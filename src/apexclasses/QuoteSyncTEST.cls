@isTest
private class QuoteSyncTEST {

    static testMethod void myUnitTest() {
        
        
        //create account
        Account testAcc = new Account(Name = 'testacc', Lead_Source__c = 'Event', Account_Status__c = 'Prospect', BillingCountry = 'United Kingdom');
        Insert testAcc;
        
        //create opp
        Opportunity testOpp = new Opportunity(Name = 'testopp', StageName = 'Lead time', CloseDate = Date.Today(), Product_Type__c = 'MAT', AccountId = testAcc.Id);
        Insert testOpp;
        system.debug('testOpp' + testOpp.Id);
        
        //create quote
        Quote testQuote = new Quote(Name = 'test quote', Status = 'draft', OpportunityId = testOpp.Id);
        insert(testQuote);
        
        //edit quote status
        testQuote.status = 'Sent';
        update(testQuote);
        
        Opportunity testOppStage = [SELECT Id, StageName FROM Opportunity WHERE Id =: testQuote.OpportunityId];
        
        //asset opp stage == expected value for status
        system.assert(testOppStage.StageName == 'Quote sent');
        
        //edit quote status
        testQuote.status = 'Accepted';
        update(testQuote);
        
        testOppStage = [SELECT Id, StageName FROM Opportunity WHERE Id =: testQuote.OpportunityId];
        
        //asset opp stage == expected value for status
        system.assert(testOppStage.StageName == 'Quote Accepted');

    }
}