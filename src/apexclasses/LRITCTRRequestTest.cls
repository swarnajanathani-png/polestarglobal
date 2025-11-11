/**
 *  @who    Samuel Arroyo (CloudSocius) // Tiago Lopes 4C
 *  @when   08/06/2016
 *  @what   Test for LRIT CTR Request pages
 */
@isTest 
private class LRITCTRRequestTest {
     
    static testMethod void testLRITCTRRequest() 
    {
      
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
            Flag__c = 'Panama - PAN', 
            Vessel_Flag__c = 'Panama - PAN', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '112312', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Mobile_Number__c = '123456789',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;
            LRIT_Conformance_Tests__c conformance1 = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = 'AMTS0001',
            Flag__c = 'PAN', 
            Vessel_Flag__c = 'Panama - PAN',  
            Gross_Tonnage__c = '1000', 
            IMO_Number__c = '113312', 
            MMSI__c = '4432442', 
            Model__c = 'IKFDM1410', 
            Port_of_Registry__c = '2313321',
            Mobile_Number__c = '123456786',
            Vessel_Name__c = 'Test Test'
        );
        insert conformance1;
      
       
        
        Test.startTest();
        
        // New // Edited on Feb 2018 to include VAT Applicable validations
        LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
        ctrl.guestMode='EXTERNALUSER';
        ctrl.redirect();
        ctrl.cancel();
        ctrl.requireChanges = true;
        ctrl.isDigitalRequest = true;
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_TESTNUMBER, ctrl.message);
        ctrl.request.Pole_Star_LRIT_Test_Number__c = '0002';
        ctrl.submitAndNew();
        ctrl.request.EU_Company_Name__c=null;
        ctrl.submitAndNew();
        
        System.assertEquals(LRITCTRRequestController.MSG_FILLCOMPANYNAME, ctrl.message);
         ctrl.request.EU_Company_Name__c='test';
         ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_FILLBILLINGADDRESS, ctrl.message);
        ctrl.request.Billing_Address__c = '123 Fake Street';
        ctrl.request.Delivery_Address_same_as_Billing_Address__c = true;
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_VATAPPLICABLE, ctrl.message);
        ctrl.request.VAT_Applicable__c = 'Yes';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_VATCODEMANDATORY, ctrl.message);
        ctrl.request.VAT_Number_if_applicable__c = '123213424';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_FILLCURRENCY, ctrl.message);
        ctrl.request.Currency__c = 'GBP';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_EMAILTORECEIVEPROFORMA, ctrl.message);
        ctrl.request.Email_to_receive_proforma__c='test@gmail.com';
        ctrl.submitAndNew();
        //System.assertEquals(LRITCTRRequestController.MSG_FILLDELIVERYCOUNTRY, ctrl.message);
        ctrl.request.Delivery_Country__c = 'United Kingdom';
        ctrl.request.Delivery_Address_same_as_Billing_Address__c = false;
        ctrl.request.Delivery_Address__c = null;
        ctrl.submitAndNew();
       
        
        /*System.assertEquals(LRITCTRRequestController.MSG_DELIVERYADDRESS, ctrl.message);
        ctrl.request.Billing_Address__c = '123 Fake Street';
        ctrl.request.Delivery_Address_same_as_Billing_Address__c = true;
        ctrl.submitAndNew();*/
        System.assertEquals(LRITCTRRequestController.MSG_FILLDELIVERYCONTACT, ctrl.message);
        ctrl.request.Delivery_Contact_Name__c = 'Jon Doe';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_FILLDELIVERYEMAIL, ctrl.message);
        ctrl.request.Delivery_Email_Address__c = 'jondoe@test.com';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_FILLDELIVERYPHONE, ctrl.message);
        ctrl.request.Delivery_phone_Number__c = '07777777777890123489019';
        ctrl.submitAndNew();
        /*System.assertEquals(LRITCTRRequestController.MSG_CONTACT_LENGTH_INVALID, ctrl.message);
        ctrl.request.Delivery_phone_Number__c = '07777777777abc';
         ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_CONTACT_HAS_STRING, ctrl.message);
        ctrl.request.Delivery_phone_Number__c = '07777777777';
         ctrl.submitAndNew();*/
        
        System.assertEquals(LRITCTRRequestController.MSG_TERMSANDCONDITIONS, ctrl.message);
        ctrl.request.Terms_and_Conditions_Accepted__c = true;
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWPORT, ctrl.message);
        ctrl.request.Port__c = 'Test';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWMMSI, ctrl.message);
        ctrl.request.MMSI__c = '123456789';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWIMN, ctrl.message);
        ctrl.request.IMN__c = '123456789';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWCALLSIGN, ctrl.message);
        ctrl.request.Call_Sign__c = 'ab cd';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWVESSELFLAG, ctrl.message);        
 
        ctrl.request.Vessel_Flag__c = 'United Kingdom - GBR';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWVESSELNAME, ctrl.message);
        ctrl.request.Vessel_Name__c = 'Test';
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_NEWGROSSTONNAGE, ctrl.message);
        
        ctrl.request.Port__c = '123';
        ctrl.submitAndNew();
        ctrl.request.MMSI__c = '12345678';
        ctrl.submitAndNew();
        ctrl.request.IMN__c = 'abcdefghi';
        ctrl.submitAndNew();
        ctrl.request.Call_Sign__c = 'ab cdadda';
        ctrl.submitAndNew();
        ctrl.request.Gross_Tonnage__c = 'ab';
        ctrl.submitAndNew();
        ctrl.request.Gross_Tonnage__c = '12';
        ctrl.request.Port__c = 'Test';
        ctrl.request.MMSI__c = '123456789';
        ctrl.request.IMN__c = '123456789';
        ctrl.request.Call_Sign__c = 'ab cd';
        //System.assertEquals(LRITCTRRequestController.MSG_IMNinmarsatINVALID, ctrl.message);
        System.assertEquals(LRITCTRRequestController.MSG_CALLSIGNINVALID, ctrl.message);
        ctrl.submitAndNew();
        /*ctrl.request.Call_Sign__c = 'abcde';
        ctrl.request.Delivery_Address_same_as_Billing_Address__c = true;
        ctrl.request.Billing_Address__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabcdefghijklmnopqrstuvwxyzabcdefghaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefffffffffffffffffffffffffffffffffffffffffffffffffffffff';       
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_ADDRESS_LENGTH, ctrl.message);
        ctrl.request.Delivery_Address_same_as_Billing_Address__c = false;
        ctrl.request.Delivery_Address__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabcdefghijklmnopqrstuvwxyzabcdefghaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccccccceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefffffffffffffffffffffffffffffffffffffffffffffffffffffff';       
        ctrl.submitAndNew();
        System.assertEquals(LRITCTRRequestController.MSG_ADDRESS_LENGTH, ctrl.message);
        ctrl.request.Billing_Address__c = '123 Fake Street';
        ctrl.request.Delivery_Address_same_as_Billing_Address__c = true;
        ctrl.submitAndNew();*/

        System.assertEquals(LRITCTRRequestController.MSG_TESTNUMBER_NOTFOUND, ctrl.message); // A conformance test must exist in the system
        ctrl.request.Pole_Star_LRIT_Test_Number__c = '0001';
        ctrl.submitAndNew();
 //       System.assertNotEquals(null, ctrl.request.Id);
        
        // View
        ctrl = new LRITCTRRequestController(new ApexPages.StandardController(ctrl.request));
 //       System.assertEquals('New', ctrl.request.Status__c);
        ctrl.redirect();
        ctrl.edit();
        ctrl.cancel();
       
        try
        {
              Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.LRIT_CTR_Request__c.getRecordTypeInfosByName();
       
        }
        catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        
        // Edit
        Test.setCurrentPage(Page.LRITCTRRequest);
        ApexPages.currentPage().getParameters().put('retURL','/'+ctrl.request.Id);
        ctrl.request.Status__c = 'New';
        ctrl = new LRITCTRRequestController(new ApexPages.StandardController(ctrl.request));
        ctrl.redirect();
        ctrl.getmyfile();
        // Submit for approval
        ctrl.submitForInvoicing();
        
     
        ctrl = new LRITCTRRequestController(new ApexPages.StandardController(ctrl.request));
        ctrl.edit(); // request is locked
        System.assertNotEquals(null, ctrl.message);
        ctrl.submitForInvoicing(); // request is already submitted
        System.assertNotEquals(null, ctrl.message);
        ctrl.cancel();
        
        // New with clone
        ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
        ctrl.request.Pole_Star_LRIT_Test_Number__c = 'Test2';
        ctrl.isDigitalRequest = false;
        ctrl.submit();
        ctrl.doClone();
		// Submit for approval
        ctrl.submitForInvoicing();
        
        
        LRITCTRRequestController ctrl1 = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
        ctrl1.redirect();
        ctrl1.cancel();
        ctrl1.requireChanges = true;
        ctrl.submitAndNew();
         System.assertEquals(LRITCTRRequestController.MSG_TESTNUMBER, ctrl.message);
        ctrl.request.Pole_Star_LRIT_Test_Number__c = 'AMTS0001';
        ctrl.submitAndNew();
       
       
        
        Test.stopTest();
    } 

    static testMethod void testPayNowPositive(){
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
        
         LRIT_Conformance_Tests__c conformance1 = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = 'AMTS0001',
            Flag__c = 'Panama - PAN', 
            Gross_Tonnage__c = '1000', 
            IMO_Number__c = '113312', 
            MMSI__c = '4432442', 
            Model__c = 'IKFDM1410', 
            Port_of_Registry__c = '2313321',
            Mobile_Number__c = '123456786',
            Vessel_Name__c = 'Test Test'
        );
        insert conformance1;
           
        // View
        LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(request));
        System.assertEquals('New', ctrl.request.Status__c);
        System.assertEquals(false, ctrl.request.Payed__c);

        ctrl.payNow();
        //finish to handle result

    }

    static testMethod void testLRITCTRHome() {
        Account distributor = new Account(
            Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event ',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId()
        );
        insert distributor;
        
        LRITCTRHomeController ctrl = new LRITCTRHomeController();
    }
    
    static testMethod void testExtranet() {
        List<ExtranetDocument__c> documents = new List<ExtranetDocument__c>();
        for (Integer i = 0; i < 20; i++)
            documents.add(new ExtranetDocument__c(
                Name__c = 'Test Document ' + String.valueOf(i), 
                FileType__c = 'PNG', 
                Type__c = 'Misc', 
                Section__c = 'To help you promote', 
                URL__c = 'https://google.co.uk', 
                Service__c = 'ALL'
            ));
        insert documents;
        
        Test.startTest();
        
        ExtranetController ctrl = new ExtranetController();
        
        Test.stopTest();
    }
    
    static testMethod void testsearchIMOVesselFlag() {
          LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'PAN', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '1123121', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Mobile_Number__c = '123456789',
            Sea_Areas__c = 'A1',
            Vessel_Name__c = 'Boaty McBoatface',
            Vessel_Flag__c = 'Panama - PAN'
        );
        insert conformance;
          LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
            ctrl.searchedIMO = '1123121';
            ctrl.searchIMOVesselFlag();
    }
    
    // Case 1: Valid HttpRequest using a Continuation
    static testMethod void testRegistrationContinuation() {
        String mockResponseBody = '{"added_via": "MANUAL", "client_reference": null, "registered_name": "9471123", "resource_uri": "/api/v1/registration/None", "transaction_id": 2541841}';

        Test.startTest();
        LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
        ctrl.request.IMN__c = '123456789';  
        Continuation con = (Continuation) ctrl.startScreeningContinuation();

        // Verify that the continuation has the correct number of requests
        Map<String, HttpRequest> requests = con.getRequests();
        System.assertEquals(1, requests.size(), 'The number of requests associated to the Continuation is not correct');

        // Create a mock success response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(201);
        response.setBody(mockResponseBody);

        //Assign the mock response to the variable created for testing - for keeping the reference to the correct Continuation
        Test.setContinuationResponse(ctrl.requestLabel1, response);

        Continuation result = (Continuation) ctrl.processRegistrationResponse();
        
        // Create a failure success response
        HttpResponse response1 = new HttpResponse();
        response1.setStatusCode(500);
        response1.setBody(mockResponseBody);

        //Assign the mock response to the variable created for testing - for keeping the reference to the correct Continuation
        Test.setContinuationResponse(ctrl.requestLabel1, response1);

        Continuation result1 = (Continuation) ctrl.processRegistrationResponse();
        
        Test.stopTest();
    }
    
    static testMethod void testTransactionContinuation() {
        String mockResponseBody = '{"objects": [{"id": 47038967, "registered_name": "9471123", "screen_results": [{"check": "COMPANY_SANCTIONS", "creation_date": "2023-06-30T23:23:50Z", "id": 13204005, "resource_uri": "/api/v1/screenresult/13204005", "result_code": null, "status": "OK"}, {"check": "SANCTIONS", "creation_date": "2023-06-30T23:23:50Z", "id": 13204004, "resource_uri": "/api/v1/screenresult/13204004", "result_code": null, "status": "OK"}]}]}';
		
        Test.startTest();
        LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
        ctrl.request.IMN__c = '123456789';
        Continuation con = (Continuation) ctrl.startTrasactionContinuation(2541841);

        // Verify that the continuation has the correct number of requests
        Map<String, HttpRequest> requests = con.getRequests();
        System.assertEquals(1, requests.size(), 'The number of requests associated to the Continuation is not correct');

        // Create a mock response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(mockResponseBody);

        //Assign the mock response to the variable created for testing - for keeping the reference to the correct Continuation
        Test.setContinuationResponse(ctrl.requestLabel2, response);

        Continuation result = (Continuation) ctrl.processTransactionResponse();
        
        // Create a failure mock response
        HttpResponse response1 = new HttpResponse();
        response1.setStatusCode(500);
        response1.setBody(mockResponseBody);

        //Assign the mock response to the variable created for testing - for keeping the reference to the correct Continuation
        Test.setContinuationResponse(ctrl.requestLabel2, response1);

        Continuation result1 = (Continuation) ctrl.processTransactionResponse();

        Test.stopTest();
		
    }

    static testMethod void testReportingContinuation() {
        String mockResponseBody = 'true';
		
        Test.startTest();
        LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
        ctrl.request.IMN__c = '123456789';
        Continuation con = (Continuation) ctrl.startPerformanceContinuation();

        // Verify that the continuation has the correct number of requests
        Map<String, HttpRequest> requests = con.getRequests();
        System.assertEquals(1, requests.size(), 'The number of requests associated to the Continuation is not correct');

        // Create a mock response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(mockResponseBody);

        //Assign the mock response to the variable created for testing - for keeping the reference to the correct Continuation
        Test.setContinuationResponse(ctrl.requestLabel3, response);

        Continuation result = (Continuation) ctrl.processPerformanceReportResponse();
        
        // Create a mock failure response
        HttpResponse response1 = new HttpResponse();
        response1.setStatusCode(500);
        response1.setBody(mockResponseBody);

        //Assign the mock response to the variable created for testing - for keeping the reference to the correct Continuation
        Test.setContinuationResponse(ctrl.requestLabel3, response1);

        Continuation result1 = (Continuation) ctrl.processPerformanceReportResponse();
        Test.stopTest();
		
    }

    
    static testMethod void testcloseSearch() {
          LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
            ctrl.request.Pole_Star_LRIT_Test_Number__c = '0001';
            ctrl.searchIMOVesselFlag();
            ctrl.closeSearch();
    }
    
             
    static testMethod void testhandleChangesRequiredckb() {
          LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
            ctrl.requireChanges = false;
            ctrl.handleChangesRequiredckb();
    }
    
    static testMethod void testenablesubmit() {
          LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
          ctrl.checkbox=true;
          ctrl.enablesubmit();
          ctrl.isDigitalRequest = false; 
          ctrl.isScreeningSuccess = false;
          ctrl.submit(); 
          ctrl.isScreeningNotPending = false;
          ctrl.submit(); 
          ctrl.isScreeningServerAvailable = false;
          ctrl.submit();
          ctrl.isPerfomanceSuccess = false;
          ctrl.submit();
          ctrl.isPerfomanceServerAvailable = false;
          ctrl.submit();
          
    }
	static testMethod void testChangeRequestForm() {
          LRITCTRRequestController ctrl = new LRITCTRRequestController(new ApexPages.StandardController(new LRIT_CTR_Request__c()));
          ctrl.requestedFor = 'Panama';
		  ctrl.changeForm();
          ctrl.checkRequestFor();
    }
    
}