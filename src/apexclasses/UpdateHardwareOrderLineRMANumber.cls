@RestResource(urlMapping='/updateHardwareOrderLineRMANumber/*')
global with sharing class UpdateHardwareOrderLineRMANumber {
    @HttpPost
    global static void updateHardwareOrderLineRMANumber() {
        Map<String, Object> m = new Map<String,Object>();
        String orderlineid;
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Update Hardware Order Line RMA Number';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
            
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
            Object OpportunityOrderLine = (Object)params.get('OpportunityOrderLine');
            m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(OpportunityOrderLine));
            orderlineid = (String) m.get('OrderlineId');
            List<OpportunityLineItem> opplineList = [Select Id,Hardware_Stock_Status__c,RMA_Number__c
                                      FROM OpportunityLineItem WHERE Id=:orderlineid ];
            if(!opplineList.isEmpty()){
            	OpportunityLineItem oppline = opplineList[0];
                oppline.RMA_Number__c = (String) m.get('RMANumber');
                update oppline;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"Hardware Order Line RMA Number update is Success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Hardware Order Line RMA Number update is successful' + orderlineid;
                log.Functionality__c = 'Update Hardware Order Line RMA Number';
                insert log;    
			}
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No OpportunityLines Found" }');    
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+m;
            log.Functionality__c = 'Update Hardware Order Line RMA Number';
            insert log;
        }
    }
}