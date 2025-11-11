public with sharing class assetInsertController {

  public static void assetInsertController (List <Pole_Star_Asset__c> assets){
    
    List <string> accountCodes = new List <string>();
    
    Map <String, Id> accountCodeMap = new Map <String, Id>();
    
    Map <String, Id> prodInfoIDMap = new Map <String, Id>();
    
    for(Pole_Star_Asset__c a : assets){
    	
      if(a.Name != '' && a.Name != null){
        a.Asset_Key_Original__c = a.Name;
      }
      
      if(a.Account_Code__c != '' && a.Account_Code__c != null){
        a.Account_Code__c = (a.Account_Code__c).replace('\"','');
      }
      if(a.Name != '' && a.Name != null){
        a.Name = (a.Name).replace('\"','');
      }
      if(a.Asset_Name__c != '' && a.Asset_Name__c != null){
        a.Asset_Name__c = (a.Asset_Name__c).replace('\"','');
      }
      if(a.Communicator_Key__c != '' && a.Communicator_Key__c != null){
        a.Communicator_Key__c = (a.Communicator_Key__c).replace('\"','');
      }
      if(a.Communicator_Type__c != '' && a.Communicator_Type__c != null){
        a.Communicator_Type__c = (a.Communicator_Type__c).replace('\"','');
      }
      if(a.IMO_Number__c != '' && a.IMO_Number__c != null){
        a.IMO_Number__c = (a.IMO_Number__c).replace('\"','');
      }
      if(a.Make__c != '' && a.Make__c != null){
        a.Make__c = (a.Make__c).replace('\"','');
      }
      if(a.Model__c != '' && a.Model__c != null){
        a.Model__c = (a.Model__c).replace('\"','');
      }
      if(a.Package_Code__c != '' && a.Package_Code__c != null){
        a.Package_Code__c = (a.Package_Code__c).replace('\"','');
      }
      if(a.Status__c != '' && a.Status__c != null){
        a.Status__c = (a.Status__c).replace('\"','');
      }
      if(a.Tariff_Code__c != '' && a.Tariff_Code__c != null){
        a.Tariff_Code__c = (a.Tariff_Code__c).replace('\"','');
      }
      if(a.Deactivation_Reason__c != '' && a.Deactivation_Reason__c != null){
        a.Deactivation_Reason__c = (a.Deactivation_Reason__c).replace('\"','');
      }
      if(a.Deactivation_Date__c != '' && a.Deactivation_Date__c != null){
        try{
          Integer unixTime = integer.valueof(a.Deactivation_Date__c);
          DateTime dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);
          String dateTimeValue = dateInstance.addSeconds(unixTime).format();
          System.debug('DateTime: '+dateTimeValue);
          a.Deactivation_Date__c = dateTimeValue;
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
      }
      if(a.Registration_Date__c != '' && a.Registration_Date__c != null){
        try{
          Integer unixTime = integer.valueof(a.Registration_Date__c);
          DateTime dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);
          String dateTimeValue = dateInstance.addSeconds(unixTime).format();
          System.debug('DateTime: '+dateTimeValue);
          a.Registration_Date__c = dateTimeValue;
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
      }
      
      
      accountCodes.add(a.Account_Code__c);
      
    }
    
    system.debug('accountCodes = ' + accountCodes);
    
    
    List <Product_Information__c> prodInfoRecords = [SELECT Id, Account__c, CAC_Code__c FROM Product_Information__c WHERE CAC_Code__c in: accountCodes];
    
    system.debug('prodInfoRecords = ' + prodInfoRecords);
    
    for(Product_Information__c pI : prodInfoRecords){
      
      accountCodeMap.put(pI.CAC_Code__c, pI.Account__c);
      
      prodInfoIDMap.put(pI.CAC_Code__c, pI.Id);
      
    }
    
    system.debug('accountCodeMap = ' + accountCodeMap);
    
    
    for(Pole_Star_Asset__c a : assets){
      
      if(a.Account_Code__c != '' && a.Account_Code__c != null){
        
        try{
          a.Account__c = accountCodeMap.get(a.Account_Code__c);
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        try{
          a.Product_Information__c = prodInfoIDMap.get(a.Account_Code__c);
        }
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
      
      }
      
    }
    
  }
  
}