@isTest
public class NDC_IMO_SearchControllerTest {
    /*@testSetup static void testUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
    }*/
    
    
	static testMethod void testGetCallout() {
        User u = [Select Id from user limit 1];
        System.runAs(u){
            LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '1123121', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        List<LRIT_CTR_Request__c> resql = new List<LRIT_CTR_Request__c>();
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
            Delivery_Option__c = 'Standard Delivery',
            Status__c = 'Completed'
        );
        insert request;
		
		List<ConformanceTestReport__c> conl = new List<ConformanceTestReport__c>();
		ConformanceTestReport__c report = new ConformanceTestReport__c(
	        CTRRequestRecordNumber__c = request.Id,
            CTRStatus__c = 'Valid',
            IssuedDate__c = Date.today(),
            Link__c = 'https://google.co.uk'
        );
        conl.add(report);
        insert conl;
            Test.startTest();
        NDC_IMO_SearchController ndc_imo = new NDC_IMO_SearchController();
        ndc_imo.searchKey = '1123121';
        ndc_imo.link = conl[0].Link__c;
        ndc_imo.showlink = true;
        Test.setMock(HttpCalloutMock.class, new NDC_IMO_SearchControllerMock());  
        ndc_imo.searchIMO();
        ndc_imo.searchKey = request.IMO__c;
        ndc_imo.clear();
        //new NDC_IMO_SearchController().getGnssData();
        ndc_imo.assignValues(new NDC_IMO_SearchController.MDIResponceWrapper(), new NDC_IMO_SearchController.MDIGNSSResponceWrapper());
        Test.stopTest();
        }
        
    }
    
    static testMethod void testGetCallout2() {
        Test.setMock(HttpCalloutMock.class, new NDC_IMO_SearchControllerMock());
        new NDC_IMO_SearchController().getGnssData();
    }
    
    static testMethod void testGetCallout3() {
        User u = [Select Id from user limit 1];
        System.runAs(u){
            LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '1123121', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        List<LRIT_CTR_Request__c> resql = new List<LRIT_CTR_Request__c>();
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
            Delivery_Option__c = 'Standard Delivery',
            Status__c = 'Completed'
        );
        insert request;
		
		List<ConformanceTestReport__c> conl = new List<ConformanceTestReport__c>();
		ConformanceTestReport__c report = new ConformanceTestReport__c(
	        CTRRequestRecordNumber__c = request.Id,
            CTRStatus__c = 'Valid',
            IssuedDate__c = Date.today(),
            Link__c = 'https://google.co.uk'
        );
        conl.add(report);
        insert conl;
            Test.startTest();
        NDC_IMO_SearchController ndc_imo = new NDC_IMO_SearchController();
        //ndc_imo.searchKey = '1123121';
        ndc_imo.link = conl[0].Link__c;
        ndc_imo.showlink = true;
        Test.setMock(HttpCalloutMock.class, new NDC_IMO_SearchControllerMock());  
        ndc_imo.searchIMO();
        ndc_imo.searchKey = request.IMO__c;
        ndc_imo.clear();
        //new NDC_IMO_SearchController().getGnssData();
        ndc_imo.assignValues(new NDC_IMO_SearchController.MDIResponceWrapper(), new NDC_IMO_SearchController.MDIGNSSResponceWrapper());
        Test.stopTest();
        }
        
    }
    
    static testMethod void testGetCallout4() {
        User u = [Select Id from user limit 1];
        System.runAs(u){
            LRIT_Conformance_Tests__c conformance = new LRIT_Conformance_Tests__c(
            Pole_Star_LRIT_Test_Number__c = '0001',
            Flag__c = 'UK', 
            Gross_Tonnage__c = '10000', 
            IMO_Number__c = '1123121', 
            MMSI__c = '4432432', 
            Model__c = 'IKFDM1110', 
            Port_of_Registry__c = '2213321',
            Vessel_Name__c = 'Boaty McBoatface'
        );
        insert conformance;

        List<LRIT_CTR_Request__c> resql = new List<LRIT_CTR_Request__c>();
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
            Vessel_Flag__c = 'Albania - ALB',
            Delivery_Option__c = 'Standard Delivery',
            Status__c = 'Completed'
        );
        insert request;
		
		List<ConformanceTestReport__c> conl = new List<ConformanceTestReport__c>();
		ConformanceTestReport__c report = new ConformanceTestReport__c(
	        CTRRequestRecordNumber__c = request.Id,
            CTRStatus__c = 'Valid',
            IssuedDate__c = Date.today(),
            Link__c = 'https://google.co.uk'
        );
        conl.add(report);
        insert conl;
            Test.startTest();
        NDC_IMO_SearchController ndc_imo = new NDC_IMO_SearchController();
        ndc_imo.searchKey = '1123121';
        ndc_imo.link = conl[0].Link__c;
        ndc_imo.showlink = true;
        Test.setMock(HttpCalloutMock.class, new NDC_IMO_SearchControllerMock());  
        ndc_imo.searchIMO();
        ndc_imo.searchKey = request.IMO__c;
        ndc_imo.clear();
        //new NDC_IMO_SearchController().getGnssData();
        ndc_imo.assignValues(new NDC_IMO_SearchController.MDIResponceWrapper(), new NDC_IMO_SearchController.MDIGNSSResponceWrapper());
        Test.stopTest();
        }
        
    }
}