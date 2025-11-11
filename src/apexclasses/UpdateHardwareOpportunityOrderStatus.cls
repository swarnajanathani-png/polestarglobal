@RestResource(urlMapping='/UpdateHardwareOpportunityOrderStatus/*')
global with sharing class UpdateHardwareOpportunityOrderStatus {
    @HttpPost
    global static void updateHardwareOpportunityOrderStatus() {
        Map<String, Object> m = new Map<String,Object>();
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Update Hardware Opp Order Status';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
                    
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
            Object Opportunity = (Object)params.get('Opportunity');
            m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Opportunity));
            String pson = (String) m.get('PSON');
            List<Opportunity> listOpp = [Select Id,AccountId,Account.Name,StageName,Comments__c,Estimated_Delivery_Lead_Time__c,Delivery_Or_Collection_Status__c,Payment_Option__c from Opportunity where Service_PSON__c =: pson];
            if(!listOpp.isEmpty()) {
                Opportunity opp = listOpp[0];
            	apiRequest.Account__c = opp.AccountId;
                update apiRequest;
                if(String.isNotBlank((String) m.get('TrackingURL'))) {
                    opp.Tracking_URL__c = (String) m.get('TrackingURL');
                }
                if(String.isNotBlank((String) m.get('DeliveryOrCollectionStatus'))) {
                    opp.Delivery_Or_Collection_Status__c = (String) m.get('DeliveryOrCollectionStatus');
                }
                if(String.isNotBlank((String) m.get('EstimatedDeliveryLeadTime'))) {
                    opp.Estimated_Delivery_Lead_Time__c = (String) m.get('EstimatedDeliveryLeadTime');
                }
                if(String.isNotBlank((String) m.get('Comments'))) {
                    opp.Comments__c = (String) m.get('Comments');
                }
                if(String.isNotBlank((String) m.get('AWBRefNo'))) {
                    opp.Exxegon_dispatch_customer_advised_AWB_no__c = (String) m.get('AWBRefNo');
                }
                update opp;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"Opportunity Order Status Update Success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Hardware Opportunity Delivery/Collection Status update is successful' + pson;
                log.Functionality__c = 'Update Hardware Opp Order Status';
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
            log.Functionality__c = 'Update Hardware Opp Order Status';
            insert log;
        }
    }
}