@isTest
private class GetODSOpportunitiesTest {

    static testMethod void test() {
        Account distributor = new Account(
        	Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event ',
            Line_of_Business__c = 'Commercial Marine',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            ShowOnPortal__c = true
        );
        insert distributor;
        
        Opportunity opp = new Opportunity(
        	Name = 'Test',
            StageName = 'Closed Won', 
            CloseDate = System.today(), 
            AccountId = distributor.Id,
            Product_Type__c = 'Ondemand Screening',
            Type = 'Portal Ondemand Screening'
        );
        insert opp;
        
        // Initialize Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getODSOpportunities';
        req.params.put('customerid',distributor.Id);
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        GetODSOpportunities.getODSOpportunities();
        Test.stopTest(); 
    }
}