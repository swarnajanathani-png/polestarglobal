@isTest
private class LRITGetCTRPriceTest {

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
                
        Product2 fastrackproduct = new Product2();
        fastrackproduct.Name = 'LRIT Fasttrack Charge';
        fastrackproduct.Family = 'LRIT CTR';
        fastrackproduct.SAP_Item_Code__c = 'SW00000212';
        insert fastrackproduct;
        
        Product2 courierproduct = new Product2();
        courierproduct.Name = 'LRIT Courier Charge';
        courierproduct.Family = 'LRIT CTR';
        courierproduct.SAP_Item_Code__c = 'SW00000213';
        insert courierproduct;
        
        Product2 p = new Product2();
        p.Name = 'LRIT Certificate - Panama';
        p.Family = 'LRIT CTR';
        p.Vessel_Flag__c = 'Panama - PAN';
        insert p;
		
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = p.Id;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 175;
        pbe.Pricebook2Id = '01s200000000BIgAAM';
        pbe.IsActive = true;
        insert pbe;
        
        PriceBookEntry fastrackpbe = new PriceBookEntry();
        fastrackpbe.Product2Id = fastrackproduct.Id;
        fastrackpbe.CurrencyIsoCode = 'USD';
        fastrackpbe.UnitPrice = 175;
        fastrackpbe.Pricebook2Id = '01s200000000BIgAAM';
        fastrackpbe.IsActive = true;
        insert fastrackpbe;
        
        PriceBookEntry courierpbe = new PriceBookEntry();
        courierpbe.Product2Id = courierproduct.Id;
        courierpbe.CurrencyIsoCode = 'USD';
        courierpbe.UnitPrice = 175;
        courierpbe.Pricebook2Id = '01s200000000BIgAAM';
        courierpbe.IsActive = true;
        insert courierpbe;
        
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
        LRITGetCTRPrice.getCTRPrice();
        Test.stopTest(); 
    }
}