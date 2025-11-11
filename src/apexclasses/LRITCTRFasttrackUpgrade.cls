@RestResource(urlMapping='/updateCTROpportunityFTPayment/*')
global with sharing class LRITCTRFasttrackUpgrade {
    @HttpPost
    global static void ctrFasttrackUpdate() {
        Map<String, Object> oppdata = new Map<String,Object>();
        String pson = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'CTR Fasttrack Upgrade';
            apiRequest.Product_Type__c = 'LRIT CTR';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;        
        
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			String source = (String) params.get('Source');
        	Object opp = (Object)params.get('Opportunity');
       		oppdata = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(opp));
            pson = (String) oppdata.get('PSON');
            String ftPaymentNumber = (String) oppdata.get('FastTrackPaymentReceiptNumber');
            String ftCurrency = (String) oppdata.get('Currency');
            
            List<Opportunity> listOpportunity = [Select Id,AccountId,Account.Is_Distributor__c,Account.Parent.Is_Distributor__c,Invoice_Country__c,Service_PSON__c,
                                                 (Select Id,Delivery_Option__c FROM LRIT_CTR_Requests__r) 
                                                 FROM Opportunity where Service_PSON__c=:pson];
            
            if(!listOpportunity.isEmpty()){
                apiRequest.Account__c = listOpportunity[0].AccountId;
                update apiRequest; 
                List<PriceBookEntry> fasttrackPbe = new List<PriceBookEntry>();                                     
                fasttrackPbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000212'
                                    AND CurrencyIsoCode=:ftCurrency AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];  
                
                if(!fasttrackPbe.isEmpty()) {
                        Decimal fasttrackPrice = 0;
                        OpportunityLineItem fasttrackOppLineItem = new OpportunityLineItem();
                        fasttrackOppLineItem.OpportunityId = listOpportunity[0].Id;
                        fasttrackOppLineItem.Product2Id = fasttrackPbe[0].Product2Id; 
                        fasttrackOppLineItem.PricebookEntryId = fasttrackPbe[0].Id;
                        fasttrackOppLineItem.Quantity=1;
                        fasttrackOppLineItem.Product_Sales_Type__c = 'One-off Product';
                        fasttrackOppLineItem.Product_Start_Date__c = System.today();
                        fasttrackOppLineItem.Product_End_Date__c = System.today();
                        //oppLineItem.UnitPrice = pbe[0].UnitPrice;
                        fasttrackPrice = fasttrackPbe[0].UnitPrice;
                        
                        if((listOpportunity[0].Invoice_Country__c == 'United Kingdom' || listOpportunity[0].Invoice_Country__c == 'Isle of Man')
                           && listOpportunity[0].Account.Is_Distributor__c == false && listOpportunity[0].Account.Parent.Is_Distributor__c == false) {
                            fasttrackOppLineItem.VAT_Amount__c = (fasttrackPrice*20)/100;
                        }
                        else{
                            fasttrackOppLineItem.VAT_Amount__c = 0;    
                        }
                        fasttrackOppLineItem.TotalPrice = fasttrackPrice + fasttrackOppLineItem.VAT_Amount__c;
                        
                        //oppLineItem.TotalPrice = oppLineItem.TotalPrice + oppLineItem.VAT_Amount__c;
                        fasttrackOppLineItem.LRIT_CTR_Request__c = listOpportunity[0].LRIT_CTR_Requests__r[0].Id;
                        upsert fasttrackOppLineItem;
                    	
                    	List<LRIT_CTR_Request__c> ctrsToUpdats = new List<LRIT_CTR_Request__c>();
                        for(Opportunity oppor : listOpportunity){
                            oppor.FT_Payment_Receipt_Number__c = ftPaymentNumber;
                            for(LRIT_CTR_Request__c ctr : oppor.LRIT_CTR_Requests__r){
                                ctr.Delivery_Option__c = 'Fast Track';
                                ctrsToUpdats.add(ctr);
                            }
                        }
                        if(!ctrsToUpdats.isEmpty()){
                            update ctrsToUpdats;    
                        }
                        if(!listOpportunity.isEmpty()){
                            update listOpportunity;     
                        }
                        
                        RestContext.response.addHeader('Content-Type', 'application/json');
                        RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "message":"success" }');
                        Error_Log__c log = new Error_Log__c();
                        log.Error_Message__c = 'CTR Fasttrack Upgrade Success:'+pson;
                        log.Functionality__c = 'CTR Fasttrack Upgrade';
                        insert log;
                    }
                else{
                    RestContext.response.addHeader('Content-Type', 'application/json');
                    RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Fasttrack PriceBookEntry is not available for the Product"}');	        
                    Error_Log__c log = new Error_Log__c();
                    log.Error_Message__c = 'Fasttrack PriceBookEntry is not available with the currency '+ftCurrency;
                    insert log;
                }
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No CTR Opportunity Found" }'); 
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Error: No CTR Opportunity Found with '+pson;
                insert log;
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+pson;
            log.Functionality__c = 'CTR Fasttrack Upgrade';
            insert log;
        }
    }
}