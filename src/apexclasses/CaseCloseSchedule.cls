global class CaseCloseSchedule implements Schedulable {
	
	
	global void execute(SchedulableContext SC){
		
		List <Case> cases = [SELECT Id, Status, LastModifiedDate FROM Case WHERE LastModifiedDate != LAST_N_DAYS:30 AND (Status = 'Active' OR Status = 'New' OR Status = 'Reopened')];
		
		List<Case> casesToUpdate = new List<Case>();
		
		for(Case c: cases){
			
			c.Status = 'Closed';
				
			casesToUpdate.add(c);
			
		}
		
		update casesToUpdate; 
		
	}
	

}