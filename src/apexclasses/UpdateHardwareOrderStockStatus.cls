@RestResource(urlMapping='/updateHardwareOrderStockStatus/*')
global with sharing class UpdateHardwareOrderStockStatus {
     @HttpPost
    global static void updateHardwareOrderStockStatus() {
        Map<String, Object> m = new Map<String,Object>();
        String orderlinebatchid;
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Update Hardware Order Batch Stock Status';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
            
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
            Object OpportunityOrderLine = (Object)params.get('OpportunityOrderLine');
            m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(OpportunityOrderLine));
            orderlinebatchid = (String) m.get('BatchID');
            Decimal availableStockLimit = (Integer) m.get('OrdersLinesLimit'); 
            List<OpportunityLineItem> oppLinesListToUpdate = new List<OpportunityLineItem>();
            List<OpportunityLineItem> paidOpplinesList = [Select Id,Hardware_Stock_Status__c,Arrived_Quantity__c,Quantity
                                           FROM OpportunityLineItem WHERE BatchID__c=:orderlinebatchid
                                           AND Hardware_Stock_Status__c = 'Stock on Order' 
                                           AND Opportunity.StageName = 'Closed Won' Order By Opportunity.Order_Date__c asc];
            for(OpportunityLineItem opl: paidOpplinesList){
                
                if(availableStockLimit > 0){
                    if(opl.Arrived_Quantity__c == null) {
                		opl.Arrived_Quantity__c = 0;    
                	}
                	Decimal stockToAllocate = opl.Quantity - opl.Arrived_Quantity__c; 
                    if(availableStockLimit > stockToAllocate) {
                        opl.Arrived_Quantity__c = opl.Arrived_Quantity__c + stockToAllocate;
                        availableStockLimit = availableStockLimit - stockToAllocate;    
                    }
                    else {
                        opl.Arrived_Quantity__c = opl.Arrived_Quantity__c + availableStockLimit;
                        availableStockLimit = 0;
                    }
                    oppLinesListToUpdate.add(opl);    
                }
                else {
                    break;
                }
                
                 
            }
            List<OpportunityLineItem> nonPaidOpplinesList = [Select Id,Hardware_Stock_Status__c,Arrived_Quantity__c,Quantity
                                           FROM OpportunityLineItem WHERE BatchID__c=:orderlinebatchid
                                           AND Hardware_Stock_Status__c = 'Stock on Order' 
                                           AND Opportunity.StageName = 'Closed Received' Order By Opportunity.Order_Date__c asc];
            for(OpportunityLineItem opl: nonPaidOpplinesList){
                if(opl.Arrived_Quantity__c == null) {
                	opl.Arrived_Quantity__c = 0;    
                }
                if(availableStockLimit > 0){
                	Decimal stockToAllocate = opl.Quantity - opl.Arrived_Quantity__c; 
                    if(availableStockLimit > stockToAllocate) {
                        opl.Arrived_Quantity__c = opl.Arrived_Quantity__c + stockToAllocate;
                        availableStockLimit = availableStockLimit - stockToAllocate;    
                    }
                    else {
                        opl.Arrived_Quantity__c = opl.Arrived_Quantity__c + availableStockLimit;
                        availableStockLimit = 0;
                    }
                    oppLinesListToUpdate.add(opl);    
                }
                else {
                    break;
                }
                 
            }
            if(!oppLinesListToUpdate.isEmpty()){
            	update oppLinesListToUpdate;    
                       
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"Opportunity Batch Stock Status update is Success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Hardware Opportunity Order Batch Stock Status update is successful' + orderlinebatchid;
                log.Functionality__c = 'Update Hardware Order Batch Stock Status';
                insert log;
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No Hardware Order Lines found with given batch id" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'No Hardware Order Lines found with given batch id' + orderlinebatchid;
                log.Functionality__c = 'Update Hardware Order Batch Stock Status';
                insert log;	    
            }

        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+m;
            log.Functionality__c = 'Update Hardware Order Batch Stock Status';
            insert log;
        }
    }
}