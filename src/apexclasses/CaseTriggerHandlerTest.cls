@isTest
private class CaseTriggerHandlerTest {
	
	@isTest static void test_onInsertUpdate_positive() {
		Case c = buildCase(
            'lrit non reporting',
			'New',
			'Email',
			// expected fully parsed description but no ship found
			'!!!! TEST Call !!!! --- SSAS ALERT MESSAGE --- Vessel Name:Test Ship \r MMSI:351218000 IMN:435121811 IMO:9400942 Call Signal:3FKT SSAS TEST MSG FOR RADIO SURVEY. PLS ACK FOR RECORD PURPOSE LAT:14:26.04N LON:120:30.29E Time:22/08/2017 10:28:24 (UTC) COURSE: 230 deg SPEED: 00 kt Shani Naik Professional Service Delivery Consultant Mobile: +44 (0)7500 918753 Address: 2nd Floor Fountain House Fenchurch Street, London, Greater London, EC3M 5DJ Website: www.weare4c.com Email: Shani.naik@weare4c.com We build customer companies -- Tiago Lopes Salesforce Developer'
		);

		Test.startTest();
			insert c;
		Test.stopTest();

		c = [SELECT Id, Location__Latitude__s, SSAS_Email_Parsing_Notes_New__c, Verification_Required__c FROM Case WHERE Id = :c.Id];

		System.debug('case ### ' + c);
		// quickly assert on insert triger parsing util worked
		System.assertEquals(false, c.Verification_Required__c);
		// assert onUpdate trigger to fill in Location field from parsed coordinates worked
		//System.assertNotEquals(null,c.Location__Latitude__s);
	}

	// private helpers

	public static Case buildCase(String subject,String status, String origin, String description){
		Case c = new Case(
            Subject = subject,
			Status = status,
			Origin = origin,
			Description = description
			);
		return c;
	}

	
}