// Gen Estrada @ 4C
public with sharing class ScheduleTestTriggerHandler {
    private static ScheduleTestTriggerHandler instance;
    
    private ScheduleTestTriggerHandler() {}
    
    public static ScheduleTestTriggerHandler getInstance(){
        if(instance == null){
            instance = new ScheduleTestTriggerHandler();
        }
        return instance;
    }
    
    public void handleOnBeforeInsert(List<Scheduled_Test__c> triggerNew){
        Map<Id, Set<Scheduled_Test__c>> shipIdListScheduledTest = new Map<Id, Set<Scheduled_Test__c>>();
        
        // Get new scheduled tests
        for(Scheduled_Test__c newST : triggerNew) {
            if(!shipIdListScheduledTest.containsKey(newST.Ship_Name__c)){
                shipIdListScheduledTest.put(newST.Ship_Name__c, new Set<Scheduled_Test__c>{newST});
            } else {
                shipIdListScheduledTest.get(newST.Ship_Name__c).add(newST);
            }
        }
        
        // Get existing scheduled tests
        for(Scheduled_Test__c exST : [SELECT Ship_Name__c, Status_Formula__c, Test_Date__c  FROM Scheduled_Test__c WHERE Ship_Name__c IN : shipIdListScheduledTest.keySet()]){
            if(!shipIdListScheduledTest.containsKey(exST.Ship_Name__c) && exST.Status_Formula__c != 'Cancelled'){
                shipIdListScheduledTest.put(exST.Ship_Name__c, new Set<Scheduled_Test__c>{exST});
            } else if(exST.Status_Formula__c != 'Cancelled'){
                shipIdListScheduledTest.get(exST.Ship_Name__c).add(exST);
            }
        }
        
        // Do validation
        for(Scheduled_Test__c newST : triggerNew) {
            for(Scheduled_Test__c st : shipIdListScheduledTest.get(newST.Ship_Name__c)){
                if(st != newST && isWithinTwoDays(st.Test_Date__c, newST.Test_Date__c)){
                    newST.addError('A test has already been scheduled within 2 days of this Test Date');
                }
            }
        }
    }
    
    private static Boolean isWithinTwoDays(Date oldDate, Date newDate){
        return oldDate >= newDate.addDays(-1) && oldDate <= newDate.addDays(1); 
    }
}