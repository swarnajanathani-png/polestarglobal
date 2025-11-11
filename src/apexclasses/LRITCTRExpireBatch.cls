global class LRITCTRExpireBatch implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'Select Id,Valid_Until__c,Extended_Until__c,LRIT_CTR_Status__c from LRIT_CTR_Request__c where Valid_Until_By_Due_Print__c < Today and LRIT_CTR_Status__c = \'Valid\'';
       
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<LRIT_CTR_Request__c> scope)
    {
        for(LRIT_CTR_Request__c ctr : scope)
        {
            /*if(ctr.Extended_Until__c == null) {
            	ctr.LRIT_CTR_Status__c = 'Expired';   
            }
            else if(ctr.Extended_Until__c < System.Today()) {
            	ctr.LRIT_CTR_Status__c = 'Expired';    
            }*/
            ctr.LRIT_CTR_Status__c = 'Expired';  
            
        }
        update scope;
    }
    global void finish(Database.BatchableContext BC) {
    }
}