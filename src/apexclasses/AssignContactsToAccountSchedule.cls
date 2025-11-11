/**
*  @who    Ahmad Kansouh <Ahmad.Kansouh@weare4c.com>
*  @when   18/10/2017
*  @what   Schedule to assign contacts without an accountId to an Account 
*/
global class AssignContactsToAccountSchedule implements Schedulable{
    
    global void execute(SchedulableContext SC){
        
        List<Account> accountOwnerId = new List<Account>();
        List<RecordType> recordTypeIds = new List<RecordType>();
        
        //Qurerying contact fields 
        List<Contact> contactsWithoutAccount = [SELECT Id, AccountId FROM Contact WHERE RecordType.Name = 'AMP Contact Request' AND Account.Id = Null];
        accountOwnerId = [SELECT OwnerId FROM Account WHERE Name = 'CSO'];
        recordTypeIds = [SELECT Id FROM RecordType WHERE Name = 'CSO'];
        
        //Before mapping fields, check if contacts exist without an account
        String className = 'AssignContactsToAccountSchedule';
        Boolean isClassScheduled = isApexClassScheduled(className);
        if(contactsWithoutAccount.size() > 0 && accountOwnerId.size() > 0 && recordTypeIds.size() > 0 && isClassScheduled == FALSE){            
            assignContactsToAccount(contactsWithoutAccount, accountOwnerId, recordTypeIds);
        }
        else{
            System.debug('ERROR please check that all values are available');
        }
        
        // Calculate next job schedule
        Integer timeWindowInMinutes = 5;
        Datetime nextScheduleTime = Datetime.now().addMinutes(timeWindowInMinutes);
        String second = String.valueOf(nextScheduleTime.second());
        String minute = String.valueOf(nextScheduleTime.minute());        
        String hour = String.valueOf(nextScheduleTime.hour());
        String cronvalue = second + ' ' + minute + ' ' + hour + ' * * ?';
        String jobName = 'AssignContactsToAccountSchedule ' + nextScheduleTime.format('HH:mm');
        
        // Schedule next job and abort current one
        AssignContactsToAccountSchedule sched = new AssignContactsToAccountSchedule();
        System.schedule(jobName, cronvalue, sched);
        System.abortJob(sc.getTriggerId());
    }
    
    public void assignContactsToAccount(List<Contact> contactsWithoutAccount, List<Account> accountOwnerId, List<RecordType> recordTypeIds){
        String accountId = accountOwnerId.get(0).Id;
        String recordTypeId = recordTypeIds.get(0).Id;
        String OwnerId = accountOwnerId.get(0).OwnerId;
        List<Contact> contactsWithAccount = new List<Contact> ();
        
        for (Contact contact : contactsWithoutAccount){
            contact.OwnerId = OwnerId;
            contact.AccountId = accountId;
            contact.RecordTypeId = recordTypeId;
            contactsWithAccount.add(contact);
        } 
        
        Database.SaveResult[] saveResult = Database.update(contactsWithAccount, false);
        for(Database.SaveResult sr : saveResult){
            if(sr.isSuccess()){
                System.debug('Update was successful');
            }
            else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('ERROR ' + err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }
    }
        
    // Check whether or not there is a scheduled job
    public static Boolean isApexClassScheduled(String className) {
        
        /* Check to see if there is already a queued callout */
        Set<String> discardedStatus = new Set<String> {'Aborted','Completed','Failed','Queued'};
            
            // Get a list of queued jobs, where the class running is this class
            List<AsyncApexJob> pendingJobs = [
                SELECT Id, Status, ApexClass.Name, CompletedDate FROM AsyncApexJob 
                WHERE ApexClass.Name = :className AND Status NOT IN :discardedStatus ORDER BY CompletedDate ASC LIMIT 1
            ];
        
        return Test.isRunningTest()?false:!pendingJobs.isEmpty();
    }
    
}