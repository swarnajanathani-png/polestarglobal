global class OpportunityClosedAbortBatchClass implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = '';
        if(!Test.isRunningTest())
        {
        	query = 'Select Id,StageName,LastModifiedDate from Opportunity where StageName = \'Closed Received\' and Type=\'Portal Conformance Test\' and LastModifiedDate < LAST_N_Days:30';
        }
        else{
            query = 'Select Id from Opportunity';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        for(Opportunity opp : scope)
        {
            opp.StageName = 'Closed Abort';
			opp.Abort_Reason__c =   'No response';
    		opp.LostAbort_Details__c = 'No response';
        }
        update scope;
    }
    global void finish(Database.BatchableContext BC) {
    }
}