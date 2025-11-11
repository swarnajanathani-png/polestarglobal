@isTest
private class LRITGetCTPriceTest {

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
        
        /* Insert Pricebook */
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Retail',
            IsActive = true
        );
        insert customPricebook;
        
        Product2 p = new Product2();
        p.Name = 'LRIT Conformance Test';
        p.Family = 'LRIT';
        p.Vessel_Flag__c = 'Panama - PAN';
        insert p;
		
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = p.Id;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 175;
        pbe.Pricebook2Id = '01s200000000BIgAAM';
        pbe.IsActive = true;
        insert pbe; 
        
		PriceBookEntry retailpbe = new PriceBookEntry();
        retailpbe.Product2Id = p.Id;
        retailpbe.CurrencyIsoCode = 'USD';
        retailpbe.UnitPrice = 175;
        retailpbe.Pricebook2Id = customPricebook.Id;
        retailpbe.IsActive = true;
        insert retailpbe; 
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getCTROpportunities';
        req.params.put('customerid',acc.Id);
        req.requestBody = Blob.valueOf('{"vesselFlag": "Panama - PAN","customerId":"'+acc.Id+'","billingCountry":"United Kingdom"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITGetCTPrice.getCTPrice();
        Test.stopTest(); 
    }
}