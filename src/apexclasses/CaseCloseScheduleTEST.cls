@isTest
private class CaseCloseScheduleTEST {

    static testMethod void myUnitTest() {

            Test.startTest();
                    String CRON_EXP = '0 0 0 1 1 ? 2025';  
                    String jobId = System.schedule('testScheduledApex', CRON_EXP, new CaseCloseSchedule() );

                    CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];

                    System.assertEquals(CRON_EXP, ct.CronExpression); 
                    System.assertEquals(0, ct.TimesTriggered);
                    System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));

            Test.stopTest();
            
    }
    
    public static testMethod void testCaseCreation()
    {
    
    		Test.startTest();
    		
            final String TestCasesSR = 'TestCases';
            final Case[] testCases = (Case[]) Test.loadData(Case.sObjectType, TestCasesSR);
            
            SchedulableContext sc = null;
			CaseCloseSchedule tsc = new CaseCloseSchedule();
			tsc.execute(sc);
			
			Test.stopTest();
     }
    
    
}