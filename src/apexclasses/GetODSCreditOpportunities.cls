@RestResource(urlMapping='/getODSCreditOpportunities/*')
global with sharing class GetODSCreditOpportunities {
    @HttpGet
    global static void getODSCreditOpportunities() {
        String accountId = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get ODS Credit Opportunities';
            apiRequest.Product_Type__c = 'Ondemand Screening Credits';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = req.params.get('customerid');
            insert apiRequest;
            accountId = req.params.get('customerid');
            
        
            List<Account> listAccounts = [Select Id,Credit_terms__c,Parent.Credit_terms__c,Is_Distributor__c,
                                          Parent.Is_Distributor__c, ParentId,SAP_Key__c from Account where id=:accountId];
            if(!listAccounts.isEmpty()){
                
            	apiRequest.Account__c = accountId;
            	update apiRequest;
                List<Opportunity> listOpps = [Select Name,Account.Credit_terms__c,AccountId,Service_PSON__c,
                                                     StageName,CloseDate, Payment_Option__c, CreatedDate,Order_Date__c,CurrencyISOCode,Amount,Amount_with_VAT__c,
                                                     Invoice_Company_Name__c,Invoice_Address_Line1__c,Invoice_Address_Line2__c,
                                                     Invoice_Address_Line3__c,Invoice_City__c,Invoice_State__c,Invoice_Zip_Code__c,
                                                     Invoice_Country__c,Finance_Contact_Name__c,TotalOpportunityQuantity,
                                                     Finance_Email__c,Finance_Phone__c,IMO_no__c,Vessel_Name__c,Screening_URL__c,Screening_Result__c,
                                              		 (Select Id,Quantity,ODS_Credits__c from OpportunityLineItems) 
                                                     FROM Opportunity 
                                                     WHERE AccountId =: accountId 
                                              		 AND Product_Type__c = 'Ondemand Screening Credits'
                                              		 AND StageName = 'Closed Won'
                                                     Order by Order_Date__c desc];
                ODSCreditOppWrapper oppObj = new ODSCreditOppWrapper();
                oppObj.customerId = accountId;
                if(listAccounts[0].ParentId != null && listAccounts[0].Parent.Is_Distributor__c == true) {
                    oppObj.creditTerms = listAccounts[0].Parent.Credit_terms__c;
                }
                else{
                	oppObj.creditTerms = listAccounts[0].Credit_terms__c;    
                }
                oppObj.sapKey = listAccounts[0].SAP_Key__c;
                List<ODSCreditOpp> odsOpps = new List<ODSCreditOpp>();
                for(Opportunity opp:listOpps){
                    ODSCreditOpp odsOpp= new ODSCreditOpp();
                    odsOpp.pson = opp.Service_PSON__c;
                    odsOpp.currencyCode = opp.CurrencyISOCode;
                    odsOpp.amountWithOutVAT = String.valueOf(opp.Amount);
                    if(opp.Amount_with_VAT__c != null){
                    	odsOpp.amount = String.valueOf(opp.Amount_with_VAT__c);    
                    }
                    else{
                    	odsOpp.amount = '';
                    }
                    odsOpp.odsCredits = 0;
                    for(OpportunityLineItem oli : opp.OpportunityLineItems){
                        odsOpp.odsCredits = odsOpp.odsCredits + oli.ODS_Credits__c;    
                    }
                    odsOpp.quantity = opp.TotalOpportunityQuantity;
                    odsOpp.billingCompanyName = opp.Invoice_Company_Name__c;
                    odsOpp.billingAddressLine1 = opp.Invoice_Address_Line1__c;
                    odsOpp.billingAddressLine2 = opp.Invoice_Address_Line2__c;
                    odsOpp.billingAddressLine3 = opp.Invoice_Address_Line3__c;
                    odsOpp.billingCity = opp.Invoice_City__c;
                    odsOpp.billingState = opp.Invoice_State__c;
                    odsOpp.billingZipcode = opp.Invoice_Zip_Code__c;
                    odsOpp.billingCountry = opp.Invoice_Country__c;
                    odsOpp.financeEmail = opp.Finance_Email__c;
                    odsOpp.financePhone = opp.Finance_Phone__c;
                    odsOpp.financeContactName = opp.Finance_Contact_Name__c;
                    
                    DateTime closeDate = opp.CloseDate;
                    if(closeDate != null) {
                    	odsOpp.closeDate = String.valueOf(closeDate.date());
                    }
                    odsOpp.psonStatus = opp.StageName;
                    odsOpp.paymentOption = opp.Payment_Option__c;
                    odsOpp.createdDate = String.valueOf(opp.CreatedDate.date());
                    if(opp.Order_Date__c != null) {
                    	odsOpp.orderDate = String.valueOf(opp.Order_Date__c.date());
                    }
                    else{
                    	odsOpp.orderDate = null;    
                    }
                    odsOpps.add(odsOpp);
                }
                oppObj.odsCreditOpps = odsOpps;
                oppObj.statuscode = '200';
                oppObj.message = 'success';
                String jsonString = JSON.serialize(oppObj);
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Get ODS Opportunities Success:'+accountId;
                log.Functionality__c = 'Get ODS Opportunities';
                insert log;
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Please provide valid customer id" }');    
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+accountId;
            log.Functionality__c = 'Get ODS Opportunities';
            insert log;
        }
    }
    
    class ODSCreditOppWrapper{
        public String statuscode;
        public String message;
        public String customerId;
        public String creditTerms;
        public String sapKey;
        public List<ODSCreditOpp> odsCreditOpps;        
    }
    class ODSCreditOpp{
    	public String pson;
        public String currencyCode;
        public String amount;
        public String amountWithOutVAT;
        public Decimal quantity;
        public Decimal odsCredits;
        public String billingCompanyName;
        public String billingAddressLine1;
        public String billingAddressLine2;
        public String billingAddressLine3;
        public String billingCity;
        public String billingState;
        public String billingZipcode;
        public String billingCountry;
        public String purchaseOrderNo;
        public String financeEmail;
        public String financePhone;
        public String financeContactName;
        public String closeDate;
        public String psonStatus;
        public String paymentOption;
        public String createdDate;
        public String orderDate;
        
    } 
}