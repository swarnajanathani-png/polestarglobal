@isTest
private class LRITUSACTROpportunityTest {

    static testMethod void test() {
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
        List<String> ctIds = new List<String>();
        ctIds.add(conformance.Id);
        LRITUSACTROpportunity.createUSACTROpportunity(ctIds);
    }

}