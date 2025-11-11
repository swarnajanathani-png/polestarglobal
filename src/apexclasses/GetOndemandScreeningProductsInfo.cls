@RestResource(urlMapping='/getOndemandScreeningProductsInfo/*')
global with sharing class GetOndemandScreeningProductsInfo {
    @HttpGet
    global static void getOndemandScreeningProductsInfo() {
        String accountId = '';
        String vesselFlag = '';
        try{
            RestRequest req = RestContext.request;
            accountId = req.params.get('customerid');          
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get Ondemand Screening Credits';
            apiRequest.Product_Type__c = 'Ondemand Screening Credits';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Account__c = req.params.get('customerid');
            insert apiRequest;        
            apiRequest.Account__c = accountId;
            update apiRequest;
        
            List<Account> listAccounts = [Select Id,Credit_terms__c,BillingCountry,CurrencyIsoCode,Hardware_Discount__c,Hardware_Discount_EndTime__c,ODP_Customer_Old_SF_Id__c,Parent.Credit_terms__c,Is_Distributor__c,
                                          Parent.Is_Distributor__c, ParentId,SAP_Key__c from Account where id=:accountId];
            if(!listAccounts.isEmpty()){
                List<Product2> lstProducts = [Select Id, Name, ODS_Credits__c,ProductCode,SAP_Item_Code__c,Product_Category__c,Description,
                                             Family,Generic_Discount__c,Discount_EndTime__c,Dimensions__c,Weight__c FROM Product2 where Family= 'Ondemand Screening'
                                   			AND IsActive = true AND SAP_Item_Code__c != 'SW00000625'];
    
                        
                Set<String> productIdsSet = new Set<String>();
                for(Product2 p : lstProducts){
                	productIdsSet.add(p.Id);	    
                }
                List<PriceBookEntry> ondemandScreeningPbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode,
                                   Product2.SAP_Item_Code__c,Product2.Generic_Discount__c,Product2.Discount_EndTime__c FROM PriceBookEntry Where Product2.Family = 'Ondemand Screening' AND Product2Id IN:productIdsSet];         
                
                Map<String,List<PriceBookEntry>> productToPriceBookEntriesMap = new Map<String,List<PriceBookEntry>>(); 
                List<PriceBookEntry> pbes = new List<PriceBookEntry>();
                for (PriceBookEntry pbe : ondemandScreeningPbe){
                    if(productToPriceBookEntriesMap.get(pbe.Product2Id) != null){
                        pbes = productToPriceBookEntriesMap.get(pbe.Product2Id);
                    }
                    else{
                        pbes = new List<PriceBookEntry>();
                    }
                    pbes.add(pbe);
                    productToPriceBookEntriesMap.put(pbe.Product2Id,pbes); 
                }
                if(!lstProducts.isEmpty()){
                    ProductWrapper productWrapper = new ProductWrapper();
                    List<ProductInfo> ProductInfoList = new List<ProductInfo>(); 
                	for (Product2 product : lstProducts){
                        ProductInfo productInfoWrapper = new ProductInfo();
                        productInfoWrapper.productName = product.Name;
                        productInfoWrapper.productCode = product.SAP_Item_Code__c;
                        productInfoWrapper.odsCredits = product.ODS_Credits__c;
                        productInfoWrapper.productDescription = product.Description;
                        List<ProductPrice> productPricesList = new List<ProductPrice>();
                        if(productToPriceBookEntriesMap.get(product.Id) != null){
                            for(PriceBookEntry pbe : productToPriceBookEntriesMap.get(product.Id)){
                                Decimal discount = 0;
                                ProductPrice productprice = new ProductPrice();
                                productprice.listPrice = pbe.UnitPrice;
                                productprice.currencyCode = pbe.CurrencyIsoCode;
                                if(listAccounts[0].BillingCountry == 'United Kingdom' || listAccounts[0].BillingCountry == 'Isle of Man') {
                                    productprice.vatAmount = ((productprice.listPrice*20)/100).setScale(2, RoundingMode.HALF_UP);
                                }                                
                                else{
                                    productprice.vatAmount = 0.00;    
                                }
                                productprice.listPriceWithVAT = pbe.UnitPrice + productprice.vatAmount;
                                                               
                                productPricesList.add(productprice);
                            }
                        }
                        productInfoWrapper.productPricesList = productPricesList;
                        ProductInfoList.add(productInfoWrapper);
                	}
                    productWrapper.statuscode = '200';
                    productWrapper.message = 'success';
                	productWrapper.customerId = accountId;
                    productWrapper.productsList = ProductInfoList;
                    String jsonString = JSON.serialize(productWrapper);
                	RestContext.response.addHeader('Content-Type', 'application/json');
                	RestContext.response.responseBody = Blob.valueOf(jsonString);
                	Error_Log__c log = new Error_Log__c();
            		log.Error_Message__c = 'Success: Get Ondemand Screening Products for '+accountId;
                    log.Functionality__c = 'Get Ondemand Screening Products';
            		insert log;
                }
                else{
                	RestContext.response.addHeader('Content-Type', 'application/json');
                	RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No Ondemand Screening Products Found" }');    
                    Error_Log__c log = new Error_Log__c();
                    log.Error_Message__c = 'No Ondemand Screening Products Found for customer id '+accountId;
                    log.Functionality__c = 'Get Hardware Products';
                    insert log;    
                }
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Please provide valid customer id" }');    
            	Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Please provide valid customer id '+accountId;
                log.Functionality__c = 'Get Ondemand Screening Products';
                insert log;
            }
                    
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+':Error Occurred while getting ondemand screening products for '+accountId;
            log.Functionality__c = 'Get Ondemand Screening Products';
            insert log;
        }
    }
    class ProductWrapper{
        public String statuscode;
    	public String message;
		public String customerId;
        public List<ProductInfo> productsList;
    }
    class ProductInfo{
    	public String productName;
        public String productCode;
        public String productDescription;
        public Decimal odsCredits;
        public List<ProductPrice> productPricesList;  
    } 
    class ProductPrice{
        public String currencyCode;
    	public Decimal listPriceWithVAT;
        public Decimal listPrice;
        public Decimal vatAmount;
    } 
}