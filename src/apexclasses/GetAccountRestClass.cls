@RestResource(urlMapping='/getAccount/*')
global with sharing class GetAccountRestClass {
    @HttpPost
    global static void getAccountDetails() {
        Map<String, Object> accountdata = new Map<String,Object>();
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get Account';
            apiRequest.Product_Type__c = 'Portal Account';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;        
        
        	Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			String source = (String) params.get('Source');
        	Object account = (Object)params.get('Account');
       
            accountdata = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(account));
            String CustomerId = (String) accountdata.get('CustomerId');
            apiRequest.Account__c = CustomerId;
        	update apiRequest;
            List<Account> accountsList = [Select Id,Name,X24x7_phone__c,Phone,Company_Email_Generic__c,
                                          Website,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,
                                          BillingCountry,BillingCity,BillingState,BillingPostalCode,
                                          Primary_Contact__c,Finance_Email__c,Line_of_Business__c,
                                          VAT_Number__c,Credit_terms__c,Is_Distributor__c,ParentId,Parent.Is_Distributor__c,Parent.Credit_terms__c
                                          From Account Where Id =:CustomerId];
                if(!accountsList.isEmpty()) {
                    List<String> primaryContactName = new List<String>();
                    String firstName = null;
                    String lastName = null;
                    if(accountsList[0].Primary_Contact__c != null){
                        primaryContactName = accountsList[0].Primary_Contact__c.replaceAll('\\s+', ' ').trim().split(' ');
                    }
                    if(primaryContactName.size() >= 2) {
                    	firstName =  primaryContactName[0];
                        lastName = primaryContactName[1];
                    }
                    else if(primaryContactName.size() == 1) {
                    	firstName =  primaryContactName[0];    
                    }
                    
                    String creditTerms = '';
                    
                    if(accountsList[0].ParentId != null && accountsList[0].Parent.Is_Distributor__c == true) {
                    	creditTerms =  accountsList[0].Parent.Credit_terms__c;   
                    }
                    else {
                    	creditTerms = accountsList[0].Credit_terms__c;    
                    }
                	RestContext.response.addHeader('Content-Type', 'application/json');
                	RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "customerid" : "'+accountsList[0].Id
                                                                     +'", "CompanyName" : "'+accountsList[0].Name
                                                                     +'", "CompanyPhone" : "'+accountsList[0].Phone
                                                                     +'", "MobilePhone" : "'+accountsList[0].X24x7_phone__c
                                                                     +'", "CompanyWebsite" : "'+accountsList[0].Website
                                                                     +'", "CompanyEmail" : "'+accountsList[0].Company_Email_Generic__c
                                                                     +'", "AddressLine1" : "'+accountsList[0].Address_Line_1__c
                                                                     +'", "AddressLine2" : "'+accountsList[0].Address_Line_2__c
                                                                     +'", "AddressLine3" : "'+accountsList[0].Address_Line_3__c
                                                                     +'", "Country" : "'+accountsList[0].BillingCountry
                                                                     +'", "City" : "'+accountsList[0].BillingCity
                                                                     +'", "StateOrProvince" : "'+accountsList[0].BillingState
                                                                     +'", "ZipOrPostalcode" : "'+accountsList[0].BillingPostalCode
                                                                     +'", "FinanceEmail" : "'+accountsList[0].Finance_Email__c
                                                                     +'", "LineOfBusiness" : "'+accountsList[0].Line_of_Business__c
                                                                     +'", "VatNumber" : "'+accountsList[0].VAT_Number__c
                                                                     +'", "FirstName" : "'+firstName
                                                                     +'", "LastName" : "'+lastName
                                                                     +'", "CreditTerms" : "'+creditTerms
                                                                     +'","message":"success" }');
                	Error_Log__c log = new Error_Log__c();
            		log.Error_Message__c = 'Get Account is Success:' + accountsList[0].Id;
                    log.Functionality__c = 'Get Account';
            		insert log;
                }
                else{
                	RestContext.response.addHeader('Content-Type', 'application/json');
                	RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500", "customerid" : "'+accountsList[0].Id+'","message":"No account found with given customerid" }');
    
                }
            }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage() + accountdata;
            log.Functionality__c = 'Get Account';
            insert log;
        }
    }
}
