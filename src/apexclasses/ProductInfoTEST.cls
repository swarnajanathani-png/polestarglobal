@isTest
private class ProductInfoTEST {

    static testMethod void myUnitTest() {
        
        
        //create account
        Account testAcc = new Account(Name = 'testacc', Lead_Source__c = 'Event', Account_Status__c = 'Prospect', BillingCountry = 'United Kingdom');
        Insert testAcc;
        
        system.debug('testAcc' + testAcc.Id);
        
        //create child product info records
        Product_Information__c testProdInfo = new Product_Information__c(Account__c = testAcc.Id);
        Insert testProdInfo;
        
        system.debug('testProdInfo' +testProdInfo.Id); 
        
        //create opp
        Opportunity testOpp = new Opportunity(Name = 'testopp', StageName = 'Lead time', CloseDate = Date.Today(), Product_Type__c = 'MAT', AccountId = testAcc.Id);
        Insert testOpp;
        system.debug('testOpp' + testOpp.Id);
        
        //assert opp prod info record count == no. of prod info records above
        Opportunity_Product_Information__c oppProdInfo = [SELECT Id, Record_Type_Name__c, Opportunity__c, Product_Information__c FROM Opportunity_Product_Information__c WHERE Opportunity__c =: testOpp.Id];
        
        system.assert(oppProdInfo.Record_Type_Name__c == testOpp.Product_Type__c);
        
        testOpp.Name = 'testoppUpdate';
        update(testOpp);
        
        testOpp.Product_Type__c = 'SSAS';
        update(testOpp);
        
        delete(testProdInfo);
        
        testOpp.Product_Type__c = '';
        update(testOpp);
        
        
    }
    
}