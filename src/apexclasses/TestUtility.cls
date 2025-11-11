@isTest
global with sharing class TestUtility {
	global static Account createAccount(String accountName, Boolean insertRecord){
		Account testAccount = new Account(
            Name = accountName,
            BillingCountry = 'United Kingdom',
            Fleet_size__c = 100,
            Account_Type__c = 'Strategic account',
            Account_Status__c = 'Commercial',
            Lead_Source__c = 'Polestarglobal.com'
        );
        if(insertRecord){
        	insert testAccount;
        }
        
        return testAccount;
	}

	global static Contact createCSOContact(String lastName, Id accountId, Boolean insertRecord){
		// CSO record type
        Id csoRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId();
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = accountId,
            Status__c = 'Attention',
            RecordTypeId = csoRecordType,
            Email = 'test@test.com'
        );
        if(insertRecord){
        	insert testContact;
    	}
        return testContact;
	}

	global static Contact createDefaultContact(Boolean insertRecord){
		// Create default contact
		Id csoRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId();
		Contact defaultContact = new Contact(
        	FirstName = 'CSO',
            LastName = 'TO BE ASSIGNED',
            Email = 'gerclaud.mola@weare4c.com',
            Phone = '+501 989-6569',
            RecordTypeId = csoRecordType
        );

		if(insertRecord){
        	insert defaultContact;
    	}
        return defaultContact;

	}

	global static Ship__c createShip(String shipName, Id accountId, Id contactId, String imoNumber, Boolean insertRecord){
		Ship__c testShip = new Ship__c(
            Name = shipName,
            Company__c = accountId,
            IMO_Number__c = imoNumber,
            Primary_CSO_Name__c = contactId,
            Call_Sign__c = 'Sign',
            MMSI__c = 'Test'
        );
        if(insertRecord){
        	insert testShip;
        }
        return testShip;
	}
}