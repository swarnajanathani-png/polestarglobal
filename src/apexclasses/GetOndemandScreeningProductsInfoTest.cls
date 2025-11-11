@isTest
private class GetOndemandScreeningProductsInfoTest {
    
    @isTest
    static void testGetOndemandScreeningProductsInfo_Success() {
        // Setup: Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCountry = 'United Kingdom',
            CurrencyIsoCode = 'USD',
            Credit_terms__c = 'Payment on invoice',
            Line_of_Business__c='Commercial Marine',
            Lead_Source__c = 'Email'
        );
        insert acc;
        
        // Setup: Create Product
        Product2 product = new Product2(
            Name = 'ODS Screening Product',
            IsActive = true,
            Family = 'Ondemand Screening',
            SAP_Item_Code__c = 'ODS001',
            ODS_Credits__c = 5,
            Description = 'Test ODS Description'
        );
        insert product;
        
        // Setup: Standard Price Book
        Id stdPBId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = product.Id,
            Pricebook2Id = stdPBId,
            UnitPrice = 200.00,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert pbe;

        // Setup REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.httpMethod = 'GET';
        req.requestUri = '/services/apexrest/getOndemandScreeningProductsInfo/';
        req.params.put('customerid', acc.Id);
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        GetOndemandScreeningProductsInfo.getOndemandScreeningProductsInfo();
        Test.stopTest();

        // Validate response
        String responseString = RestContext.response.responseBody.toString();
        System.assert(responseString.contains('success'), 'Response should contain success');
        System.assert(responseString.contains(acc.Id), 'Response should include the customer ID');
        System.assert(responseString.contains('ODS001'), 'Response should include the product SAP code');

        // Validate API_Request__c record created
        List<API_Request__c> requests = [SELECT Id, Name, Product_Type__c FROM API_Request__c];
        System.assertEquals(1, requests.size(), 'One API_Request__c should be created');
        System.assertEquals('Get Ondemand Screening Credits', requests[0].Name);

        // Validate Error_Log__c success log
        List<Error_Log__c> logs = [SELECT Id, Error_Message__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'One success log should be inserted');
        System.assert(logs[0].Error_Message__c.contains('Success'), 'Log should indicate success');
    }

    @isTest
    static void testGetOndemandScreeningProductsInfo_InvalidCustomer() {
        // Setup REST request with invalid customer ID
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.httpMethod = 'GET';
        req.requestUri = '/services/apexrest/getOndemandScreeningProductsInfo/';
        req.params.put('customerid', '001XXXXXXXXXXXX');  // Non-existent Account ID
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        GetOndemandScreeningProductsInfo.getOndemandScreeningProductsInfo();
        Test.stopTest();

        String response = RestContext.response.responseBody.toString();
        System.assert(response.contains('"statuscode" : "500"'), 'Should return error for invalid customer');
        
        // Validate Error_Log__c
        List<Error_Log__c> logs = [SELECT Id, Error_Message__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'One error log should be created');
    }
}