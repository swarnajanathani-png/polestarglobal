@RestResource(urlMapping='/getCTRPrice/*')
global with sharing class LRITGetCTRPrice {
    @HttpPost
    global static void getCTRPrice() {
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
            apiRequest.Name = 'Get CTR Price';
            apiRequest.Product_Type__c = 'LRIT CTR';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            apiRequest.Account__c = customerId;
            insert apiRequest;        
        
            List<PriceBookEntry> ctrPbe = new List<PriceBookEntry>();   
            ctrPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.Vessel_Flag__c =: vesselFlag
                                 AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR']; 
            List<PriceBookEntry> fasttrackPbe = new List<PriceBookEntry>();   
            fasttrackPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000212'
                                 AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];
            List<PriceBookEntry> courierPbe = new List<PriceBookEntry>();   
            courierPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000213'
                                     AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];
            LRITGetCTRPrice.CTRPriceWrapper ctrPriceObj = new LRITGetCTRPrice.CTRPriceWrapper();
            //CTR Price
            if(!ctrPbe.isEmpty()) {
                List<LRITGetCTRPrice.CTRPrice> ctrPriceList = new List<LRITGetCTRPrice.CTRPrice>();
                for(PriceBookEntry pbe:ctrPbe){
                	CTRPrice ctrpricewrapper = new CTRPrice();
                    Decimal ctrPrice = 0;
                    Decimal vatPrice = 0;
                    Decimal totalPrice = 0;
                    ctrPrice = pbe.UnitPrice;
                    
                    if((billingCountry == 'United Kingdom' || billingCountry == 'Isle of Man')
                       && acc.Is_Distributor__c == false && acc.Parent.Is_Distributor__c == false) {
                           vatPrice = (ctrPrice*20)/100;
                    }
                    totalPrice = ctrPrice + vatPrice;
                    ctrpricewrapper.price = totalPrice;
                    ctrpricewrapper.currencyCode = pbe.CurrencyIsoCode;
                    ctrPriceList.add(ctrpricewrapper);
                }
                ctrPriceObj.ctrPriceList = ctrPriceList; 
                //Fasttrack Price
                if(!fasttrackPbe.isEmpty()) {
                    List<LRITGetCTRPrice.FasttrackPrice> fasttrackPriceList = new List<LRITGetCTRPrice.FasttrackPrice>();
                    for(PriceBookEntry pbe:fasttrackPbe){
                        FasttrackPrice fasttrackPricewrapper = new FasttrackPrice();
                        Decimal fasttrackPrice = 0;
                        Decimal vatPrice = 0;
                        Decimal totalPrice = 0;
                        fasttrackPrice = pbe.UnitPrice;
                        
                        if((billingCountry == 'United Kingdom' || billingCountry == 'Isle of Man')
                           && acc.Is_Distributor__c == false && acc.Parent.Is_Distributor__c == false) {
                               vatPrice = (fasttrackPrice*20)/100;
                        }
                        totalPrice = fasttrackPrice + vatPrice;
                        fasttrackPricewrapper.price = totalPrice;
                        fasttrackPricewrapper.currencyCode = pbe.CurrencyIsoCode;
                        fasttrackPriceList.add(fasttrackPricewrapper);
                    }
                    ctrPriceObj.fasttrackPriceList = fasttrackPriceList;     
                }
                //Courier Price
                if(!courierPbe.isEmpty()) {
                    List<LRITGetCTRPrice.CourierPrice> courierPriceList = new List<LRITGetCTRPrice.CourierPrice>();
                    for(PriceBookEntry pbe:courierPbe){
                        CourierPrice courierPricewrapper = new CourierPrice();
                        Decimal courierPrice = 0;
                        Decimal vatPrice = 0;
                        Decimal totalPrice = 0;
                        courierPrice = pbe.UnitPrice;
                        
                        if((billingCountry == 'United Kingdom' || billingCountry == 'Isle of Man')
                           && acc.Is_Distributor__c == false && acc.Parent.Is_Distributor__c == false) {
                               vatPrice = (courierPrice*20)/100;
                        }
                        totalPrice = courierPrice + vatPrice;
                        courierPricewrapper.price = totalPrice;
                        courierPricewrapper.currencyCode = pbe.CurrencyIsoCode;
                        courierPriceList.add(courierPricewrapper);
                    }
                    ctrPriceObj.courierPriceList = courierPriceList;     
                }
                ctrPriceObj.statuscode = '200';
                ctrPriceObj.message = 'success';
                ctrPriceObj.customerId = customerId;
                String jsonString = JSON.serialize(ctrPriceObj);
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Success: Get CTR Price for '+customerId+ 'Vessel Flag '+vesselFlag;
                log.Functionality__c = 'Get CTR Price';
                insert log;
            }
            else{
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"PriceBookEntry is not available for the Product"}');	        
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'PriceBookEntry is not available for '+customerId+ 'Vessel Flag '+vesselFlag;
                log.Functionality__c = 'Get CTR Price';
                insert log;
            }
                   
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+':Error Occurred while getting CTR Price for '+customerId+ 'Vessel Flag '+vesselFlag;
            log.Functionality__c = 'Get CTR Price';
            insert log;
        }
    }
    class CTRPriceWrapper{
        public String statuscode;
    	public String message;
		public String customerId;
        public List<CTRPrice> ctrPriceList;  
        public List<FasttrackPrice> fasttrackPriceList;  
        public List<CourierPrice> courierPriceList;  
    }
    class CTRPrice{
    	public decimal price;
        public string currencyCode;    
    } 
    class FasttrackPrice{
    	public decimal price;
        public string currencyCode;    
    } 
    class CourierPrice{
    	public decimal price;
        public string currencyCode;    
    } 
}