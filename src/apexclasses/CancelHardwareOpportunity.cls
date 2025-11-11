@RestResource(urlMapping='/cancelHardwareOpportunity/*')
global with sharing class CancelHardwareOpportunity {
    @HttpPost
    global static void cancelHardwareOpportunity() {
        Map<String, Object> oppdata = new Map<String,Object>();
        String pson = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Hardware Order Cancellation';
            apiRequest.Product_Type__c = 'Hardware';
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
            
            List<Opportunity> listOpportunity = [Select Id,AccountId,StageName,Service_PSON__c from Opportunity where Service_PSON__c=:pson];
            if(!listOpportunity.isEmpty()){
                apiRequest.Account__c = listOpportunity[0].AccountId;
                update apiRequest; 
                for(Opportunity oppor : listOpportunity){
                	oppor.StageName = 'Closed Lost';
                    oppor.Stage_Reason__c  = cancelReason;
                    oppor.LostAbort_Details__c = cancelReason;
                    
                }
                
                if(!listOpportunity.isEmpty()){
                	update listOpportunity;     
                }
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "message":"success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Hardware Order Cancellation Success:'+pson;
                log.Functionality__c = 'Hardware Order Cancellation';
                insert log;
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No Hardware Opportunity Found" }'); 
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Error: No Hardware Opportunity Found with '+pson;
                log.Functionality__c = 'Hardware Order Cancellation';
                insert log;
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+pson;
            log.Functionality__c = 'Hardware Order Cancellation';
            insert log;
        }
    }
}