/**
*  @who    Ahmad Kansouh <Ahmad.Kansouh@weare4c.com>
*  @when   20/10/2017
*  @what   Test Class for AssignContactsToSchedule
*/

@isTest
public class AssignContactsToAccountScheduleTest {
    
    @isTest public static void testMethod1(){
        
        Account acc2 = new Account();
        acc2.Name = 'CSO2';
        acc2.BillingCountry = 'United Kingdom';
        acc2.Lead_Source__c = 'Event';
        insert acc2;
        
        Contact testContact2 = new Contact();
        testContact2.LastName = 'MR Hello Test 1';
        testContact2.AccountId = acc2.id;
        testContact2.Inactive__c = FALSE;
        testContact2.Email = 'sarah.sample@company.com';
        testContact2.Phone = '077777777777';
        testContact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId();
        insert testContact2;
        
        String uniqueUserName = 'communityUser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Community User AMP'];
        User u = new User(Alias = 'standt', Email='communityuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName, ContactId = testContact2.Id);
        
        String uniqueUserName2 = 'communityUser2' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User user = new User(Alias = 'standt', Email='communityuser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = prof.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName2);
        
        System.runAs(user){
            Account acc = new Account();
            acc.Name = 'CSO';
            acc.BillingCountry = 'United Kingdom';
            acc.Lead_Source__c = 'Event';
            insert acc;
        }
         
        System.runAs(u){
            Contact testContact = new Contact();
            testContact.FirstName = 'Hello';
            testContact.Salutation = 'Mr.';
            testContact.LastName = 'Test';
            testContact.Inactive__c = FALSE;
            testContact.Email = 'sarah.sample@company.com';
            testContact.Phone = '077777777777';
            testContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('AMP Contact Request').getRecordTypeId();
            insert testContact;
            
            Test.startTest();
            System.schedule('AssignContactsToAccountSchedule','0 0 0 3 9 ? 2022', new AssignContactsToAccountSchedule());
            Test.stopTest();
        }
        
        //Check if contacts have the account.Id assigned 
        System.assertEquals(1, [SELECT COUNT() FROM Contact WHERE Account.Name = 'CSO']); 
        
        
    }
    
}