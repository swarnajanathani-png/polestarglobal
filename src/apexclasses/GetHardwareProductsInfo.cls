@RestResource(urlMapping='/getHardwareProductsInfo/*')
global with sharing class GetHardwareProductsInfo {
    @HttpGet
    global static void getHardwareProductsInfo() {
        String accountId = '';
        String vesselFlag = '';
        try{
            RestRequest req = RestContext.request;
            accountId = req.params.get('customerid');          
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get Hardware Products';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Account__c = req.params.get('customerid');
            insert apiRequest;        
            apiRequest.Account__c = accountId;
            update apiRequest;
        
            List<Account> listAccounts = [Select Id,Use_Old_Hardware_Price__c,Credit_terms__c,BillingCountry,CurrencyIsoCode,Hardware_Discount__c,Hardware_Discount_EndTime__c,ODP_Customer_Old_SF_Id__c,Parent.Credit_terms__c,Is_Distributor__c,
                                          Parent.Is_Distributor__c, ParentId,SAP_Key__c from Account where id=:accountId];
            if(!listAccounts.isEmpty()){
                Decimal hardwareDiscount = 0;
                if (listAccounts[0].Hardware_Discount__c != null) {
                    hardwareDiscount = listAccounts[0].Hardware_Discount__c;         
                }
        		DateTime hardwareDiscountEndtime = listAccounts[0].Hardware_Discount_EndTime__c;
                List<Product2> lstProducts = new List<Product2>(); 
                if(System.Label.ODPHardwareProducts == 'Old' || listAccounts[0].Use_Old_Hardware_Price__c == true) {
                	lstProducts = [Select Id, Name, ProductCode,SAP_Item_Code__c,Product_Category__c,Description,
                                             Family,Dimensions__c,Weight__c,Generic_Discount__c,Discount_EndTime__c FROM Product2 where Family= 'Hardware'
                                   			AND IsActive = true AND ODP_Product_Temp__c = true];
                }
                else {
                	lstProducts = [Select Id, Name, ProductCode,SAP_Item_Code__c,Product_Category__c,Description,
                                             Family,Generic_Discount__c,Discount_EndTime__c,Dimensions__c,Weight__c FROM Product2 where Family= 'Hardware'
                                   			AND IsActive = true AND ODP_Product__c = true];
    
                }
                DateTime currentDateTime = System.now();
                List<Customer_Discounts__c> customerDiscountsList = new List<Customer_Discounts__c>(); 
                if(System.Label.ODPHardwareProducts == 'Old' || listAccounts[0].Use_Old_Hardware_Price__c == true) {
                	customerDiscountsList = [Select Id, Discount_Percent__c,End_DateTime__c,Product__r.SAP_Item_Code__c FROM Customer_Discounts__c 
                                                             WHERE Account__c =: accountId 
                                             				 AND Product__r.ODP_Product_Temp__c = true
                                                             AND End_DateTime__c > : currentDateTime];
                }
                else {
                	customerDiscountsList = [Select Id, Discount_Percent__c,End_DateTime__c,Product__r.SAP_Item_Code__c FROM Customer_Discounts__c 
                                                             WHERE Account__c =: accountId 
                                             				 AND Product__r.ODP_Product__c = true
                                                             AND End_DateTime__c > : currentDateTime];    
                }
                Map<String,Decimal> customerProductDiscountsMap = new Map<String,Decimal>();
                for(Customer_Discounts__c cd : customerDiscountsList){
                    customerProductDiscountsMap.put(cd.Product__r.SAP_Item_Code__c,cd.Discount_Percent__c);	        
                }
                Set<String> productIdsSet = new Set<String>();
                for(Product2 p : lstProducts){
                	productIdsSet.add(p.Id);	    
                }
                List<PriceBookEntry> hardwarePbe = new List<PriceBookEntry>();   
                if(listAccounts[0].Is_Distributor__c == true || listAccounts[0].Parent.Is_Distributor__c == true) {
                    hardwarePbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode,
                                   Product2.SAP_Item_Code__c,Product2.Generic_Discount__c,Product2.Discount_EndTime__c FROM PriceBookEntry Where Product2.Family = 'Hardware' AND Product2Id IN:productIdsSet  AND Pricebook2.Name like '%Wholesale%']; 
                }
                else {
                    hardwarePbe = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode,
                                   Product2.SAP_Item_Code__c,Product2.Generic_Discount__c,Product2.Discount_EndTime__c FROM PriceBookEntry Where Product2.Family = 'Hardware' AND Product2Id IN:productIdsSet  AND Pricebook2.Name like '%Retail%'];         
                }
                Map<String,List<PriceBookEntry>> productToPriceBookEntriesMap = new Map<String,List<PriceBookEntry>>(); 
                List<PriceBookEntry> pbes = new List<PriceBookEntry>();
                for (PriceBookEntry pbe : hardwarePbe){
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
                        productInfoWrapper.productCategory = product.Product_Category__c;
                        productInfoWrapper.productDescription = product.Description;
                        if(product.Weight__c != null) {
                        	productInfoWrapper.productWeight = String.valueOf(product.Weight__c) + 'kg';    
                        }                        
                        productInfoWrapper.productDimensions = product.Dimensions__c;
                        List<ProductPrice> productPricesList = new List<ProductPrice>();
                        if(productToPriceBookEntriesMap.get(product.Id) != null){
                            for(PriceBookEntry pbe : productToPriceBookEntriesMap.get(product.Id)){
                                Decimal discount = 0;
                                ProductPrice productprice = new ProductPrice();
                                productprice.listPrice = pbe.UnitPrice;
                                productprice.currencyCode = pbe.CurrencyIsoCode;
                                 
                                if (hardwareDiscountEndtime != null && hardwareDiscountEndtime > System.now()) {
                                    discount = discount + hardwareDiscount;       
                                }
                                if(pbe.Product2.Generic_Discount__c >  0 && 
                                   pbe.Product2.Discount_EndTime__c != null && 
                                   pbe.Product2.Discount_EndTime__c > System.now()) {
                                    discount = discount + pbe.Product2.Generic_Discount__c;    
                                }
                                
                                if(customerProductDiscountsMap.get(pbe.Product2.SAP_Item_Code__c) != null ) {
                                    discount = discount + customerProductDiscountsMap.get(pbe.Product2.SAP_Item_Code__c);    
                                }  
                                productprice.discount = discount; 
                                
                                if(discount > 0) {
                                    productprice.discountedPrice = productprice.listPrice - ((productprice.listPrice*discount)/100); 
                                }
                                else {
                                	productprice.discountedPrice = productprice.listPrice;
                                }
                                
                                if(pbe.CurrencyIsoCode == 'AUD'){
                                    productprice.vatAmount = ((productprice.discountedPrice*10)/100).setScale(2, RoundingMode.HALF_UP);     
                                }
                                else if(listAccounts[0].BillingCountry == 'United Kingdom' || listAccounts[0].BillingCountry == 'Isle of Man') {
                                    productprice.vatAmount = ((productprice.discountedPrice*20)/100).setScale(2, RoundingMode.HALF_UP);
                                }                                
                                else{
                                    productprice.vatAmount = 0.00;    
                                }
                                productprice.price = pbe.UnitPrice + productprice.vatAmount;
                                productprice.discountedPriceExcludedVAT = productprice.discountedPrice;
                                productprice.discountedPrice = productprice.discountedPrice + productprice.vatAmount;
                                
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
            		log.Error_Message__c = 'Success: Get Hardware Products for '+accountId;
                    log.Functionality__c = 'Get Hardware Products';
            		insert log;
                }
                else{
                	RestContext.response.addHeader('Content-Type', 'application/json');
                	RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No Hardware Products Found" }');    
                    Error_Log__c log = new Error_Log__c();
                    log.Error_Message__c = 'No Hardware Products Found for customer id '+accountId;
                    log.Functionality__c = 'Get Hardware Products';
                    insert log;    
                }
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Please provide valid customer id" }');    
            	Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Please provide valid customer id '+accountId;
                log.Functionality__c = 'Get Hardware Products';
                insert log;
            }
                    
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+':Error Occurred while getting hardware products for '+accountId;
            log.Functionality__c = 'Get Hardware Products';
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
        public String productWeight;
        public String productDimensions;
        public String productCategory;
        public String productDescription;
        public List<ProductPrice> productPricesList;  
    } 
    class ProductPrice{
        public String currencyCode;
    	public Decimal price;
        public Decimal discountedPrice;
        public Decimal discountedPriceExcludedVAT;
        public Decimal discount;
        public Decimal listPrice;
        public Decimal vatAmount;
    } 
}