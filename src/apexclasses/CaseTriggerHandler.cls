/**
*	@who	TL @ 4C
*	@what	Handler class for Case Trigger
*	@when	12/08/2017
*/
public with sharing class CaseTriggerHandler {
	private static CaseTriggerHandler instance;

	private CaseTriggerHandler() {
		
	}

	public static CaseTriggerHandler getInstance(){
		if(instance == null){
			instance = new CaseTriggerHandler();
		}
		return instance;
	}
	public void handleOnBeforeInsert(List<Case> triggerNew){
        List<RecordType> recTypeList = [Select Id from RecordType where DeveloperName = 'LRIT_Non_Reporting'];
        List<Group> queuesList = [Select Id from Group where Type = 'Queue' AND DeveloperNAME = 'LRIT_Non_Reporting_Queue'];
        String lowercaseSubject = '';
        String lowercaseDescription = '';
        Boolean isSubjectNotBlank = false;
        Boolean isDescriptionNotBlank = false;
        for(Case c:triggerNew){
            if(String.isNotBlank(c.Subject)){
            	lowercaseSubject = c.Subject.toLowerCase();
                isSubjectNotBlank = true;
            }
            if(String.isNotBlank(c.Description)){
            	lowercaseDescription = c.Description.toLowerCase();
                isDescriptionNotBlank = true;
            }
            String lritNonReportingKeyWords = System.Label.LRIT_Non_Reporting_Keywords;
            if(String.isNotBlank(lritNonReportingKeyWords)) {
                
                for(String keyword : lritNonReportingKeyWords.split(';')) {
                	if((isSubjectNotBlank && lowercaseSubject.Contains(''+keyword) == True) ||
                       (isDescriptionNotBlank && lowercaseDescription.Contains(''+keyword) == True) ) {
                       if(!recTypeList.isEmpty()) {
                            c.RecordTypeId = recTypeList[0].Id;        
                       }
                       if(!queuesList.isEmpty()) {
                            c.OwnerId = queuesList[0].Id;        
                       }
                       c.Priority = 'P2';
                       c.Issue_Type__c = 'Request';
                       c.Platform__c = 'LRIT DC';
                       c.Case_Type__c = 'Device has stopped reporting';
                       c.Sub_Type__c = 'LRIT';
                       break;
                    }    
                }   
            }
        }
    }
	public void handleOnAfterInsert(List<Case> triggerNew){
		List<Case> casesToParseDescription = new List<Case>();
		if(!triggerNew.isEmpty()){
			for(Case c : triggerNew){
				// handle case description parsing
				if(validateDescription(c, 'insert')){
					casesToParseDescription.add(c);
				}
				//
			}
			if(!casesToParseDescription.isEmpty()){
				EmailParserUtil.handleCasesForParsing(casesToParseDescription);
			}
		}
	}

	public void handleOnAfterUpdate(List<Case> triggerNew, Map<Id,Case> oldMap){
		List<Case> casesToUpdateGeolocation = new List<Case>();
		if(!triggerNew.isEmpty()){
			for(Case c : triggerNew){
				// handle geolocation update
				if(validateFieldsForGeolocationCalc(c, oldMap, 'update')){
					casesToUpdateGeolocation.add(c);
				}
			}
			if(!casesToUpdateGeolocation.isEmpty()){
				EmailParserUtil.handleCasesForGeolocationCalc(casesToUpdateGeolocation);
			}
		}
	}

	// private helpers

	private Boolean validateDescription(Case c, String event){
		if(event == 'insert'){
			if(c.Description != null){
				return (c.Description == null) ? false : true;
			}
		}
		return false;
	}

	private Boolean validateFieldsForGeolocationCalc(Case c, Map<Id,Case> oldMap, String event){
		if(event == 'update'){
			if((c.Latitude_Parsed__c != null && c.Latitude_Parsed__c != oldMap.get(c.Id).Latitude_Parsed__c) 
				&& (c.Longitude_Parsed__c != null && c.Longitude_Parsed__c != oldMap.get(c.Id).Longitude_Parsed__c)){
				return true;
			}
		}
		return false;
	}
}