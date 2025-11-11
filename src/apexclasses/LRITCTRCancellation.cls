@RestResource(urlMapping='/cancelCTROpportunity/*')
global with sharing class LRITCTRCancellation {
    @HttpPost
    global static void cancelCTR() {
        Map<String, Object> oppdata = new Map<String,Object>();
        String pson = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'CTR Cancellation';
            apiRequest.Product_Type__c = 'LRIT CTR';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
        
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			String source = (String) params.get('Source');
        	Object opp = (Object)params.get('Opportunity');
       		oppdata = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(opp));
            pson = (String) oppdata.get('PSON');
            String cancelReason = (String) oppdata.get('CancelReason');
            
            List<Opportunity> listOpportunity = [Select Id,AccountId,StageName,Service_PSON__c,(Select Id,Status__c FROM LRIT_CTR_Requests__r) from Opportunity where Service_PSON__c=:pson];
            if(!listOpportunity.isEmpty()){
                apiRequest.Account__c = listOpportunity[0].AccountId;
                update apiRequest; 
                List<LRIT_CTR_Request__c> ctrsToUpdats = new List<LRIT_CTR_Request__c>();
                for(Opportunity oppor : listOpportunity){
                	oppor.StageName = 'Closed Lost';
                    oppor.Stage_Reason__c = cancelReason;
                    oppor.LostAbort_Details__c = cancelReason;
                    for(LRIT_CTR_Request__c ctr : oppor.LRIT_CTR_Requests__r){
                    	ctr.Status__c = 'Cancelled';
                        ctr.Revoke_Cancellation_Reason__c = cancelReason;
                        ctr.Revoke_Cancellation_Date__c = System.now();
                        ctrsToUpdats.add(ctr);
                    }
                }
                if(!ctrsToUpdats.isEmpty()){
                	update ctrsToUpdats;    
                }
                if(!listOpportunity.isEmpty()){
                	update listOpportunity;     
                }
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "message":"success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'CTR Cancellation Success:'+pson;
                log.Functionality__c = 'CTR Cancellation';
                insert log;
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No CTR Opportunity Found" }'); 
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Error: No CTR Opportunity Found with '+pson;
                log.Functionality__c = 'CTR Cancellation';
                insert log;
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+pson;
            log.Functionality__c = 'CTR Cancellation';
            insert log;
        }
    }
}