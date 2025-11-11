@isTest
private class CommunityHelperTest {
	
	@testSetup
	static void setupData(){
				Account dist = buildDistributor('Test Distributor','Quoted',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId(),'United Kingdom','Event');
		insert dist;

		Account acc = buildAcc('Test Acc','Quoted','Small',8,dist.Id,'Banks','United Kingdom','Event');
		insert acc;

		Contact con = buildContact('Test','CSO','test@email.com','123456789',Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId(),acc.Id);
		insert con;

		Ship__c ship = buildShip('Test Ship',acc.Id,con.Id,'9400942','351218000','3FKT');
		insert ship;

	}

	@isTest static void test_fetchRecords_positive() {

		Test.startTest();
			List<SObject> accList = (List<Account>)CommunityHelper.fetchRecords('Account', new List<String>{'Name'},'Test');
		Test.stopTest();

		// assert we grabbed our inserted accounts
		System.assertNotEquals(null,accList);
		System.assertNotEquals(0,accList.size());
		System.assertEquals(2,accList.size());

	}

	@isTest static void test_getSObjectType(){
		// mocking community url
		String url = 'www.someinstance.salesforce.com/somepath1/somepath2/somepath3/Account/someotherpath';
		String sobj;

		Test.startTest();
			sobj = CommunityHelper.getSObjectType(url);
		Test.stopTest();

		System.assertNotEquals(null, sobj);
		System.assertEquals('Account',sobj);
	}

	// private helpers

	private static Account buildDistributor(String name, String accStatus, Id recordTypeId, String billingCountry, String leadSource){
		Account acc = new Account(
			Name = name,
			Account_Status__c = accStatus,
			RecordTypeId = recordTypeId,
			BillingCountry = billingCountry,
			Lead_Source__c = leadSource
			);
		return acc;
	}

	private static Account buildAcc(String name, String accStatus, String accType, Integer fleetSize, Id distributor, String sector, String billingCountry, String leadSource){
		Account acc = new Account(
			Name = name,
			Account_Status__c = accStatus,
			Account_Type__c = accType,
			Fleet_Size__c = fleetSize,
			Distributor__c = distributor,
			Sector__c = sector,
			BillingCountry = billingCountry,
			Lead_Source__c = leadSource
			);
		return acc;
	}

	private static Contact buildContact(String firstName,String lastName, String email,String phone, Id recordTypeId, Id accId){
		Contact con = new Contact(
			FirstName = firstName,
			LastName = lastName,
			Email = email,
			Phone = phone,
			RecordTypeId = recordTypeId,
			AccountId = accId
			);
		return con;
	}

	private static Ship__c buildShip(String name, Id company, String primaryCSO, String imoNr, String mmsi, String callSign){
		Ship__c ship = new Ship__c(
			Name = name,
			Company__c = company,
			Primary_CSO_Name__c = primaryCSO,
			IMO_Number__c = imoNr,
			MMSI__c = mmsi,
			Call_Sign__c = callSign
			);
		return ship;
	}

	public static Case buildCase(String status, String origin, String description){
		Case c = new Case(
			Status = status,
			Origin = origin,
			Description = description
			);
		return c;
	}
	
}