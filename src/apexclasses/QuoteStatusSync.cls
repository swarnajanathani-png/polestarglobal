public with sharing class QuoteStatusSync {

   Public static void QuoteStatusSync(List<Quote> quotes){
   
       List<Id> opps = new list<Id>();

       Map<Quote,Opportunity> oppMap = new Map<Quote,Opportunity>();
       
       List<Opportunity> oppForUpload = new List<Opportunity>();
       
       List<Opportunity> oppTurnOnRules = new List<Opportunity>();
       
       For(Quote q: quotes){
       
           opps.add(q.OpportunityId);
           
       }
       
       Set<Opportunity> quoteOpps = new Set<Opportunity>();
       
       quoteOpps.add([SELECT Id, StageName FROM Opportunity WHERE Id in: opps]);
       
       For(Quote q: quotes){
           
           for(Opportunity opp: quoteOpps){
           
               if(opp.Id == q.OpportunityId){
               
                   oppMap.put(q, opp);
               }
               
           }
           
       }
       
       
       For(Quote q: quotes){
           
           Opportunity opp = oppMap.get(q);
           
           If(q.Status == 'Draft'){
           
               system.debug('quote = ' + q.Opportunity);
               system.debug('opp = ' + opp);
               opp.StageName = 'Lead time';
               opp.Skip_Validation__c = TRUE;
               oppForUpload.add(opp);
           
           }
           
           If(q.Status == 'Sent'){
           
               system.debug('quote = ' + q.Opportunity);
               system.debug('opp = ' + opp);
               opp.StageName = 'Quote sent';
               opp.Skip_Validation__c = TRUE;
               oppForUpload.add(opp);
           
           }
           
           If(q.Status == 'Accepted'){
       
               system.debug('quote = ' + q.Opportunity);
               system.debug('opp = ' + opp);
               opp.StageName = 'Quote Accepted';
               opp.Skip_Validation__c = TRUE;
               oppForUpload.add(opp);
           
           }
           
        }
        
       update(oppForUpload);
       
       for(Opportunity opp : oppForUpload){
       
           opp.Skip_Validation__c = FALSE;
           oppTurnOnRules.add(opp);
       
       }
       
       update(oppTurnOnRules);
       
    }

}