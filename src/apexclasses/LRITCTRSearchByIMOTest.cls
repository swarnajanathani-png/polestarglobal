@isTest
public class LRITCTRSearchByIMOTest{
    @isTest
    public static void testLRITCTRSearchByIMO(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/LRITCTRSearchByIMO';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTRSearchByIMO.ctrSearchByIMO();
        Test.stopTest();
    }
    
    @isTest
    public static void testCTRSearch(){
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
        
        // Create test data
        LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '112312', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;
        LRIT_CTR_Request__c request = new LRIT_CTR_Request__c(
            Pole_Star_LRIT_Test_Number__c = '0002',
            Billing_Address__c = '123 Fake Street',
            Delivery_Country__c = 'United Kingdom',
            Delivery_Address_same_as_Billing_Address__c = true,
            Delivery_Contact_Name__c = 'Jon Doe',
            Delivery_Email_Address__c = 'jondoe@test.com',
            Delivery_phone_Number__c = '07777777777',
            Terms_and_Conditions_Accepted__c = true,
            LRIT_Conformance_Test__c = conformance.Id,
            LRIT_CTR_Status__c = 'Valid',
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Status__c = 'Completed',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateOpportunityPaymentRef';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","LRITCTR" : {"IMO":"112312"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTRSearchByIMO.ctrSearchByIMO();
        Test.stopTest();
    }
}