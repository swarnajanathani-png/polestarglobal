@isTest
public class GetOpenHardwareOpportunitiesTest {
	@isTest
    public static void testGetOpenHardwareOppsException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getOpenHardwareOpportunities';
        req.params.put('text','test');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetOpenHardwareOpportunities.getOpenHardwareOpportunities();
        Test.stopTest();
    }
    
    @isTest
    public static void testGetHardwareOpps(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        acc.Line_of_Business__c = 'Commercial Marine';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.CurrencyIsoCode = 'USD';
        opp.Type = 'Portal Ondemand Hardware';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;
        
               
        /* Insert Pricebook */
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Retail',
            IsActive = true
        );
        insert customPricebook;
        
        Product2 p = new Product2();
        p.Name = 'Hardware Product';
        p.Family = 'Hardware';
        p.ODP_Product__c = true;
        p.IsActive = true;
        p.SAP_Item_Code__c = 'HW00000183AS';
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
        
        Product2 p1 = new Product2();
        p1.Name = 'Hardware Product1';
        p1.Family = 'Hardware';
        p1.IsActive = true;
        p1.ODP_Product__c = true;
        p1.SAP_Item_Code__c = 'HW00000264';
        insert p1;
		
        PriceBookEntry pbe1 = new PriceBookEntry();
        pbe1.Product2Id = p1.Id;
        pbe1.CurrencyIsoCode = 'USD';
        pbe1.UnitPrice = 175;
        pbe1.Pricebook2Id = '01s200000000BIgAAM';
        pbe1.IsActive = true;
        insert pbe1; 
        
		PriceBookEntry retailpbe1 = new PriceBookEntry();
        retailpbe1.Product2Id = p1.Id;
        retailpbe1.CurrencyIsoCode = 'USD';
        retailpbe1.UnitPrice = 175;
        retailpbe1.Pricebook2Id = customPricebook.Id;
        retailpbe1.IsActive = true;
        insert retailpbe1;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Product2Id = pbe.Product2Id; 
        oppLineItem.PricebookEntryId = pbe.Id;
        oppLineItem.Quantity= 1;
        oppLineItem.Serial_Number_Req__c = true;
        oppLineItem.Hardware_Stock_Status__c= 'In Stock';
        oppLineItem.BatchID__c = 'xyxhkhfkjdfh';
        oppLineItem.Product_Sales_Type__c = 'One-off Product';
        oppLineItem.Product_Start_Date__c = System.today();
        oppLineItem.Product_End_Date__c = System.today();
        oppLineItem.TotalPrice = pbe.UnitPrice;
        insert oppLineItem;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getOpenHardwareOpportunities';
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetOpenHardwareOpportunities.getOpenHardwareOpportunities();
        Test.stopTest();
    }
}