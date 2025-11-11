/**
*  @who TL @ 4C
*  @what Email parsing utility class
*  @when 12/08/2017
*   @edits
*  Tiago Lopes - 21/1/2019 - Line 242 - getShip method now only fetches ship and assumes only 1 ship can be found for a given IMO nr
*  iago Lopes - 21/1/2019 - Line
* ---------------------------------------------------------------------------------------------------------
*  Email parsing utility runs off custom metadata settings, a record for each Case field to parse and map. Custom metadata records hold:
*      Case Field Name : name of the Case api field name to map the parsed string to.
*      Regex Pattern : String holding the regex to match the Case Description against, and extract the matched string. Some of the records hold multiple rules separated by ' --- '
*      Text Clean : Boolean identifying if parsed string needs unwanted char trimming.
*  Algorithm will loop over CMD settings and attempt to extract all strings matching Regex Patters found, and map it to the corresponding case field.
*  As last step it will attempt to update the case with new mapped fields.
**/

public with sharing class EmailParserUtil {
  public static final String SPLITTER = ' --- ';
  public static final String SHIP_NAME  = 'Ship_Name_Parsed__c';
  public static final String IMO_NUMBER = 'IMO_Parsed__c';
  public static final String TEST_TEST  = 'TEST';
  public static final String TEST_ALERT = 'Test Alert';
  public static final String REAL_ALERT = 'Real Alert';
  public static final String FULLY_PARSED = 'Ship record assigned successfully with all fields matching.';
  public static final String PARTIALLY_PARSED = 'Some of the fields failed to parse and need verification. Did not proceed to Ship record assignment.';
  public static final String PARSED_SHIP_NOT_FOUND = 'No Ship record was found in database.';
  public static final String PARTIAL_SHIP_MATCH = 'Ship record matches some of the parsed fields.';
  public static final String NO_SHIP_MATCH = 'Ship record does not match any of the parsed criteria.';
  public static final String NO_IMONR = 'IMO Number not found.';
  public static final STRING MULTIPLE_SHIPS_FOUND = 'Multiple ships with matching criteria found. Assigned the one with most matching criteria.';
  // message that will hold parsing comments to be assigned to case field Email_Parsing_Notes__c
  public static String MESSAGE;
  // string holding unmatched fields used for ship matching
  public static String UNMATCHED_SHIP_FIELDS = '';
  // record type for SSAS Alert
  private static final String RT_SSASALERT = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSAS Alert').getRecordTypeId();

  /**
  *  @description entry point method for cases coming from Case trigger handlers. Will handle bulk cases if needed
  *  @param cases with list of cases to process
  */
  public static void handleCasesForParsing(List<Case> cases){
    List<Case> casesToUpdate = new List<Case>();
    for(Case c : cases){
      Case clonedCase = handleForParsing(c);
      if(clonedCase != null){
        casesToUpdate.add(clonedCase);
      }
    }
    if(!casesToUpdate.isEmpty()){
      try{
        update casesToUpdate;
      }
      catch(DmlException e){
        //log error
        System.debug(' ### Failed to update case fields after assignment: ' + e.getMessage());
      }
    }
  }

  /**
  *  @description entry point method for cases coming from Case trigger handlers. Will handle bulk cases if needed
  *  @param cases with list of cases to process
  */
  public static void handleCasesForGeolocationCalc(List<Case> cases){
    List<Case> casesToUpdate = new List<Case>();
    for(Case c : cases){
      Case clonedCase = handleForGeolocationCalc(c);
      if(clonedCase != null){
        casesToUpdate.add(clonedCase);
      }
    }
    if(!casesToUpdate.isEmpty()){
      try{
        update casesToUpdate;
      }
      catch(DmlException e){
        //log error
        System.debug(' ### Failed to update case  geolocation fields on after update: ' + e.getMessage());
      }
    }
  }
  
  /**
  *  @description handler method that has some logic control for some fields and sends them for parsing each case individually passed by handleCases method
  *  @param case to be parsed
  *  @return Case with modified case fields to be updated, or null
  **/  
  public static Case handleForParsing(Case c){
    Case clonedCase;
    if(String.isNotBlank(c.Description) && c.RecordTypeId == RT_SSASALERT){
      String body = c.Description;
      List<SSAS_Parser_settings__mdt> settings = getSettings();
      if(!settings.isEmpty()){
        
        // assign default case info
        clonedCase = new Case(Id = c.Id);
        
        // check for 'TEST TEST' and change alert status field, else tag as an ALERT message
        clonedCase.Alert_Status__c =  getAlertStatus(String.valueOf(body));
        
        // Halt process if this is not a real or a test alert case and return case as it is.
        if(clonedCase.Alert_Status__c != TEST_ALERT && clonedCase.Alert_Status__c != REAL_ALERT)
          return clonedCase;
        
        Map<String,String> nameMap = new Map<String,String>();
        List<String> shipFieldsToParse = new List<String>();
        Map<String,String> shipFieldNameToCaseFieldNameMap = new Map<String,String>();
                for(SSAS_Parser_settings__mdt setting : settings ){
          String parsedValue = parse(body, setting.Regex_Pattern__c, setting.Text_Clean__c, setting.Letter_Clean__c);
          // clean map value for unwanted chars/spaces in beggining and end of string
          parsedValue = cleanString(parsedValue);
          nameMap.put(setting.Case_Field_Name__c, parsedValue);
          // build ship field map to use for ship field matching later on
          if(setting.Ship_Field_Name__c != null)
            shipFieldsToParse.add(setting.Ship_Field_Name__c);
            shipFieldNameToCaseFieldNameMap.put(setting.Ship_Field_Name__c, setting.Case_Field_Name__c);
          
        }
        
        
        //go for ship record if IMO number is not null
        if(nameMap.get(IMO_NUMBER) != null && String.isNotBlank(nameMap.get(IMO_NUMBER))){
          Ship__c s = getShip(nameMap.get(IMO_NUMBER));
          if(s != null){
            // validate ship fields against case parsed values
            validateShipFields(shipFieldsToParse, s, nameMap, shipFieldNameToCaseFieldNameMap, c.Description);
            // if ship is not null, get ship name and try to find it in email description
            if(String.valueOf(c.Description).containsIgnoreCase(s.Name)){
              clonedCase.put('Ship_Name_Parsed__c', s.Name);
              //nameMap.put('Ship_Name_Parsed__c',s.Name);
            } else{
              UNMATCHED_SHIP_FIELDS = UNMATCHED_SHIP_FIELDS + 'Name';
              MESSAGE = PARTIAL_SHIP_MATCH;
            }
            clonedCase.Ship__c = s.Id;
            // get ST for nested ship query related if email is TEST 
            clonedCase.Scheduled_Test__c = clonedCase.Alert_Status__c == TEST_ALERT ? 
                             getScheduledTest(s.Scheduled_Tests__r) : null;
          }
                    if(MESSAGE != FULLY_PARSED && clonedCase.Alert_Status__c == TEST_ALERT) 
                        clonedCase.Verification_Required__c = true;
        }
        // else
        else{
          MESSAGE = NO_IMONR;
        }

        // run verification on map null values to check if case needs manual verification
        clonedCase.Verification_Required__c = clonedCase.Alert_Status__c == TEST_ALERT ?
                            checkVerificationRequired(nameMap) : false;
        
        for(String caseFieldName : nameMap.keySet()){
          try{  
            if(String.isNotBlank(nameMap.get(caseFieldName)) != null){
              if(caseFieldName != SHIP_NAME)
                clonedCase.put(caseFieldName, nameMap.get(caseFieldName));
            }
          }
          catch(Exception e1){
            System.debug(' ### Problem found during case field assignment: ' + e1.getMessage());
          }
        }
      }
    }

    // update message to Notes field just before returning
    if(MESSAGE != null)
      clonedCase.SSAS_Email_Parsing_Notes_New__c = MESSAGE;
    // update unmatched ship fields just before returning
    if(String.isNotBlank(UNMATCHED_SHIP_FIELDS))
      clonedCase.Unmatched_Ship_Fields__c = UNMATCHED_SHIP_FIELDS;
    return clonedCase;
  }

  /**
  *  @description  method that parses case description to extract strings
  *  @param String body with case description as string
  *  @param String regex holding the regex rule to match the case description agains
  *  @param Boolean textClean telling if the field should be 'cleaned' after parsing for removal of un wanted characters
  *  @return String with the extracted string if found by pattern, null if not
  **/
  private static String parse(String body, String regex, Boolean textClean, Boolean letterClean){
    String val = '';
    if(String.isNotBlank(body) && String.isNotBlank(regex) != null){
      // start parsing
      try{
        // split regex at ' --- '
        List<String> splitRegex = regex.split(SPLITTER);
        for(String reg : splitRegex){
                    System.debug('reg ' + reg);
          Pattern patt = Pattern.compile(String.valueOf(reg));
          Matcher matcher = patt.matcher(String.valueOf(body));
          List<String> matchedStrings = new List<String>();
                    
                    
                    while(matcher.find()){
                        String matcherGroup = matcher.group().toLowerCase();
                        if(matcherGroup.contains('Speed') || matcherGroup.contains('Spd') ||
                           matcherGroup.contains('SPEED') || matcherGroup.contains('SOG') ||
                           matcherGroup.contains('sog')){
                               matchedStrings.add(matcher.group(2));
                        } else if(matcherGroup.contains('HDG') || matcherGroup.contains('hdg') ||
                                  matcherGroup.contains('Heading') || matcherGroup.contains('HEADING') ||
                                  matcherGroup.contains('Course') || matcherGroup.contains('COURSE') ||
                                  matcherGroup.contains('cog') || matcherGroup.contains('COG')){
                                      
                                      matchedStrings.add(matcher.group(2));
                                      
                        } else {
                            matchedStrings.add(matcher.group());
                        }
                       
                    }
                    if(!matchedStrings.isEmpty()){
            val = matchedStrings.get(0);
            // clean string
                        if(textClean){
                            val = val.replaceAll('\\W', '');
                        }
                        
                        if(letterClean){
                            val = val.replaceAll('[a-zA-Z]', '');
                        }
            // exit loop 
            break;
          }
        }
      }
      catch(Exception e){
        // log error
        System.debug(' ### Error found parsing text: ' + e.getMessage());
      }
    }
    return val;
  }

  /**
  *  @description method to query the ship record by unique identifier IMO number
  *  @param imoNr with string to filter by
  *  @param valueTofieldNameMap with parsed fields to match against ship fields, to be passed to other method
  *  @return Ship__c with ship record found or null
  *
  **/
  private static Ship__c getShip(String imoNr){
    Ship__c matchingShip;
    if(String.isNotBlank(imoNr)){
      List<Ship__c> ships = [SELECT Id, Name, IMO_Number__c, MMSI__c, Call_Sign__c,
      (SELECT Test_Date__c FROM Scheduled_Tests__r WHERE Status_Formula__c != 'Cancelled' ORDER BY Test_Date__c DESC) 
      FROM Ship__c WHERE IMO_Number__c = :imoNr];
      if(!ships.isEmpty()){
        matchingShip = ships.get(0);
      }
      else{
        MESSAGE = PARSED_SHIP_NOT_FOUND;
      }
    }
    return matchingShip;
  }

  //
  private static Id getScheduledTest(List<Scheduled_Test__c> sts){
    if(sts != null){
      for(Scheduled_Test__c sc : sts){
        if(sc.Test_Date__c != null && isWithinThreeDays(sc.Test_Date__c))
          return sc.Id;
      }
    }
    return null;
  }

  // checks if given testDate is within 3 days of the current date
  private static Boolean isWithinThreeDays(Date testDate){
    // use case createdDate as System.today()
    return System.today() >= testDate.addDays(-1) && System.today() <= testDate.addDays(1); 
  }

  /**
  * @description
  * Checks values in the ship fields (IMO,CALL SIGN,MMSI) against case body and updates parsed value map in case any of those fields
  * have been parsed wrongly
  * @param shipFieldsToParse with the list of ship api field names to check value against case
  * @param ship with the ship object to get values from
  * @param nameValueMap with the parsed strings from the text to compare and update
  * @param shipFieldNameToCaseFieldNameMap with the map of ship field api name => case field api name
  * @param caseBody with the content of the email sent to match against
  */
  private static void validateShipFields(List<String> shipFieldsToParse,
                       Ship__c ship,
                       Map<String,String> nameValueMap, 
                       Map<String,String> shipFieldNameToCaseFieldNameMap,
                       String caseBody){
    Boolean fullMatch = true;
    // for every field on shipFieldsToParse, check if case description contains the value for that field that is on the ship record
    for(String shipFieldName : shipFieldsToParse){
      try{
        String shipFieldValue = String.valueOf(ship.get(shipFieldName));
        // if case description contains the ship field value, put it/replace it in the namevaluemap so we can get the correct one
        // in case we parsed wrongly
        if(caseBody.containsIgnoreCase(shipFieldValue)) nameValueMap.put(shipFieldNameToCaseFieldNameMap.get(shipFieldName), shipFieldValue);
        else{
          UNMATCHED_SHIP_FIELDS = UNMATCHED_SHIP_FIELDS + ' ' + shipFieldName;
          // if body doesn't contain value, erase value for the parsed text
          nameValueMap.put(shipFieldNameToCaseFieldNameMap.get(shipFieldName),'');
          fullMatch = false;
        }
      }
      catch(Exception e){
        System.debug('Problem occured while matching ship field values against email description: ' + e.getMessage());
        UNMATCHED_SHIP_FIELDS = UNMATCHED_SHIP_FIELDS + ' ' + shipFieldName;
      }
    }
    if(!fullMatch) MESSAGE = PARTIAL_SHIP_MATCH;
  }

  
  public static Case handleForGeolocationCalc(Case c){
    Case clonedCase = new Case(Id = c.Id );
    String parsedLat = c.Latitude_Parsed__c;
    String parsedLong = c.Longitude_Parsed__c;
    try{
      // extract letter from coordinates
      String latSign = getCoordinateSign(parsedLat,'lat');
      String longSign = getCoordinateSign(parsedLong, 'long');
      if(latSign != null){
        Decimal lat = cleanAndGetGeolocationResult(parsedLat, latSign);
        if(lat != null){
          clonedCase.Location__Latitude__s = lat;
        }
      }
      if(longSign != null){
        Decimal longitude = cleanAndGetGeolocationResult(parsedLong, longSign);
        if(longitude != null){
          clonedCase.Location__Longitude__s = longitude;
        }
      }

    }
    catch(Exception e){
      System.debug(' ### Problem found during geolocation assignment: ' + e.getMessage());
    }
    return clonedCase;
  }


                   /*************** helper methods **************** */
    /**
    * @description returns Alert Status picklist value depending on email context
    * @param       caseBody with email body as string 
    * @return      String with alert status value
    */
    private static String getAlertStatus(String caseBody){
      String alertStatus;

      if(String.isNotBlank(caseBody)){
        /*alertStatus = caseBody.containsIgnoreCase(TEST_TEST) ? TEST_ALERT :
                (caseBody.containsIgnoreCase('This is not a test') 
                          && caseBody.containsIgnoreCase('SSAS') 
                || caseBody.containsIgnoreCase('Security') 
                || caseBody.containsIgnoreCase('Alert')) ?
                REAL_ALERT : 'SSAS Miscellaneous';*/
            

            if(!caseBody.containsIgnoreCase('This is not a test') && caseBody.containsIgnoreCase(TEST_TEST)){
                alertStatus = TEST_ALERT;
            } else if(caseBody.containsIgnoreCase('This is not a test') || 
               (caseBody.containsIgnoreCase('SSAS') || 
                caseBody.containsIgnoreCase('Security') || 
                caseBody.containsIgnoreCase('Alert'))){
                    
                alertStatus = REAL_ALERT;
          
            } else{
                alertStatus = 'SSAS Miscellaneous';
            }
      }
      return alertStatus;
    }

  /**
  *  @description helper method to get custom metadata parsing settings from Database.
  *         Holds what Case fields should be mapped with what extracted string and all regex info
  *  @return List<SSAS_Parser_settings__mdt> holding all settings for each of the case fields to be mapped
  *
  **/
  private static List<SSAS_Parser_settings__mdt> getSettings(){
    List<SSAS_Parser_settings__mdt> settings = new List<SSAS_Parser_Settings__mdt>();
    settings = [SELECT Id, DeveloperName, Text_Clean__c, Regex_Pattern__c, Case_Field_Name__c, Ship_Field_Name__c, Letter_Clean__c FROM SSAS_Parser_settings__mdt];
    return settings;
  }

  //
  public static String getCoordinateSign(String coordinate, String dir){
    // isolate the cardinal direction to get the math sign from 
    String letter = coordinate.replaceAll('[0-9\\W]','');
    String sign;
    if(String.isNotBlank(letter)){
      if(dir == 'lat'){
        if(letter == 'N' || letter == 'n')
          sign = '';
        else if(letter == 'S' || letter == 's')
          sign = '-';
      }
      else if (dir == 'long'){
        if(letter == 'E' || letter == 'e')
          sign = '';
        else if(letter == 'W' || letteR == 'w')
          sign = '-';
      }
    }
    return sign;
  }

  //
  public static Decimal cleanAndGetGeolocationResult(String coordinate, String sign){
    Decimal result;
        // perform some cleaning:
        // 1st remove cardinal direction from coordinate
        coordinate = coordinate.replaceAll('[A-Za-z]','');
        // 2nd substitude anything that's not a floating number with a space
        coordinate = coordinate.replaceAll('[^0-9.]',' ');
        // 3rd replace all spaces and multiple spaces with one space only
        coordinate = coordinate.replaceAll('\\s+',' ');
        // 4th remove spaces at end of string
        coordinate = coordinate.replaceAll('\\s*$','');
        // 5th remove spaces at beginning of string
        coordinate = coordinate.replaceAll('^\\s*','');
        // 6th split by space
        List<String> isolatedCoordinates = coordinate.split(' ');
    // best scenario, we've isolated the coordinate string into degree, minutes, seconds. Ex 120 30' 20'', 120 25.35
    if(isolatedCoordinates.size() == 3){
      String degree = isolatedCoordinates.get(0);
      String min = isolatedCoordinates.get(1);
      String sec = isolatedCoordinates.get(2);
      result = Decimal.valueOf(degree) + (Decimal.valueOf(min)/(Decimal)60) + (Decimal.valueOf(sec)/(Decimal)3600);
      result = Decimal.valueOf(sign + String.valueOf(result)).setScale(2);
    }
    // 2nd scenario, we've isolated the coordinate string into degrees, minutes
    else if(isolatedCoordinates.size() == 2){
      String degree = isolatedCoordinates.get(0);
      String min = isolatedCoordinates.get(1);
      result = Decimal.valueOf(degree) + (Decimal.valueOf(min)/(Decimal)60);
      result = Decimal.valueOf(sign + String.valueOf(result)).setScale(2);
    }

    return result;

  }
                   
  /**
  *   Deprecated
  *  @description helper method to extract field name from parsed string containing possible ship name
  *  @param shipNameString with unformatted ship name string to extract
  *  @return String with extracted good ship name
  *
  *
  private static String extractShipName(String shipNameString){
    String nameHelper = '';
    if(shipNameString.contains('Name')) nameHelper = shipNameString.substringAfter('Name');
    else if(shipNameString.contains('NAME')) nameHelper = shipNameString.substringAfter('NAME');
    else if(shipNameString.contains('name')) nameHelper = shipNameString.substringAfter('name');
    else if(shipNameString.contains('M/V')) nameHelper = shipNameString.substringAfter('M/V');
    // clean columns
    nameHelper = nameHelper.replace(':','');
    return nameHelper;
  }*/

  /**
  *  @description helper method to clean parsed strings from unwanted characters
  *  @param val with string to be cleaned
  *  @return String with cleaned string
  *
  **/
  private static String cleanString(String val){
    String value;
    if(String.isNotBlank(val)){
      try{
        value = val.replace(',','');
        value = value.replaceAll('^\\W*','');
        value = value.replaceAll('\\s*$','');
      }
      catch(Exception e){
        System.debug('Failed to clean parsed value: ' + e.getMessage());
      }
    }
    return value;
  }

  /**
  *  @description helper method to check whether fields have been parsed from email text, will flag for verification required if parsing fails
  *  @param nameMap with map of case field name as key and parsed string as value, values will be blank if they failed to be parsed
  *  @return Boolean for verification required checkbox
  *
  **/
  private static Boolean checkVerificationRequired(Map<String,String> nameMap){
    Boolean isVerificationRequired = false;
        for(String key : nameMap.keySet()){
      // adding exception for Time Standard
      if(String.isBlank(nameMap.get(key)) && key != 'Time_Standard_Parsed__c' ){
        MESSAGE = PARTIALLY_PARSED;
        isVerificationRequired = true;
        break;
      }
    }
    if(!isVerificationRequired) MESSAGE = FULLY_PARSED;
    return isVerificationRequired;
  }
}