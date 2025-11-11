@isTest
public class LRITCTROpportunityRestServiceTest {
    @isTest
    public static void testOpportunityRestCallException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCTROpportuntity';
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal"}');
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTROpportunityRestService.postOpportunity();
        Test.stopTest();
    }
    
    @isTest
    public static void testNewOpportunity(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        acc.Line_of_Business__c = 'Commercial Marine';
        insert acc;
        
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
        
        Product2 p = new Product2();
        p.Name = 'LRIT Certificate - Panama';
        p.Family = 'LRIT CTR';
        p.Vessel_Flag__c = 'Panama - PAN';
        insert p;
        
        Product2 courierProduct = new Product2();
        courierProduct.Name = 'LRIT Certificate - Courier';
        courierProduct.Family = 'LRIT CTR';
        courierProduct.SAP_Item_Code__c = 'SW00000213';
        insert courierProduct;
        
        Product2 fasttrackProduct = new Product2();
        fasttrackProduct.Name = 'LRIT Certificate - FastTrack';
        fasttrackProduct.Family = 'LRIT CTR';
        fasttrackProduct.SAP_Item_Code__c = 'SW00000212';
        insert fasttrackProduct;
        
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = p.Id;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 175;
        pbe.Pricebook2Id = '01s200000000BIgAAM';
        pbe.IsActive = true;
        insert pbe;
        
        PriceBookEntry pbeCourier = new PriceBookEntry();
        pbeCourier.Product2Id = courierProduct.Id;
        pbeCourier.CurrencyIsoCode = 'USD';
        pbeCourier.UnitPrice = 175;
        pbeCourier.Pricebook2Id = '01s200000000BIgAAM';
        pbeCourier.IsActive = true;
        insert pbeCourier;
        
        PriceBookEntry pbeFasttrack = new PriceBookEntry();
        pbeFasttrack.Product2Id = fasttrackProduct.Id;
        pbeFasttrack.CurrencyIsoCode = 'USD';
        pbeFasttrack.UnitPrice = 175;
        pbeFasttrack.Pricebook2Id = '01s200000000BIgAAM';
        pbeFasttrack.IsActive = true;
        insert pbeFasttrack;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CreateCTROpportuntity';
        req.params.put('text','test');
        String deliveryOption = 'Fast Track';
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","Opportunity" : {"CustomerId":"'+acc.Id
                                       +'", "CTRecordId" : "'+conformance.Id
                                       +'", "DeliveryOption" : "'+deliveryOption
                                       +'", "FlagName" : "Panama - PAN'
                                       +'", "PaymentCurrency" : "USD'
                                       +'", "IsCourierRequest" : "true'
                                       +'", "AdditionalEmailAddresses" : "test1@gmail.com;test2@gmail.com;test3@gmail.com;test4@gmail.com;test6@gmail.com'
                                       +'","DeliveryContactLastName":"test"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTROpportunityRestService.postOpportunity();
        Test.stopTest();
    }

}