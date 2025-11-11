/**
* @Who Tiago Lopes - CloudSocius
* @When 4/01/17
* @What test class for ErrorLog class
**/
@isTest
private class ErrorLoggerTest {
	
	@isTest static void insertErrorLogPositive() {
		
		AWSKey__c awsc = new AWSKey__c();
		awsc.Key__c = 'wrwrwfw234234';
		awsc.Secret__c = 'asfdad356786jh';
		awsc.Name = 'salesforce';
		insert awsc;

		LRIT_Conformance_Tests__c reqtest = new LRIT_Conformance_Tests__c();
		reqtest.Pole_Star_LRIT_Test_Number__c = '12345';
		insert reqtest;

		LRIT_CTR_Request__c req = new LRIT_CTR_Request__c();
		req.Pole_Star_LRIT_Test_Number__c = '12345';
		req.LRIT_Conformance_Test__c = reqtest.Id;
		req.Currency__c = 'GBP';
		req.Delivery_Option__c = 'Standard Delivery (GBP 15.00/ USD 26.00)';
		insert req;

		LRIT_CTR_Request__c req1 = [SELECT Id, Pole_Star_LRIT_Test_Number__c, Certificate_Number__c FROM LRIT_CTR_Request__c WHERE Id = :req.Id LIMIT 1 ];


		Attachment at = new Attachment();
		at.Name = req1.Certificate_Number__c + '_' + req1.Pole_Star_LRIT_Test_Number__c + '.pdf';
		at.Body = Blob.valueof('testing stub for unit Tests');
		at.ParentId = req1.Id;
		insert at;

		System.assertEquals(at.ParentId, req1.Id);

		Test.startTest();

			String errorMsg = 'testing errorlog insert';
			ErrorLog error = new ErrorLog(at.Id, errorMsg);


		Test.stopTest();

		LRIT_CTR_Request_S3upload_Error__c err = [SELECT Id, Name, Error_message__c, LRIT_CTR_Request__c FROM LRIT_CTR_Request_S3upload_Error__c WHERE LRIT_CTR_Request__c = :req.Id LIMIT 1];
		System.assertEquals(err.Error_message__c, errorMsg );
		System.assertEquals(err.LRIT_CTR_Request__c, req.Id);
	}
	
	
}