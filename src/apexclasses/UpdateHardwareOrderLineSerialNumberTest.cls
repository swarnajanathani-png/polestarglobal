@isTest
public class UpdateHardwareOrderLineSerialNumberTest {
	@isTest
    public static void testOpportunitySerialNumberUpdateCallException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/updateHardwareOrderLineSerialNumber';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateHardwareOrderLineSerialNumber.updateHardwareOrderLineSerialNumber();
        Test.stopTest();
    }
    
    @isTest
    public static void testOpportunitySerialNumberUpdate(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.CurrencyIsoCode = 'USD';
        opp.Name = 'Test';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;
        
        Opportunity oppRec = [Select Id, Service_PSON__c from Opportunity where Id=:opp.Id];
        
              
        Product2 p = new Product2();
        p.Name = 'Hardware Product';
        p.Family = 'Hardware';
        p.SAP_Item_Code__c = 'HW00000183AS';
        insert p;
		
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = p.Id;
        pbe.CurrencyIsoCode = 'USD';
        pbe.UnitPrice = 175;
        pbe.Pricebook2Id = '01s200000000BIgAAM';
        pbe.IsActive = true;
        insert pbe; 
        
		
        
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
        req.requestURI = '/services/apexrest/updateHardwareOrderLineSerialNumber';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"Source": "Self Service Portal","OpportunityOrderLine" : {"OrderlineId":"'+oppLineItem.Id+'","SerialNumber":"12345"}}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        UpdateHardwareOrderLineSerialNumber.updateHardwareOrderLineSerialNumber();
        Test.stopTest();
    }
}