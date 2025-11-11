@isTest
private class assetInsertControllerTEST {

    static testMethod void myUnitTest() {
        
        //create account
        Account testAcc = new Account(Name = 'testacc', Lead_Source__c = 'Event', Account_Status__c = 'Prospect', BillingCountry = 'United Kingdom');
        Insert testAcc;
        
        system.debug('testAcc' + testAcc.Id);
        
        //create child product info records
        Product_Information__c testProdInfo = new Product_Information__c(Account__c = testAcc.Id, CAC_Code__c = 'test1234');
        Insert testProdInfo;
        
        Pole_Star_Asset__c testAsset = new Pole_Star_Asset__c(Account_Code__c = '\"test1234\"', Registration_Date__c = '\"1330095600\"', Deactivation_Date__c = '\"1330095600\"', Deactivation_Reason__c = '\"test\"', Tariff_Code__c = '\"test\"',Status__c = '\"test\"', Package_Code__c = '\"test\"', Model__c = '\"test\"', Make__c = '\"test\"', IMO_Number__c = '\"test\"', Communicator_Type__c = '\"test\"', Communicator_Key__c = '\"test\"', Asset_Name__c = '\"test\"', Name = '\"test\"');
        
        Insert testAsset;
        
        /**system.assert(testAsset.Account__r.Id == testAcc.Id); 
        system.assert(testAsset.Product_Information__r.Id == testProdInfo.Id); 
        **/
        
    }
}