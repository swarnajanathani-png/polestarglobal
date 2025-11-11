@isTest
private class LeadTriggerTEST {

    static testMethod void myUnitTest() {
        
        Lead testLead = new Lead(LastName = 'test', LeadSource = 'Social Media', Company = 'test');
        Insert testLead;
        
        Lead leadResult = [SELECT Id, LeadSource, Lead_Source_for_mapping__c FROM Lead WHERE Id =: testLead.Id];
        
        system.assert(leadResult.LeadSource == leadResult.Lead_Source_for_mapping__c);
        
    }
    
}