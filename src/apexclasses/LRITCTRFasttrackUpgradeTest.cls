@isTest
public class LRITCTRFasttrackUpgradeTest{
    @isTest
    public static void testCTRFasttrackUpgradeException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateCTROpportunityFTPayment';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTRFasttrackUpgrade.ctrFasttrackUpdate();
        Test.stopTest();
    }
    
    @isTest
    public static void testCTRFasttrackUpgrade(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.CurrencyISOCode = 'USD';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
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
            Opportunity__c = opp.Id,
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;
        
        Opportunity oppRec = [Select Id, Service_PSON__c from Opportunity where Id=:opp.Id];
        
        Product2 p = new Product2();
        p.Name = 'LRIT Certificate - Panama';
        p.Family = 'LRIT CTR';
        p.Vessel_Flag__c = 'Panama - PAN';
        insert p;
        
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
        req.requestURI = '/services/apexrest/updateCTROpportunityFTPayment';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","Opportunity" : {"PSON":"'+oppRec.Service_PSON__c+'","FastTrackPaymentReceiptNumber":"12345","Currency":"USD"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTRFasttrackUpgrade.ctrFasttrackUpdate();
        Test.stopTest();
    }
}