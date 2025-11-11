global class LRITCTRExpireScheduleJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        LRITCTRExpireBatch b = new LRITCTRExpireBatch(); 
        database.executebatch(b);
    }
}