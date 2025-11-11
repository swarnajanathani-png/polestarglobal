@isTest
public class LRITCTRValidationControllerTest {
    //Below is a method with @testsetup annotation, the name can be anything like setup(), oneTimeData(), etc.
    @testSetup static void setup() {
        // Create test data
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
            LRIT_CTR_Status__c = 'Valid',
            Currency__c = 'GBP',
            EU_Company_Name__c = 'Test Company',
            Vessel_Flag__c = 'Panama - PAN',
            Delivery_Option__c = 'Standard Delivery'
        );
        insert request;
    }
    @isTest
    static void testLRITCTRValidationController() {
        LRIT_CTR_Request__c request = [Select Id,Name from LRIT_CTR_Request__c LIMIT 1];
        Test.startTest();
        Test.setCurrentPage(Page.LRITCTRValidationPage);
        ApexPages.currentPage().getParameters().put('id',request.Id);
        Test.setMock(HttpCalloutMock.class, new LRITCTRValidationControllerMock());
        
        LRITCTRValidationController lrit = new LRITCTRValidationController();
        HttpResponse res = lrit.getAuthenticationResponse('identification');
        Test.stopTest();
      
    }
    
}