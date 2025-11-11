@RestResource(urlMapping='/getCTPrice/*')
global with sharing class LRITGetCTPrice {
    @HttpPost
    global static void getCTPrice() {
        String customerId = '';
        String vesselFlag = '';
        try{
            RestRequest req = RestContext.request;
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
			vesselFlag = (String) params.get('vesselFlag');
            customerId = (String) params.get('customerId');
            String billingCountry = (String) params.get('billingCountry');
            Account acc = [Select Id,Is_Distributor__c,Account_Type__c,Parent.Is_Distributor__c from Account where Id=: customerId];
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get CT Price';
            apiRequest.Product_Type__c = 'LRIT CT';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            apiRequest.Account__c = customerId;
            insert apiRequest;        
        
            List<PriceBookEntry> ctPbe = new List<PriceBookEntry>();   
            if(acc.Is_Distributor__c == true || acc.Parent.Is_Distributor__c == true) {
        		ctPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.Vessel_Flag__c =: vesselFlag
                                 AND Product2.Family = 'LRIT' AND Pricebook2.Name like '%Wholesale%']; 
            }
            else {
                ctPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.Vessel_Flag__c =: vesselFlag
                                     AND Product2.Family = 'LRIT' AND Pricebook2.Name like '%Retail%'];         
            }
            
            if(!ctPbe.isEmpty()) {
                List<CTPrice> ctPriceList = new List<CTPrice>();
                for(PriceBookEntry pbe:ctPbe){
                	CTPrice ctpricewrapper = new CTPrice();
                    Decimal ctPrice = 0;
                    Decimal vatPrice = 0;
                    Decimal discount = 0;
                    Decimal totalPrice = 0;
                    ctPrice = pbe.UnitPrice;
                    
                    if((billingCountry == 'United Kingdom' || billingCountry == 'Isle of Man')
                       && acc.Is_Distributor__c == false && acc.Parent.Is_Distributor__c == false) {
                           vatPrice = (ctPrice*20)/100;
                    }
                    if(acc.Account_Type__c == 'National Agent' && vesselFlag == 'Liberia - LBR'){
                        discount = (ctPrice*20)/100;
                    }
                	totalPrice = ctPrice + vatPrice - discount;
                    ctpricewrapper.price = totalPrice;
                    ctpricewrapper.currencyCode = pbe.CurrencyIsoCode;
                    ctPriceList.add(ctpricewrapper);
                }
                CTPriceWrapper ctPriceObj = new CTPriceWrapper();
                ctPriceObj.statuscode = '200';
                ctPriceObj.message = 'success';
                ctPriceObj.customerId = customerId;
                ctPriceObj.ctPriceList = ctPriceList; 
                String jsonString = JSON.serialize(ctPriceObj);
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
                Error_Log__c log = new Error_Log__c();
            	log.Error_Message__c = 'Success: Get CT Price for '+customerId+ 'Vessel Flag '+vesselFlag;
                log.Functionality__c = 'Get CT Price';
            	insert log;
            }
            else{
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"PriceBookEntry is not available for the Product"}');	        
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'PriceBookEntry is not available for '+customerId+ 'Vessel Flag '+vesselFlag;
                log.Functionality__c = 'Get CT Price';
                insert log;
            }
                    
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+':Error Occurred while getting CT Price for '+customerId+ 'Vessel Flag '+vesselFlag;
            log.Functionality__c = 'Get CT Price';
            insert log;
        }
    }
    class CTPriceWrapper{
        public String statuscode;
    	public String message;
		public String customerId;
        public List<CTPrice> ctPriceList;        
    }
    class CTPrice{
    	public Double price;
        public String currencyCode;    
    } 
}