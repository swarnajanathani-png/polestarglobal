@isTest
public class UpdateHardwareOpportunityCommentsTest {
    @isTest
    public static void testOpportunityCommentsUpdateCallException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateHardwareOpportunityComments';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateHardwareOpportunityComments.updateHardwareOpportunityComments();
        Test.stopTest();
    }
    
    @isTest
    public static void testOpportunityCommentsUpdate(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;
        
        Opportunity oppRec = [Select Id, Service_PSON__c from Opportunity where Id=:opp.Id];
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateHardwareOpportunityComments';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","Opportunity" : {"PSON":"'+oppRec.Service_PSON__c+'","Comments":"12345"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateHardwareOpportunityComments.updateHardwareOpportunityComments();
        Test.stopTest();
    }

}