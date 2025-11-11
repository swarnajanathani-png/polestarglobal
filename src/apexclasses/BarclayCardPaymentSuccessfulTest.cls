@isTest
private class BarclayCardPaymentSuccessfulTest {
	
	@isTest static void testPaymentSuccessfullCTR() {
		LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '112312', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        LRIT_CTR_Request__c request = new LRIT_CTR_Request__c(
            Pole_Star_LRIT_Test_Number__c = '0002',
            Billing_Address__c = '123 Fake Street',
            Delivery_Country__c = 'United Kingdom',
            Delivery_Address_same_as_Billing_Address__c = true,
            Delivery_Contact_Name__c = 'Jon Doe',
            Delivery_Email_Address__c = 'jondoe@test.com',
            Delivery_phone_Number__c = '07777777777',
            Terms_and_Conditions_Accepted__c = true,
            LRIT_Conformance_Test__c = conformance.Id,
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;

		Test.setCurrentPage(new PageReference('Page.BCardPaymentSuccessful'));
		System.currentPageReference().getParameters().put('STATUS','5');
		System.currentPageReference().getParameters().put('DIST','polestar');
		System.currentPageReference().getParameters().put('ORDERID','testOrder12345');
		System.currentPageReference().getParameters().put('AMOUNT','2000.00');
		System.currentPageReference().getParameters().put('CURRENCY','GBP');
		System.currentPageReference().getParameters().put('CN','Test Company');
		System.currentPageReference().getParameters().put('PAYID','099875');
		System.currentPageReference().getParameters().put('TRXDATE','5/10/2020');
		System.currentPageReference().getParameters().put('RECID', request.Id);

		Test.startTest();
			BarclayCardPaymentSuccessfulController ctrl = new BarclayCardPaymentSuccessfulController();
			ctrl.createNewPayment();
		Test.stopTest();

		Credit_Card_Payment__c payment = [SELECT Name, BCard_CrossReference__c, Company_Name__c FROM Credit_Card_Payment__c LIMIT 1];
		//asserting success
		System.assertEquals(true, ctrl.isSuccess);
		System.assertNotEquals(null, ctrl.req);
		System.assertNotEquals(null, payment);
		System.assertEquals(ctrl.companyName, payment.Company_Name__c);
		System.assertEquals(ctrl.paymentId, payment.BCard_CrossReference__c);

	}
	
	@isTest static void testPaymentDeclined() {
		LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '112312', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        LRIT_CTR_Request__c request = new LRIT_CTR_Request__c(
            Pole_Star_LRIT_Test_Number__c = '0002',
            Billing_Address__c = '123 Fake Street',
            Delivery_Country__c = 'United Kingdom',
            Delivery_Address_same_as_Billing_Address__c = true,
            Delivery_Contact_Name__c = 'Jon Doe',
            Delivery_Email_Address__c = 'jondoe@test.com',
            Delivery_phone_Number__c = '07777777777',
            Terms_and_Conditions_Accepted__c = true,
            LRIT_Conformance_Test__c = conformance.Id,
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;

		Test.setCurrentPage(new PageReference('Page.BCardPaymentSuccessful'));
		System.currentPageReference().getParameters().put('STATUS','2');
		System.currentPageReference().getParameters().put('DIST','polestar');
		System.currentPageReference().getParameters().put('ORDERID','testOrder12345');
		System.currentPageReference().getParameters().put('AMOUNT','2000.00');
		System.currentPageReference().getParameters().put('CURRENCY','GBP');
		System.currentPageReference().getParameters().put('CN','Test Company');
		System.currentPageReference().getParameters().put('PAYID','099875');
		System.currentPageReference().getParameters().put('TRXDATE','5/10/2020');
		System.currentPageReference().getParameters().put('RECID', request.Id);

		Test.startTest();
			BarclayCardPaymentSuccessfulController ctrl = new BarclayCardPaymentSuccessfulController();
		Test.stopTest();

		//asserting declined
		System.assertEquals(false, ctrl.isSuccess);
		System.assertEquals(true, ctrl.isDeclined);
		System.assertEquals(null, ctrl.req);
		System.assertEquals(false,ctrl.proceedToPaymentCreation);
	}

	@isTest static void testPaymentException() {
		LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '112312', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        LRIT_CTR_Request__c request = new LRIT_CTR_Request__c(
            Pole_Star_LRIT_Test_Number__c = '0002',
            Billing_Address__c = '123 Fake Street',
            Delivery_Country__c = 'United Kingdom',
            Delivery_Address_same_as_Billing_Address__c = true,
            Delivery_Contact_Name__c = 'Jon Doe',
            Delivery_Email_Address__c = 'jondoe@test.com',
            Delivery_phone_Number__c = '07777777777',
            Terms_and_Conditions_Accepted__c = true,
            LRIT_Conformance_Test__c = conformance.Id,
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;

		Test.setCurrentPage(new PageReference('Page.BCardPaymentSuccessful'));
		System.currentPageReference().getParameters().put('STATUS','52');
		System.currentPageReference().getParameters().put('DIST','polestar');
		System.currentPageReference().getParameters().put('ORDERID','testOrder12345');
		System.currentPageReference().getParameters().put('AMOUNT','2000.00');
		System.currentPageReference().getParameters().put('CURRENCY','GBP');
		System.currentPageReference().getParameters().put('CN','Test Company');
		System.currentPageReference().getParameters().put('PAYID','099875');
		System.currentPageReference().getParameters().put('TRXDATE','5/10/2020');
		System.currentPageReference().getParameters().put('RECID', request.Id);

		Test.startTest();
			BarclayCardPaymentSuccessfulController ctrl = new BarclayCardPaymentSuccessfulController();
		Test.stopTest();

		//asserting exception
		System.assertEquals(false, ctrl.isSuccess);
		System.assertEquals(true, ctrl.isException);
		System.assertEquals(null, ctrl.req);
		System.assertEquals(false,ctrl.proceedToPaymentCreation);
	}

	@isTest static void testPaymentCanceled() {
		LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '112312', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        LRIT_CTR_Request__c request = new LRIT_CTR_Request__c(
            Pole_Star_LRIT_Test_Number__c = '0002',
            Billing_Address__c = '123 Fake Street',
            Delivery_Country__c = 'United Kingdom',
            Delivery_Address_same_as_Billing_Address__c = true,
            Delivery_Contact_Name__c = 'Jon Doe',
            Delivery_Email_Address__c = 'jondoe@test.com',
            Delivery_phone_Number__c = '07777777777',
            Terms_and_Conditions_Accepted__c = true,
            LRIT_Conformance_Test__c = conformance.Id,
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;

		Test.setCurrentPage(new PageReference('Page.BCardPaymentSuccessful'));
		System.currentPageReference().getParameters().put('STATUS','1');
		System.currentPageReference().getParameters().put('DIST','polestar');
		System.currentPageReference().getParameters().put('ORDERID','testOrder12345');
		System.currentPageReference().getParameters().put('AMOUNT','2000.00');
		System.currentPageReference().getParameters().put('CURRENCY','GBP');
		System.currentPageReference().getParameters().put('CN','Test Company');
		System.currentPageReference().getParameters().put('PAYID','099875');
		System.currentPageReference().getParameters().put('TRXDATE','5/10/2020');
		System.currentPageReference().getParameters().put('RECID', request.Id);

		Test.startTest();
			BarclayCardPaymentSuccessfulController ctrl = new BarclayCardPaymentSuccessfulController();
		Test.stopTest();

		//asserting exception
		System.assertEquals(false, ctrl.isSuccess);
		System.assertEquals(true, ctrl.isCancel);
		System.assertEquals(null, ctrl.req);
		System.assertEquals(false,ctrl.proceedToPaymentCreation);
	}
	
}