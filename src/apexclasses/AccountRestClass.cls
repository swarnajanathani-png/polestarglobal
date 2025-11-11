@RestResource(urlMapping='/CreateOrUpdateAccount/*')
global with sharing class AccountRestClass {
    @HttpPost
    global static void postAccount() {
        Map<String, Object> accountdata = new Map<String,Object>();
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Create Account';
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
            String email = (String) accountdata.get('CompanyEmail');
            String isDistributor = (String) accountdata.get('IsDistributor');
            String parentAccountId = (String) accountdata.get('ParentCustomerId');
            String existingCreditTerms = '';
            List<Account> accountsList = [Select Id,Credit_terms__c,Company_Email_Generic__c From Account 
                                          Where Company_Email_Generic__c =:email 
                                          and Lead_Source__c=:source
                                          and Account_Status__c!='Inactive'];
            if(String.isNotBlank(CustomerId)) {
            	accountsList = [Select Id,Credit_terms__c,Company_Email_Generic__c From Account 
                                          Where Id=:CustomerId
                               			  and Account_Status__c!='Inactive'];    
            }
            
            Account acc = new Account();
            
            if(!accountsList.isEmpty()){
                acc.Id = accountsList[0].Id;
                existingCreditTerms = accountsList[0].Credit_terms__c;
                apiRequest.Name = 'Update Account';
                apiRequest.Account__c = accountsList[0].Id;
                update apiRequest;
            
            }
            if(String.isNotBlank(parentAccountId) && parentAccountId != 'null'){
            	acc.ParentId = parentAccountId;    
            }
            acc.Name = (String) accountdata.get('CompanyName');
            acc.Phone = (String) accountdata.get('CompanyPhone');
            acc.X24x7_phone__c = (String) accountdata.get('MobilePhone');
            acc.Website = (String) accountdata.get('CompanyWebsite') != 'null'?(String) accountdata.get('CompanyWebsite'):'';
            acc.Account_Status__c = 'Commercial';
            acc.Company_Email_Generic__c = email;
            acc.Address_Line_1__c = (String) accountdata.get('AddressLine1');
            acc.Address_Line_2__c = (String) accountdata.get('AddressLine2');
            acc.Address_Line_3__c = (String) accountdata.get('AddressLine3');
            acc.BillingStreet = acc.Address_Line_1__c;
            if(String.isNotBlank(acc.Address_Line_2__c) && acc.Address_Line_2__c != 'null'){
            	acc.BillingStreet = acc.BillingStreet + ',' + acc.Address_Line_2__c;    
            }
            if(String.isNotBlank(acc.Address_Line_3__c) && acc.Address_Line_3__c != 'null'){
                	acc.BillingStreet = acc.BillingStreet + ',' + acc.Address_Line_3__c;    
            }
            acc.BillingCountry = (String) accountdata.get('Country');
            acc.BillingCity = (String) accountdata.get('City');
            acc.BillingState = (String) accountdata.get('StateOrProvince');
            acc.BillingPostalCode = (String) accountdata.get('ZipOrPostalcode');
            acc.Lead_Source__c = source;
            acc.Primary_Contact__c = (String) accountdata.get('FirstName') +' '+ (String) accountdata.get('LastName');
            acc.Finance_Email__c = (String) accountdata.get('FinanceEmail');
            acc.Line_of_Business__c = (String) accountdata.get('LineOfBusiness');
            acc.VAT_Number__c = (String) accountdata.get('VatNumber');
            String creditTerms = (String) accountdata.get('CreditTerms');
            if(isDistributor == 'true') {
                acc.Is_Distributor__c = true;
            	acc.Credit_terms__c = 'Payment on invoice'; 
                acc.Account_Type__c = 'Distributor';
            	acc.RecordTypeId = '012D0000000VAZtIAO';
            }
            else if(existingCreditTerms == 'Payment on invoice'){ // Added this condition to fix https://pole-star.atlassian.net/browse/FIT-31
                acc.Is_Distributor__c = false;
                acc.Account_Type__c = 'End User';
            	acc.RecordTypeId = '012D0000000VAZqIAO';
            }
            else{
                acc.Is_Distributor__c = false;
                acc.Credit_terms__c = 'Proforma';
                acc.Account_Type__c = 'End User';
            	acc.RecordTypeId = '012D0000000VAZqIAO';
            }
            /*else if(String.isNotBlank(creditTerms)){
            	acc.Credit_terms__c = creditTerms;   
            }*/
            
            acc.Not_Sync_with_SAP__c = true;
            upsert acc;
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "customerid" : "'+acc.Id+'","message":"success" }');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'Account Insert or Update is Success:' + acc.Id;
            log.Functionality__c = 'Create/Update Account';
            insert log;
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage() + accountdata;
            log.Functionality__c = 'Create/Update Account';
            insert log;
        }
    }
}