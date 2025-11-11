@RestResource(urlMapping='/UpdateHardwareOpportunityPayment/*')
global with sharing class UpdateHardwareOpportunityPayment {
    @HttpPost
    global static void updateHardwareOpportunityPayment() {
        Map<String, Object> m = new Map<String,Object>();
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Pay Hardware Opportunity';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
                    
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
            Object Opportunity = (Object)params.get('Opportunity');
            m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Opportunity));
            String pson = (String) m.get('PSON');
            List<Opportunity> listOpp = [Select Id,AccountId,StageName,Purchase_Order_No__c,Payment_Option__c from Opportunity where Service_PSON__c =: pson];
            if(!listOpp.isEmpty()) {
                Opportunity opp = listOpp[0];
                apiRequest.Account__c = opp.AccountId;
                update apiRequest;
                opp.StageName = 'Closed Won';
                opp.Payment_Receipt_Number__c = (String) m.get('PaymentReceiptNumber');
                opp.Payment_Option__c = '';
                opp.Order_Date__c = System.now();
                opp.CloseDate = System.today();
                update opp;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Hardware Opportunity Payment is successful' + pson;
                log.Functionality__c = 'Pay Hardware Opportunity';
                insert log;  
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No Opportunities Found" }');    
            }

        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+m;
            log.Functionality__c = 'Pay Hardware Opportunity';
            insert log;
        }
    }
}