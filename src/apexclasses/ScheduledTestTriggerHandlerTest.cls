@isTest
public class ScheduledTestTriggerHandlerTest {
    @testSetup
    static void setupData(){
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCountry = 'United Kingdom',
            Fleet_size__c = 100,
            Account_Type__c = 'Strategic account',
            Account_Status__c = 'Commercial',
            Lead_Source__c = 'Polestarglobal.com'
        );
        insert testAccount;
        
        //Contact required to be CSO record type
        Id csoRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId();
        Contact testContact = new Contact(
            FirstName = 'CSO',
            LastName = 'TO BE ASSIGNED',
            AccountId = testAccount.Id,
            Status__c = 'Attention',
            RecordTypeId = csoRecordType,
            Email = 'testEmail@gmail.com'
        );
        insert testContact;
        
        
        //Create and insert Ship record which tests the utility class and trigger
        Ship__c testShip = new Ship__c(
            Name = 'Test Ship',
            Company__c = testAccount.Id,
            IMO_Number__c = '9400942',
            Primary_CSO_Name__c = testContact.Id,
            Alternate_CSO_Name__c = testContact.Id,
            Call_Sign__c = '3FKT',
            MMSI__c = '351218000',
            Primary_CSO_Email__c = testContact.Email
        );
        insert testShip;
        
        // Create preliminary scheduled test
        Scheduled_Test__c testSchedule = new Scheduled_Test__c(
            Test_Date__c = System.today(),
            Account_Name__c = testAccount.Id,
            Ship_Name__c = testShip.Id,
            Primary_CSO_Name__c = testContact.Id
        );
        insert testSchedule;
    }
    
    @isTest static void test_onInsert_positive() {
        
        // Create scheduled test 2 days AFTER prelimiary scheduled test on setup
        Scheduled_Test__c testSchedule1 = new Scheduled_Test__c(
            Test_Date__c = System.today().addDays(2),
            Account_Name__c = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id,
            Ship_Name__c = [SELECT Id FROM Ship__c WHERE Name = 'Test Ship'].Id,
            Primary_CSO_Name__c = [SELECT Id FROM Contact WHERE LastName = 'TO BE ASSIGNED'].Id
        );
        insert testSchedule1;
        
        // Create scheduled test 2 days BEFORE prelimiary scheduled test on setup
        /*Scheduled_Test__c testSchedule2 = new Scheduled_Test__c(
            Test_Date__c = System.today().addDays(-2),
            Account_Name__c = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id,
            Ship_Name__c = [SELECT Id FROM Ship__c WHERE Name = 'Test Ship'].Id,
            Primary_CSO_Name__c = [SELECT Id FROM Contact WHERE LastName = 'TO BE ASSIGNED'].Id
        );
        insert testSchedule2;*/
        
        // Succesful inserts
        System.assertEquals(2, [SELECT COUNT() FROM Scheduled_Test__c]);
    }
    
    @isTest static void test_onInsert_negative() {
        // Create scheduled test 1 day AFTER prelimiary scheduled test on setup
        try {
            Scheduled_Test__c testSchedule1 = new Scheduled_Test__c(
                Test_Date__c = System.today().addDays(1),
                Account_Name__c = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id,
                Ship_Name__c = [SELECT Id FROM Ship__c WHERE Name = 'Test Ship'].Id,
                Primary_CSO_Name__c = [SELECT Id FROM Contact WHERE LastName = 'TO BE ASSIGNED'].Id
            );
            insert testSchedule1;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('A test has already been scheduled within 2 days of this Test Date') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        
        // Create scheduled test 1 day BEFORE prelimiary scheduled test on setup
        try {
            Scheduled_Test__c testSchedule2 = new Scheduled_Test__c(
                Test_Date__c = System.today().addDays(-1),
                Account_Name__c = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id,
                Ship_Name__c = [SELECT Id FROM Ship__c WHERE Name = 'Test Ship'].Id,
                Primary_CSO_Name__c = [SELECT Id FROM Contact WHERE LastName = 'TO BE ASSIGNED'].Id
            );
            insert testSchedule2;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('A test has already been scheduled within 2 days of this Test Date') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        // No successful inserts
        System.assertEquals(1, [SELECT COUNT() FROM Scheduled_Test__c]);
    }
}