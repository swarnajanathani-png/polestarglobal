@isTest
private class caseDeletionBatchTest {
    
    @isTest static void testcaseDeletion() {
    
      List<Case_Deletion_SetUp__mdt> mapcaseDeletionSetUp = [SELECT Case_Origin_Type__c, Case_Owner_Queue_Equal__c, Case_Owner_Type__c ,Subject_Contains__c,Subject_Equals__c,Subject_Starts_With__c,Supplied_Email_Equals__c,Case_Deletion_Age_In_Days__c,Case_Deletion_Before_Years__c,Subject_Does_Not_Contain__c FROM Case_Deletion_SetUp__mdt];
     
      case cs = new case();
      cs.Subject = 'test001';
      cs.SuppliedEmail= 'test@polestar.com';
      cs.origin ='email';
      cs.OwnerId='00G20000000iCbgEAE';
      // cs.Case_Owner_Type__c='Queue';
      
      insert cs;
       
     
      
        
        
      case cs1 = new case();
      cs1.Subject = 'test001';
      cs1.SuppliedEmail= 'test@polestar.com';
      cs1.origin ='Web';
      cs1.OwnerId='00G20000000iCbgEAE';
      insert cs1;
        
      case c = new case();
      c.Subject = 'By Tony';
      
      insert c;
       
      case cs01 = new case();
      cs01.Subject = 'Test';
        insert cs01;
      
      
      case cs4 = new case();
      cs4.Subject = 'test test';
     
      insert cs4;  
        
      case cs2 = new case();
      cs2.SuppliedEmail= 'test@polestar.com';
      cs2.origin ='Web';
      
      insert cs2;
        
      case cs3 = new case();
      cs3.SuppliedEmail= 'testtest@polestar.com';
      cs3.origin ='Web';
      
      insert cs3;
      case cs5 = new case();
      cs5.SuppliedEmail= 'Test@polestar.com';
      
      insert cs5; 
        
      case cs6 = new case();
      cs6.subject= 'prakashtest@polestar.com';
      insert cs6;
       
        case c10 = new case();
      c10.Subject = 'Pole Star Customer Support has received your email';
      insert c10;
     
      case c11 = new case();
      c11.Subject = 'Vessel registration';
      insert c11;
        
        
      
      test.startTest();
      caseDeletionBatch csb = new caseDeletionBatch();
      DataBase.executeBatch(csb); 
      test.stopTest();
    }
    
    
    @isTest static void testcaseDeletionsche() {
    
      List<Case_Deletion_SetUp__mdt> mapcaseDeletionSetUp = [SELECT Case_Origin_Type__c, Case_Owner_Queue_Equal__c, Case_Owner_Type__c ,Subject_Contains__c,Subject_Equals__c,Subject_Starts_With__c,Supplied_Email_Equals__c,Case_Deletion_Age_In_Days__c,Case_Deletion_Before_Years__c,Subject_Does_Not_Contain__c FROM Case_Deletion_SetUp__mdt];
     
      case cs = new case();
      cs.Subject = 'test';
      cs.SuppliedEmail= 'test@polestar.com';
      cs.origin ='email';
     
      
      insert cs;
      
      case cs1 = new case();
      cs1.Subject = 'test';
      cs1.SuppliedEmail= 'test@polestar.com';
      cs1.origin ='email';
      
      
      insert cs1;
        
      case c = new case();
      c.Subject = 'By Tony';
     
      insert c;
      
      case c0 = new case();
      c0.Subject = 'test';
      insert c0;
        
  
        
        
      case cs4 = new case();
      cs4.Subject = '234test test';
      insert cs4;  
        
      case cs2 = new case();
      cs2.SuppliedEmail= 'test@polestar.com';
      cs2.origin ='Web';
      
      insert cs2;
        
      case cs3 = new case();
      cs3.SuppliedEmail= 'testtest@polestar.com';
      cs3.origin ='Web';
      
      insert cs3;
      case cs5 = new case();
      cs5.SuppliedEmail= 'Test@polestar.com';
      
      insert cs5; 
        
      case cs6 = new case();
      cs6.subject= 'prakashtest@polestar.com';
      insert cs6;
          
        
      
      Test.StartTest();
caseDeletionBatch sh1 = new caseDeletionBatch();

String sch = '0 0 23 * * ?'; system.schedule('deletbatch test', sch, sh1); Test.stopTest();
    }
    
    @isTest static void testcaseDeletion1() {
    
      List<Case_Deletion_SetUp__mdt> mapcaseDeletionSetUp = [SELECT Case_Origin_Type__c, Case_Owner_Queue_Equal__c, Case_Owner_Type__c ,Subject_Contains__c,Subject_Equals__c,Subject_Starts_With__c,Supplied_Email_Equals__c,Case_Deletion_Age_In_Days__c,Case_Deletion_Before_Years__c,Subject_Does_Not_Contain__c FROM Case_Deletion_SetUp__mdt];
     List<Case> caseList = new List<Case>();
  
     
     case cs1 = new case();
      cs1.Subject = 'Polestar';
      
      caseList.add(cs1);
      
      case cs = new case();
      cs.Subject = 'Test';
      
      caseList.add(cs);
      
      case cs3 = new case();
      
      cs3.origin ='Web';
      
      caseList.add(cs3);
      
      case cs4 = new case();
      
      cs4.origin ='Web';
      cs4.Subject = 'Test';
      cs4.SuppliedEmail= 'Test@polestar.com';
      
      caseList.add(cs4);
      
      insert caseList;
      
        
      
      test.startTest();
      caseDeletionBatch csb = new caseDeletionBatch();
      DataBase.executeBatch(csb); 
      test.stopTest();
    }
}