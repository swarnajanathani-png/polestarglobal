@isTest
public class OpportunityRestClassTest{
    @isTest
    public static void testOpportunityRestCallException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateOpportuntity';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        OpportunityRestClass.postOpportunity();
        Test.stopTest();
    }
    
    @isTest
    public static void testNewOpportunity(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        insert acc;
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateOpportuntity';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","Opportunity" : {"CustomerId":"'+acc.Id+'","LRITContactLastName":"test"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        OpportunityRestClass.postOpportunity();
        Test.stopTest();
    }
}