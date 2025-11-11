@RestResource(urlMapping='/updateHardwareOrderLineSerialNumber/*')
global with sharing class UpdateHardwareOrderLineSerialNumber {
    @HttpPost
    global static void updateHardwareOrderLineSerialNumber() {
        Map<String, Object> m = new Map<String,Object>();
        String orderlineid;
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Update Hardware Order Line Serial Number';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
            
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
            Object OpportunityOrderLine = (Object)params.get('OpportunityOrderLine');
            m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(OpportunityOrderLine));
            orderlineid = (String) m.get('OrderlineId');
            List<OpportunityLineItem> opplineList = [Select Id,Serial_Numbers__c,Exegon_Serial_Numbers__c,HS_Code__c
                                      FROM OpportunityLineItem WHERE Id=:orderlineid ];
            if(!opplineList.isEmpty()){
            	OpportunityLineItem oppline = opplineList[0];
            	oppline.Serial_Numbers__c = (String) m.get('SerialNumber');
                oppline.Exegon_Serial_Numbers__c = (String) m.get('ExegonSerialNumber');
                oppline.HS_Code__c = (String) m.get('HSCode');
                update oppline;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"Hardware Order Line Serial Number update is Success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Hardware Order Line Serial Number update is successful' + orderlineid;
                log.Functionality__c = 'Update Hardware Order Line Serial Number';
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
            log.Functionality__c = 'Update Hardware Order Line Serial Number';
            insert log;
        }
    }
}