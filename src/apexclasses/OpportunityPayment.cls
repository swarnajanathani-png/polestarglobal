@RestResource(urlMapping='/UpdateOpportunityPaymentRef/*')
global with sharing class OpportunityPayment {
    @HttpPost
    global static void updateOpportunityPayment() {
        API_Request__c apiRequest = new API_Request__c();
        apiRequest.Name = 'Pay CT Opportunity';
        apiRequest.Product_Type__c = 'LRIT CTR';
        apiRequest.Request_Type__c = 'Inbound';
        if(RestContext.request.requestBody != null) {
        	apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
        }
        insert apiRequest;
        Map<String, Object> m = new Map<String,Object>();
        try{
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
		Object Opportunity = (Object)params.get('Opportunity');
        m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Opportunity));
        String pson = (String) m.get('PSON');
        Opportunity opp = [Select Id,AccountId,StageName,Purchase_Order_No__c from Opportunity where Service_PSON__c =: pson];
        apiRequest.Account__c = opp.AccountId;
        update apiRequest;
        opp.StageName = 'Closed Won';
        opp.Payment_Receipt_Number__c = (String) m.get('PaymentReceiptNumber');
        opp.Payment_Option__c = '';
        opp.CloseDate = System.today();
        update opp;
	    RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"success" }');
        Error_Log__c log = new Error_Log__c();
        log.Error_Message__c = 'CT Opportunity Payment is successful' + pson;
        log.Functionality__c = 'Pay CT Opportunity';
        insert log;

        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+ m;
            log.Functionality__c = 'Pay CT Opportunity';
            insert log;
        }
    }
}