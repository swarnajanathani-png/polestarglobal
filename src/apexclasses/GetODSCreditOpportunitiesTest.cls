@isTest
private class GetODSCreditOpportunitiesTest {

    @isTest
    static void testGetODSCreditOpportunities_Success() {
        // Create parent account (distributor)
        Account parentAcc = new Account(
            Name = 'Distributor Parent',
            Credit_terms__c = 'Payment on invoice',
            BillingCountry='United Kingdom',
            Lead_Source__c = 'Email',
            Line_of_Business__c = 'Commercial Marine',
            Is_Distributor__c = true
        );
        insert parentAcc;

        // Create child account (customer)
        Account acc = new Account(
            Name = 'Test Account',
            ParentId = parentAcc.Id,
            Credit_terms__c = 'Payment on invoice',
            BillingCountry='United Kingdom',
            Lead_Source__c = 'Email',
            Line_of_Business__c = 'Commercial Marine',
            SAP_Key__c = 'SAP123',
            Is_Distributor__c = false
        );
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            Type = 'Portal Ondemand Screening',
            Product_Type__c = 'Ondemand Screening Credits',
            StageName = 'Closed Won',
            CloseDate = System.today(),
            CurrencyIsoCode = 'GBP',
            Invoice_Company_Name__c = 'Test Billing Co',
            Invoice_Address_Line1__c = 'Line 1',
            Invoice_City__c = 'City',
            Invoice_State__c = 'State',
            Invoice_Zip_Code__c = '12345',
            Invoice_Country__c = 'Country',
            Finance_Contact_Name__c = 'Finance Person',
            Finance_Email__c = 'finance@example.com',
            Finance_Phone__c = '123456789',
            CreatedDate = System.now(),
            Order_Date__c = Date.today(),
            Payment_Option__c = ''
            //RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Master').getRecordTypeId()
        );
        insert opp;

        // Create OpportunityLineItem
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;

        // Get StandardPricebook Id
        Id standardPBId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = standardPBId,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 10,
            PricebookEntryId = pbe.Id,
            Product_Sales_Type__c = 'One-off Product',
            UnitPrice = 100
        );
        insert oli;

        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/getODSCreditOpportunities/';
        req.httpMethod = 'GET';
        req.addParameter('customerid', acc.Id);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            GetODSCreditOpportunities.getODSCreditOpportunities();
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, RestContext.response.responseBody, 'Response body should not be null');
        String responseBody = RestContext.response.responseBody.toString();
        System.debug('Response: ' + responseBody);
        System.assert(responseBody.contains('"statuscode":"200"'), 'Response should indicate success');
        System.assert(responseBody.contains('"customerId":"'+acc.Id+'"'), 'Response should include correct customer ID');
    }

    @isTest
    static void testGetODSCreditOpportunities_InvalidCustomerId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/getODSCreditOpportunities/';
        req.httpMethod = 'GET';
        req.addParameter('customerid', '001000000000000'); // Non-existent Id
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            GetODSCreditOpportunities.getODSCreditOpportunities();
        Test.stopTest();
		System.debug(RestContext.response.responseBody.toString());
        System.assert(RestContext.response.responseBody.toString().contains('Please provide valid customer id'));
    }
}