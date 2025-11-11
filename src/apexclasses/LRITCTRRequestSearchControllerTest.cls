@isTest
private class LRITCTRRequestSearchControllerTest {
	
	@isTest static void test_payNowPositive() {
		BCard_settings__c settings = new BCard_settings__c(
            Test_form_URL__c = 'https://mdepayments.epdq.co.uk/ncol/test/orderstandard.asp',
            PSPID_GBP__c = 'polestarglobaltest',
            SHA1Passphrase__c = 'Cloudsociustest1!'
        );
        insert settings;

        Account distributor = new Account(
            Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            ShowOnPortal__c = true
        );
        insert distributor;
        
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
        //getting Name
        request = [SELECT Name FROM LRIT_CTR_Request__c WHERE Id = :request.Id LIMIT 1];

        Invoices__c invoice = new Invoices__c(
        	Amount__c = 1500,
        	Currency__c = 'GBP',
        	EU_Company_Name__c = 'Test Company',
        	Delivery_Email_Address__c = 'someemail@email.com',
        	Delivery_phone_Number__c = '1212121212',
        	Billing_Address__c = '123 Fake Street'
        	);
        insert invoice;
        invoice = [SELECT Name FROM Invoices__c WHERE Id = :invoice.Id LIMIT 1];
        
        // testing ctrRequest
        LRITCTRRequestSearchController ctrl = new LRITCTRRequestSearchController();
        ctrl.captchaResponse = 'testCaptchaString';
        ctrl.verifyCaptcha();
        ctrl.ctrNumber = request.Name;
        ctrl.captchaVerified = true;
        ctrl.searchRecords();
        System.assertNotEquals(null, ctrl.results);
        System.assertNotEquals(0, ctrl.results.size());

        //testing invoice
        ctrl.results.clear();
        ctrl.ctrNumber = null;
        ctrl.invNumber = invoice.Name;
        ctrl.searched = false;
        ctrl.searchRecords();
        System.assertNotEquals(null, ctrl.results);
        System.assertNotEquals(0, ctrl.results.size());

        Test.startTest();
        	ctrl.payNow();
        Test.stopTest();
        //To finish
	}
	
}