/**
 *  @who    Gen Estrada <genalyn.estrada@weare4c.com>
 *  @when   23/05/2019
 *  @what   Batch that checks for all ships that whose last successful
 *          test is > 10 months and > 12 months or null
 */
global class ScheduledShipTestBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    // Query to run
    public String query;
    // Cron to run on every day, 2am
    public static String dailyCron = '0 0 2 1/1 * ? *';
    // Ten months in days
    public static final Integer tenMonths = -304;
    // Twelve months in days
    public static final Integer twelveMonths = -365;

    /**
    *  Builds Query for batch
    */
    global ScheduledShipTestBatch() {
        String tenMonthsAgo = String.valueOf(System.today().addDays(tenMonths));
        String twelveMonthsAgo = String.valueOf(System.today().addDays(twelveMonths)); 

        this.query =    'SELECT Id, Latest_Success_Date__c, No_Scheduled_Test_in_10_months__c, CreatedDate, Primary_CSO_Name__c, ' +
                        'No_Scheduled_Test_in_12_months__c, Status__c, Primary_CSO_Email__c ' +
                        'FROM Ship__c WHERE ' + 
                        '(Latest_Success_Date__c <= ' + tenMonthsAgo + 
                        ' OR Latest_Success_Date__c <= ' + twelveMonthsAgo + 
                        ' OR Latest_Success_Date__c = null) AND ' + 
                        '(No_Scheduled_Test_in_10_months__c = false OR No_Scheduled_Test_in_12_months__c = false)';

        System.debug('Query ' + query);
    }
    
    /**
    *  Batch start
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    /**
    *  Batch execute
    */
    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        ScheduledShipTestBatchHandler.processShips((List<Ship__c>) scope);
    }

    /**
    *  Schedules batch for daily run
    */
    global void execute (SchedulableContext sc) {
        Database.executeBatch (new ScheduledShipTestBatch(), 50);
    }
    
    /**
    *  Schedules batch for daily
    */
    global static String scheduleDaily(){
        ScheduledShipTestBatch sstb = new ScheduledShipTestBatch(); 
        return System.schedule('Scheduled Ship Test Batch Daily', dailyCron, sstb);
    }

    /**
    *  Batch finish
    */
    global void finish(Database.BatchableContext BC) {}
}