/**
 * @who		: Sadiq Adesanya <sadiq.adesanay@weare4c.com>
 * @when	: 04/12/2017
 * @what	: Test class for 'ShipTrigger' and 'ShipUtility'
 */
@isTest
private class ShipUtilityTest {
    /**
     * @method		: testInsertShip()
     * @description	: Test class to test the validation of the Primary_CSO_Name__c on Ship records
     * @return		: void
     * @params		: N/A
     */
    private testMethod static void testInsertShip() {
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCountry = 'United Kingdom',
            Fleet_size__c = 100,
            Account_Type__c = 'Strategic account',
            Account_Status__c = 'Commercial',
            Lead_Source__c = 'Polestarglobal.com'
        );
        
        Account testAccount1 = new Account(
            Name = 'Test Account1',
            BillingCountry = 'United Kingdom',
            Fleet_size__c = 100,
            Account_Type__c = 'Strategic account',
            Account_Status__c = 'Commercial',
            Lead_Source__c = 'Polestarglobal.com'
        );
        insert new List<Account> {testAccount1, testAccount};
        
        //Contact required to be CSO record type
        Id csoRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId();
        //Create CSO default contact, a matching contact and a non matching contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Status__c = 'Attention',
            RecordTypeId = csoRecordType
        );
        Contact testContact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1',
            AccountId = testAccount1.Id,
            Status__c = 'Attention',
            RecordTypeId = csoRecordType
        );
        Contact defaultContact = new Contact(
        	FirstName = 'CSO',
            LastName = 'TO BE ASSIGNED',
            Email = 'richard.fosu@weare4c.com',
            Phone = '+501 989-6569',
            AccountId = testAccount.Id,
            RecordTypeId = csoRecordType
        );
        
        insert new List<Contact> {testContact, testContact1, defaultContact};
        
        //Create and insert Ship record which tests the utility class and trigger
        Ship__c testShip = new Ship__c(
            Company__c = testAccount.Id,
            IMO_Number__c = '1234',
            Primary_CSO_Name__c = testContact1.Id,
            Alternate_CSO_Name__c = testContact1.Id,
            Call_Sign__c = 'Sign',
            MMSI__c = 'Test'
        );
        
        //Error message expected
        String errorMessage = 'Primary CSO does not have a relationship';
        //Insert ship record, expecting failure with provided message
        try{
            insert testShip;
        } catch (DMLException e) {
            System.debug('result: ' + e.getmessage());
            System.AssertEquals(true, e.getMessage().contains(errorMessage));
        }
    }	
}