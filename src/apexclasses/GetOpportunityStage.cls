@RestResource(urlMapping='/getOpportunityStage/*')
global with sharing class GetOpportunityStage {
    @HttpPost
    global static void getOpportunityStage() {
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
        try{
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get Opportunity Stage';
            apiRequest.Product_Type__c = 'LRIT CT';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
            Object psonsObj = params.get('psons');
            List<Object> psonsList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(psonsObj));
            Set<String> psonsSet = new Set<String>();
            for(Object obj : psonsList){
                Map<String, Object> psonAttributes = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            	psonsSet.add((String) psonAttributes.get('pson'));
            }
            List<Opportunity> listOpportunities = [Select Id,StageName,Service_PSON__c from Opportunity where Service_PSON__c IN:psonsSet];
            List<PSON> psonsListWrapper = new List<PSON>();
            for(Opportunity opp:listOpportunities){
            	PSON psonObj = new PSON();
                psonObj.pson = opp.Service_PSON__c;
                psonObj.stageName = opp.StageName;
                psonsListWrapper.add(psonObj);
            }
            OppStageWrapper oppStageWraper = new OppStageWrapper();
            oppStageWraper.statuscode = '200';
            oppStageWraper.message = 'success';
            oppStageWraper.psonsList = psonsListWrapper;
            String jsonString = JSON.serialize(oppStageWraper);
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(jsonString);
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'Success getting Opportunity Stage: '+jsonString;
            log.Functionality__c = 'Get Opportunity Stage';
            insert log;
            
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'Error Occurured while getting Opportunity Stage: '+ e.getMessage()+ ':'+params;
            log.Functionality__c = 'Get Opportunity Stage';
            insert log;
        }
    }
    
    class OppStageWrapper{
        public String statuscode;
    	public String message;
		public List<PSON> psonsList;        
    }
    class PSON{
    	public String pson;
        public String stageName;    
    } 
}