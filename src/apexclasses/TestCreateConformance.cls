@isTest
public class TestCreateConformance{
    @isTest
    public static void testCTExceptions(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateConformanceTest';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        CreateConformanceTest.createConformanceTest();
        Test.stopTest();
    }
    
    @isTest
    public static void testCT(){
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
        req.requestURI = '/services/apexrest/CreateConformanceTest';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","ConformanceTestDetails" : {"PSON":"'+oppRec.Service_PSON__c+'","PaymentReceiptNumber":"12345","customerSecondEmail":"test@test.com"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        CreateConformanceTest.createConformanceTest();
        Test.stopTest();
    }
}