@isTest
public class LRITCTRRevokeTest{
    @isTest
    public static void testCTRRevokeException(){
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/revokeCTR';
        req.params.put('text','test');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTRRevoke.revokeCTR();
        Test.stopTest();
    }
    
    @isTest
    public static void testCTRRevoke(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;
        
        Opportunity oppRec = [Select Id, Service_PSON__c from Opportunity where Id=:opp.Id];
        
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
        	Account__c = acc.Id,
            Opportunity__c = opp.Id,
            Delivery_Option__c = 'Standard',
            LRIT_Conformance_Test__c = conformance.Id,
            IMO_Number__c = conformance.IMO_Number__c
        );
        insert request;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/revokeCTR';
        req.params.put('text','test');
        req.requestBody = Blob.valueOf('{"CTRID": "'+request.Id+'","RevokeReason": "Exception"}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        LRITCTRRevoke.revokeCTR();
        Test.stopTest();
    }
}