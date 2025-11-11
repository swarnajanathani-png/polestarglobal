@isTest
private class GetOpportunityStageTest {

    static testMethod void test() {
        Account distributor = new Account(
        	Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event ',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            ShowOnPortal__c = true
        );
        insert distributor;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = distributor.Id;
        opp.CurrencyISOCode = 'USD';
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.today();
        opp.Order_Date__c = System.today();
        opp.Type = 'Portal Conformance Test';
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
        
        Opportunity opp1 = [Select Id,Service_PSON__c from Opportunity where Id =: opp.Id ];
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getOpportunityStage';
        req.params.put('test','test');
        req.requestBody = Blob.valueOf('{\"psons\":[{\"pson\":\"'+opp1.Service_PSON__c+'\"}]}');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetOpportunityStage.getOpportunityStage();
        Test.stopTest(); 
    }
}