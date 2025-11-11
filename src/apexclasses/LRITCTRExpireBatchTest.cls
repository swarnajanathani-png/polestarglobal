@isTest
public class LRITCTRExpireBatchTest {
    static testMethod void testLRITCTRScheduleJob() {
        Test.startTest();
			LRITCTRExpireScheduleJob scheduler = new LRITCTRExpireScheduleJob();
			scheduler.execute(null);
        Test.stopTest();
    }
    
    static testMethod void testLRITCTRBatchJob() {
        Account distributor = new Account(
        	Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event ',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            Line_of_Business__c = 'Commercial Marine',
            ShowOnPortal__c = true
        );
        insert distributor;
        Date lastDay = System.Today() - 1;
        Date lastYear = System.Today() - 400;
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
            Delivery_Option__c = 'Standard Delivery',
            LRIT_CTR_Status__c = 'Valid',
            Due_for_printing_date__c = lastYear,
            Valid_Until__c = lastDay
        );
        insert request;
        

        Test.startTest();
			LRITCTRExpireBatch batchObj = new LRITCTRExpireBatch();
			DataBase.executeBatch(batchObj);
        Test.stopTest();
    }
}