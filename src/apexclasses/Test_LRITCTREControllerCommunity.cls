/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Test_LRITCTREControllerCommunity {

    static testMethod void myUnitTest() {
        
        LRIT_CTR_Request__c obj = new LRIT_CTR_Request__c();
                
        obj.Pole_Star_LRIT_Test_Number__c = '01ert';
        obj.Vessel_Flag__c = 'test';
        obj.Vessel_Name__c = 'test';
        obj.IMO_Number__c = '1321';
        obj.Equipment_Part_of_the_GDMSS__c = 'Yes';
        obj.Equipment_Part_of_the_SSAS__c = 'No';
        obj.Currency__c = 'GBP'; 
        obj.Delivery_Option__c = 'test';
        
        //insert obj;
       
        ApexPages.StandardController controller = new ApexPages.StandardController(obj); 
        LRITCTREControllerCommunity lt = new LRITCTREControllerCommunity(controller);
        
        lt.LRITObj = obj;
        lt.chekedVal2 = true;
        lt.chekedVal = true;
        lt.saveLRITRecord();
        
        lt.cancelIt();
        obj.Port__c  = 'test';
        lt.saveLRITRecord();
        
        obj.MMSI__c = 'test';
        lt.saveLRITRecord();
         
         obj.IMN__c = 'test';
        lt.saveLRITRecord();
        
        obj.Call_Sign__c = 'test';
        lt.saveLRITRecord();
        
        obj.Pole_Star_LRIT_Test_Number__c = 'test';
        lt.saveLRITRecord();
         
         
         
         obj.Vessel_Flag__c= 'test';
        lt.saveLRITRecord();
        
        obj.Vessel_Name__c= 'test';
        lt.saveLRITRecord();
        
        obj.IMO_Number__c= 'test';
        lt.saveLRITRecord();
        
        obj.Equipment_Part_of_the_GDMSS__c= 'test';
        lt.saveLRITRecord();
        
        obj.Equipment_Part_of_the_SSAS__c= 'test';
        lt.saveLRITRecord();
       
    }
    
    
    static testMethod void myUnitTest22() {
        
        LRIT_CTR_Request__c obj = new LRIT_CTR_Request__c();
                
        obj.Pole_Star_LRIT_Test_Number__c = '01ert';
        obj.Vessel_Flag__c = 'test';
        obj.Vessel_Name__c = 'test';
        obj.IMO_Number__c = '1321';
        obj.Equipment_Part_of_the_GDMSS__c = 'Yes';
        obj.Equipment_Part_of_the_SSAS__c = 'No';
        obj.Currency__c = 'GBP'; 
        obj.Delivery_Option__c = 'test';
        
        //insert obj;
       
        ApexPages.StandardController controller = new ApexPages.StandardController(obj); 
        LRITCTREControllerCommunity lt = new LRITCTREControllerCommunity(controller);
        
        lt.LRITObj = obj;
        lt.chekedVal2 = false;
        lt.chekedVal = true;
        lt.saveAndNewLRITRecord();
        lt.Rendering();
        lt.cancelIt();
       
        
    }
    
    static testMethod void myUnitTest223() {
        
        Feedback__c obj = new Feedback__c();
        obj.Overall_Experience_Score__c = 'test';
       
        FeedbackFormController lt = new FeedbackFormController();
        
        lt.AccountManagVal = 'test';
        lt.serviceteamVal = 'test';
        lt.PoleStarVal = 'test';
        lt.ProductSatisfactionVal = 'test';
        lt.RecLikelyVal = 'test';
        lt.RecPolstarVal = 'test';
        lt.feebackObj = obj;
        
        lt.saveFeedbackRec();
        
        lt.CancelRec();
       
        
    }
    
    
}