@isTest
public class OpportunityClosedAbortBatchTest {
    static testMethod void testOpportunityClosedAbortSchJob() {
        Test.startTest();
			OpportunityClosedAbortScheduleClass scheduler = new OpportunityClosedAbortScheduleClass();
			scheduler.execute(null);
        Test.stopTest();
    }
    
    static testMethod void testOpportunityClosedAbortBatchJob() {
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
        opp.Name = 'Test';
        opp.AccountId = distributor.Id;
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;     

        Test.startTest();
			OpportunityClosedAbortBatchClass batchObj = new OpportunityClosedAbortBatchClass();
			DataBase.executeBatch(batchObj);
        Test.stopTest();
    }
}