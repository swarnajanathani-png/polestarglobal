@RestResource(urlMapping='/revokeCTR/*')
global with sharing class LRITCTRRevoke {
    @HttpPost
    global static void revokeCTR() {
        Map<String, Object> oppdata = new Map<String,Object>();
        String pson = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'CTR Revoke';
            apiRequest.Product_Type__c = 'LRIT CTR';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
        
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			String ctrId = (String) params.get('CTRID');
            String revokeReason = (String) params.get('RevokeReason');
        	List<LRIT_CTR_Request__c> ctrsToUpdats = [Select Id,Revoke_Cancellation_Reason__c, LRIT_CTR_Status__c FROM 
                                                     LRIT_CTR_Request__c WHERE Id =:ctrId];
           if(!ctrsToUpdats.isEmpty()){
                LRIT_CTR_Request__c ctr = new LRIT_CTR_Request__c();
                ctr.Id = ctrsToUpdats[0].Id;
                ctr.LRIT_CTR_Status__c = 'Revoked';
                ctr.Revoke_Cancellation_Reason__c = revokeReason;
                ctr.Revoke_Cancellation_Date__c = System.now();
                update ctr;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "message":"success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'CTR Revoke Success:'+pson;
                log.Functionality__c = 'CTR Revoke';
                insert log;
           }
           else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No CTR Found" }'); 
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Error: No CTR Opportunity Found with '+pson;
                log.Functionality__c = 'CTR Revoke';
                insert log;
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+pson;
            log.Functionality__c = 'CTR Revoke';
            insert log;
        }
    }
}