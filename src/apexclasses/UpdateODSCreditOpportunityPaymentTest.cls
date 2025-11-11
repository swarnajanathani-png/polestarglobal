@isTest
private class UpdateODSCreditOpportunityPaymentTest {
    
    @isTest
    static void testUpdateODSCreditOpportunityPayment_Success() {
        // Create test Account
        Account acc = new Account(Name = 'Test Account', BillingCountry='United Kingdom',Lead_Source__c = 'Email',Line_of_Business__c = 'Commercial Marine');
        insert acc;

        // Create Product
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        // Get Standard Pricebook ID
        Id pricebookId = Test.getStandardPricebookId();

        // Create PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = pricebookId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test ODS Opportunity',
            AccountId = acc.Id,
            StageName = 'Closed Received',
            CloseDate = System.today(),
            CurrencyIsoCode = 'GBP',
            Payment_Option__c = 'Credit Terms'
        );
        insert opp;

        // Create OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 2,
            UnitPrice = 100,
            PricebookEntryId = pbe.Id,
            Product_Sales_Type__c = 'One-off Product'
            
        );
        insert oli;
		Opportunity oppRec = [Select Id, Service_PSON__c from Opportunity where Id=:opp.Id];
        // Build JSON payload
        String requestBody = JSON.serialize(new Map<String, Object>{
            'Opportunity' => new Map<String, Object>{
                'PSON' => oppRec.Service_PSON__c,
                'PaymentReceiptNumber' => 'RCPT-0001'
            }
        });

        // Mock REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/updateODSCreditOpportunityPayment/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UpdateODSCreditOpportunityPayment.updateODSCreditOpportunityPayment();
        Test.stopTest();

        // Check response
        String responseBody = RestContext.response.responseBody.toString();
        System.debug('Response: ' + responseBody);
        System.assert(responseBody.contains('"statuscode" : "200"'), 'Expected success status');
        
        // Check API Request record
        List<API_Request__c> requests = [SELECT Id, Name FROM API_Request__c];
        System.assertEquals(1, requests.size(), 'API_Request__c should be created');
        System.assertEquals('Pay ODS Credit Opportunity', requests[0].Name);

        // Check Error_Log__c
        List<Error_Log__c> logs = [SELECT Id, Error_Message__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'Error_Log__c should be created');
        System.assert(logs[0].Error_Message__c.contains('successful'), 'Log should indicate success');
    }

    @isTest
    static void testUpdateODSCreditOpportunityPayment_InvalidPSON() {
        // Prepare invalid JSON (no matching PSON)
        String requestBody = JSON.serialize(new Map<String, Object>{
            'Opportunity' => new Map<String, Object>{
                'PSON' => 'NON_EXISTENT_PSON',
                'PaymentReceiptNumber' => 'RCPT-9999'
            }
        });

        // Mock REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/updateODSCreditOpportunityPayment/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        UpdateODSCreditOpportunityPayment.updateODSCreditOpportunityPayment();
        Test.stopTest();

        // Check response for failure
        String response = RestContext.response.responseBody.toString();
        System.debug('Failure Response: ' + response);
        System.assert(response.contains('"statuscode" : "500"'), 'Should return failure for invalid PSON');

        // Validate Error_Log__c created
        List<Error_Log__c> logs = [SELECT Id, Error_Message__c FROM Error_Log__c];
        System.assertEquals(1, logs.size(), 'Error log should be created for exception');
        System.assert(logs[0].Error_Message__c.contains('NON_EXISTENT_PSON'), 'Log should mention missing PSON');
    }
}