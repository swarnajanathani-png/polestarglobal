@RestResource(urlMapping='/inactivateAccount/*')
global with sharing class InactivateAccount {
    @HttpPost
    global static void inactivateAccount() {
        Map<String, Object> accountdata = new Map<String,Object>();
        String customerId = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Inactivate Account';
            apiRequest.Product_Type__c = 'Portal Account';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;        
        
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			String source = (String) params.get('Source');
        	Object account = (Object)params.get('Account');
       		accountdata = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(account));
            customerId = (String) accountdata.get('CustomerId');
            String inactiveReason = (String) accountdata.get('InactiveReason');
            
            List<Account> listAccounts = [Select Id,Account_Status__c from Account where id=:customerId];
            if(!listAccounts.isEmpty()){
                apiRequest.Account__c = customerId;
                update apiRequest; 
                for(Account acc : listAccounts){
                	acc.Account_Status__c = 'Inactive';  
                    acc.Shutdown_Reason__c = inactiveReason;
                }
                update listAccounts;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "message":"success" }');
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Account Inacivate Success:'+customerId;
                log.Functionality__c = 'Inactivate Account';
                insert log;
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Please provide valid customer id" }'); 
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Error: Invalid Account Id '+customerId;
                log.Functionality__c = 'Inactivate Account';
                insert log;
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+customerId;
            log.Functionality__c = 'Inactivate Account';
            insert log;
        }
    }
}