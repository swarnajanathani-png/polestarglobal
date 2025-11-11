@isTest
public class GetAccountRestClassTest{
    @isTest
    public static void testGetAccountRestCallException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getAccount';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetAccountRestClass.getAccountDetails();
        Test.stopTest();
    }
    
    @isTest
    public static void testNewAccount(){
        //Creating New Account
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Email';
        insert acc;
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getAccount';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","Account" : {"CustomerId":"'+acc.Id+'"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetAccountRestClass.getAccountDetails();
        Test.stopTest();
    }
  
}