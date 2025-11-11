@IsTest
private class LRITGetCTROpportunitiesTest {
    
    @TestSetup
    static void setupData() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            Credit_terms__c = 'Net 30',
            Is_Distributor__c = false,
            BillingCountry = 'United Kingdom',
            Lead_Source__c = 'Self Service Portal',
            Line_of_Business__c  = 'Commercial Marine',
            SAP_Key__c = 'SAP123'
        );
        insert acc;
        
        // Create Product and PriceBook data
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Retail',
            IsActive = true
        );
        insert customPricebook;
        Product2 prod = new Product2(Name = 'LRIT CTR Product', Family = 'LRIT CTR', SAP_Item_Code__c = 'SW00000212', IsActive = true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = '01s200000000BIgAAM',
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true,
            UseStandardPrice = false,
            CurrencyIsoCode = 'USD'
        );
        insert pbe;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            Payment_Option__c = 'Credit Terms',
            Amount = 500,
            CurrencyIsoCode = 'USD',
            Invoice_Company_Name__c = 'Test Co',
            Invoice_Country__c = 'United Kingdom',
            Order_Date__c = Date.today()
        );
        insert opp;
        
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
        
        // Create LRIT CTR Request
        LRIT_CTR_Request__c ctr = new LRIT_CTR_Request__c(
            Status__c = 'Completed',
            LRIT_CTR_Status__c = 'Valid',
            Opportunity__c = opp.Id,
            Vessel_Name__c = 'Vessel Alpha',
            IMO_Number__c = 'IMO1234',
            Delivery_Option__c = 'Standard',
            LRIT_Conformance_Test__c = conformance.Id
        );
        insert ctr;
    }
    
    @IsTest
    static void test_getCTROpportunities_success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getCTROpportunities';
        req.httpMethod = 'GET';
        req.params.put('customerid', acc.Id);
        req.params.put('searchstring', 'Vessel');
        req.params.put('recordcount', '10');
        req.params.put('pagenumber', '0');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        LRITGetCTROpportunities.getCTROpportunities();
        Test.stopTest();
        
        System.assertNotEquals(null, RestContext.response.responseBody, 'Response should not be null');
    }
    
    @IsTest
    static void test_getCTROpportunities_invalidAccount() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getCTROpportunities';
        req.httpMethod = 'GET';
        req.params.put('customerid', '001000000000000AAA');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        LRITGetCTROpportunities.getCTROpportunities();
        Test.stopTest();
        
        String res = RestContext.response.responseBody.toString();
    }
    
    @IsTest
    static void test_getCTROpportunities_exceptionPath() {
        // Force exception by not inserting dependent data
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/getCTROpportunities';
        req.httpMethod = 'GET';
        req.params.put('customerid', null);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        LRITGetCTROpportunities.getCTROpportunities();
        Test.stopTest();
        
        System.assert(RestContext.response.responseBody.toString().contains('"statuscode"') , 'Should return 500 error');
    }
}