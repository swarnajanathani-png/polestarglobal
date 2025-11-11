@isTest
private class LRITGetODSPriceTest {

    static testMethod void test() {
        Account acc = new Account(
        	Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event ',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            ShowOnPortal__c = true
        );
        insert acc;
                
        Product2 odsproduct = new Product2();
        odsproduct.Name = 'Ondemand Screening';
        odsproduct.Family = 'Ondemand Screening';
        odsproduct.SAP_Item_Code__c = 'SW00000625';
        insert odsproduct;
                
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = odsproduct.Id;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 175;
        pbe.Pricebook2Id = '01s200000000BIgAAM';
        pbe.IsActive = true;
        insert pbe;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getODSPrice';
        req.params.put('customerid',acc.Id);
        req.requestBody = Blob.valueOf('{"customerId":"'+acc.Id+'","billingCountry":"United Kingdom"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITGetODSPrice.getODSPrice();
        Test.stopTest(); 
    }
}