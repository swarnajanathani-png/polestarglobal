@RestResource(urlMapping='/getODSPrice/*')
global with sharing class LRITGetODSPrice {
    @HttpPost
    global static void getODSPrice() {
        String customerId = '';
        try{
            RestRequest req = RestContext.request;
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			customerId = (String) params.get('customerId');
            String billingCountry = (String) params.get('billingCountry');
            Account acc = [Select Id,Is_Distributor__c,Account_Type__c,Parent.Is_Distributor__c from Account where Id=: customerId];
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get ODS Price';
            apiRequest.Product_Type__c = 'Ondemand Screening';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            apiRequest.Account__c = customerId;
            insert apiRequest;        
        
            List<PriceBookEntry> odsPbe = new List<PriceBookEntry>();   
            odsPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000625'];         
            
            if(!odsPbe.isEmpty()) {
                List<ODSPrice> odsPriceList = new List<ODSPrice>();
                for(PriceBookEntry pbe:odsPbe){
                	ODSPrice odspricewrapper = new ODSPrice();
                    Decimal odsPrice = 0;
                    Decimal vatPrice = 0;
                    Decimal discount = 0;
                    Decimal totalPrice = 0;
                    odsPrice = pbe.UnitPrice;
                    odspricewrapper.productPrice = odsPrice;
                    
                    if((billingCountry == 'United Kingdom' || billingCountry == 'Isle of Man')) {
                           vatPrice = (odsPrice*20)/100;
                    }
                    odspricewrapper.vat = vatPrice;
                    totalPrice = odsPrice + vatPrice - discount;
                    odspricewrapper.totalPrice = totalPrice;
                    odspricewrapper.currencyCode = pbe.CurrencyIsoCode;
                    odsPriceList.add(odspricewrapper);
                }
                ODSPriceWrapper odsPriceObj = new ODSPriceWrapper();
                odsPriceObj.statuscode = '200';
                odsPriceObj.message = 'success';
                odsPriceObj.customerId = customerId;
                odsPriceObj.odsPriceList = odsPriceList; 
                String jsonString = JSON.serialize(odsPriceObj);
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
                Error_Log__c log = new Error_Log__c();
            	log.Error_Message__c = 'Success: Get ODS Price for '+customerId;
                log.Functionality__c = 'Get ODS Price';
            	insert log;
            }
            else{
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"PriceBookEntry is not available for the Product"}');	        
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'PriceBookEntry is not available for '+customerId;
                log.Functionality__c = 'Get ODS Price';
                insert log;
            }
                    
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+':Error Occurred while getting ODS Price for '+customerId;
            log.Functionality__c = 'Get ODS Price';
            insert log;
        }
    }
    class ODSPriceWrapper{
        public String statuscode;
    	public String message;
		public String customerId;
        public List<ODSPrice> odsPriceList;        
    }
    class ODSPrice{
    	public Double totalPrice;
        public Double vat;
        public Double productPrice;
        public String currencyCode;    
    } 
}