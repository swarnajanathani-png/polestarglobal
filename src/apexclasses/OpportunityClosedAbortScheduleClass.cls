global class OpportunityClosedAbortScheduleClass implements Schedulable {
    global void execute(SchedulableContext sc) {
        OpportunityClosedAbortBatchClass b = new OpportunityClosedAbortBatchClass(); 
        database.executebatch(b);
    }
}