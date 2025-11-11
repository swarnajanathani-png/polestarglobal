@isTest
public class TestUpdateConformance{
    @isTest
    public static void testCTExceptions(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateConformanceTest';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateConformanceTest.updateConformanceTest();
        Test.stopTest();
    }
    
    @isTest
    public static void testCT(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        acc.Line_of_Business__c = 'API Customer';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;
        
        Opportunity oppRec = [Select Id, Service_PSON__c from Opportunity where Id=:opp.Id];
        
        LRIT_Conformance_Tests__c ct = new LRIT_Conformance_Tests__c();
        ct.Pole_Star_LRIT_Test_Number__c = 'CT Test';
        insert ct;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateConformanceTest';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","ConformanceTestDetails" : {"pson":"'+oppRec.Service_PSON__c+'","ctRecordId":"'+ct.Id+'","PaymentReceiptNumber":"12345","customerSecondEmail":"test@test.com"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateConformanceTest.updateConformanceTest();
        Test.stopTest();
    }
}