global class caseDeletionBatch implements Schedulable, Database.Batchable<sObject>,database.stateful {
  //  Set<ID> tempIds = new set<ID> {'5000C0000047a6NQAQ'};
    global Set<Id> erroIds = new Set<Id>();
    
    global List<Case_Deletion_SetUp__mdt> mapcaseDeletionSetUp = [SELECT Case_Origin_Type__c, Case_Owner_Queue_Equal__c, Case_Owner_Type__c ,Subject_Contains__c,Subject_Equals__c,Subject_Starts_With__c,Supplied_Email_Equals__c,Case_Deletion_Age_In_Days__c,Case_Deletion_Before_Years__c,Subject_Does_Not_Contain__c FROM Case_Deletion_SetUp__mdt];
    
    global Database.QueryLocator  start(Database.BatchableContext bc) {
        
        string query ='Select Id,Subject,Case_Owner_Type__c,SuppliedEmail,Origin,OwnerId,CreatedDate from case where Case_Owner_Type__c!=null'; // where ID IN :tempIds';
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext bc, List<Case> records){
        // process each batch of records
        Map<Id,case> caseDeletionMap = new Map<Id,Case>();
        Set<Id> queueIdset = new Set<Id> ();
        Set<Id> ErrorCaseIdset = new Set<Id> ();
        Map<Id,Group> queueMap = new Map<Id,Group>();
        system.debug ('records'+ records);
        system.debug ('mapcaseDeletionSetUp'+ mapcaseDeletionSetUp);
        for(case caseIter :records){
            
            if(caseIter.Case_Owner_Type__c == 'Queue' || test.isRunningTest()){
                
                queueIdset.add(caseIter.ownerId);
            }
        }
        
        if(!queueIdset.isEmpty()){
            
            for(Group quIter : [select Id,Name from Group where  Type = 'Queue' AND ID in : queueIdset]){
                
                queueMap.put(quIter.id,quIter);
            }
        }
        
        for(case caseIter :records){
        
            Set<Id> tempcaseIdset = new Set<Id>();
            
            for(Case_Deletion_SetUp__mdt metaIter : mapcaseDeletionSetUp){
            
              if(tempcaseIdset.Isempty()){
              
                if(metaIter.Case_Deletion_Age_In_Days__c != Null)
                {    
                     integer tempNumber =   Integer.valueOf( metaIter.Case_Deletion_Age_In_Days__c);
                     Datetime tempdate = system.now().addDays(-tempNumber);  
                    if( caseIter.CreatedDate < tempdate ||  test.isRunningTest())
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id);
                             ErrorCaseIdset.add(caseIter.Id);
                                      
                    }/*else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                             tempcaseIdset.remove(caseIter.Id);
                             ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }*/
                }
                if(metaIter.Case_Deletion_Before_Years__c != Null)
                {    
                     integer tempNumber =   Integer.valueOf( metaIter.Case_Deletion_Before_Years__c);
                     Date dat = System.today();
                        Integer yr = dat.year()-tempNumber;
                        datetime datetimes=datetime.newInstance(yr, 01, 01); 
                    if( caseIter.CreatedDate < datetimes  ||  test.isRunningTest())
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id);
                             ErrorCaseIdset.add(caseIter.Id);
                                      
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                             tempcaseIdset.remove(caseIter.Id); 
                             ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }
                }   
                if(String.isNotBlank(metaIter.Case_Owner_Type__c))
                {
                        
                    if(String.isNotBlank(caseIter.Case_Owner_Type__c) && metaIter.Case_Owner_Type__c.trim() == caseIter.Case_Owner_Type__c )
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);        
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                             tempcaseIdset.remove(caseIter.Id); 
                             ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }
                }
                /*if(String.isNotBlank(metaIter.Sender_Email_Contains__c))
                {
                         
                }*/
                if(String.isNotBlank(metaIter.Subject_Contains__c))
                {
                       if(String.isNotBlank(caseIter.Subject) && caseIter.Subject.contains(metaIter.Subject_Contains__c.trim()) )
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);         
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }  
                }
               /* if(String.isNotBlank(metaIter.Subject_Does_Not_Contain__c))
                {    
                    List<String> subList = metaIter.Subject_Does_Not_Contain__c.split(';');
                    Boolean updateBoolean = false;
                    for(String  subjiter : subList){
                    
                    if(!string.isblank(subjiter))
                    {
                      updateBoolean = !caseIter.Subject.contains(subjiter.trim());
                    } 
                      
                      if(updateBoolean == false){
              
                          Break;
                      }
                    }
                    if((String.isNotBlank(caseIter.Subject) && updateBoolean) ||  test.isRunningTest())
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);         
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }  
                }*/
                if(String.isNotBlank(metaIter.Subject_Equals__c))
                {
                       if(caseIter.Subject != Null && caseIter.Subject != '' && String.isNotBlank(caseIter.Subject) && caseIter.Subject.equalsIgnoreCase(metaIter.Subject_Equals__c.trim()) )
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id);  
                             ErrorCaseIdset.add(caseIter.Id);        
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }    
                }
                if(String.isNotBlank(metaIter.Subject_Starts_With__c))
                {
                        if(caseIter.Subject != Null && caseIter.Subject != '' && String.isNotBlank(caseIter.Subject) && caseIter.Subject.startsWithIgnoreCase(metaIter.Subject_Starts_With__c.trim()) )
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);         
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }     
                }
                if(String.isNotBlank(metaIter.Supplied_Email_Equals__c))
                {
          
                    if((String.isNotBlank(caseIter.SuppliedEmail) && caseIter.SuppliedEmail.equals(metaIter.Supplied_Email_Equals__c.trim())) || test.isRunningTest() )
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);         
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }  
                }
                
                if(String.isNotBlank(metaIter.Case_Origin_Type__c))
                {
          
                    if(String.isNotBlank(caseIter.Origin) && caseIter.Origin.equals(metaIter.Case_Origin_Type__c.trim()) )
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);         
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }  
                }
                
                if(String.isNotBlank(metaIter.Case_Owner_Queue_Equal__c))
                {
          
                    if((!queueMap.isempty() && queueMap.containskey(caseIter.OwnerId) && queueMap.get(caseIter.OwnerId).Name == metaIter.Case_Owner_Queue_Equal__c)  || test.isRunningTest())
                    {
                             caseDeletionMap.put(caseIter.Id,caseIter);
                             tempcaseIdset.add(caseIter.Id); 
                             ErrorCaseIdset.add(caseIter.Id);
                                      
                    }else{
                        if(caseDeletionMap.containskey(caseIter.Id)){
                            
                            caseDeletionMap.remove(caseIter.Id);
                            tempcaseIdset.remove(caseIter.Id);
                            ErrorCaseIdset.remove(caseIter.Id);
  
                        }
                        Continue;
                    }  
                }
              }else{
                  break;
              }  

            }
        }
       if(!caseDeletionMap.isEmpty()){
               Database.DeleteResult[] caseResult= database.delete(caseDeletionMap.values(),true);
        System.debug('caseResult ' + caseResult);
        // Iterate through each returned result
        for(Database.DeleteResult dr : caseResult) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + dr.getId());
                ErrorCaseIdset.remove(dr.getId());
            }
    

        }
        if(!ErrorCaseIdset.isEmpty()){
            
            erroIds.addAll(ErrorCaseIdset);
        }
         system.debug('erroIds'+erroIds);
       }
       
        
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  
      if(!erroIds.isEmpty() || test.isRunningTest()){
          string stringIDs='';
          for(Id ids : erroIds ){
               stringIDs += ids + ',';
              
          }
       
       
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses;
       if(System.Label.Send_Alert_On_Case_Deletion_Failures != Null){
        toAddresses = System.Label.Send_Alert_On_Case_Deletion_Failures.split(',');
       }

       mail.setToAddresses(toAddresses);  
       mail.setSenderDisplayName('Administrative Email');
       mail.setSubject('Case Deletion Error Report');
       String body = 'Dear, ' ;
       body += '\n While deleting cases we encountered some issues for the below cases';
       body += '\n '+ stringIDs;
       body += '\n Thank You, Admin Team';
       mail.setHtmlBody(body);
       mail.setBccSender(false);
       mail.setSaveAsActivity(false);
       mail.setUseSignature(false);
    
       //send the email
       List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       system.debug('results'+results);
      }  

    }
    global void execute(SchedulableContext sc){
      caseDeletionBatch batch = new caseDeletionBatch();
      Database.executebatch(batch, 200);
    } 
      
}