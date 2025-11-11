@RestResource(urlMapping='/getHardwareOpportunities/*')
global with sharing class GetHardwareOpportunities {
    @HttpGet
    global static void getHardwareOpportunities() {
        String accountId = '';
        String pson = '';
        String warehouse = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get Hardware Opportunities';
            apiRequest.Product_Type__c = 'Hardware';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = req.params.get('customerid');
            insert apiRequest;
            
            accountId = req.params.get('customerid');
            pson = req.params.get('pson');
            warehouse = req.params.get('warehouse');
            apiRequest.Account__c = accountId;
            update apiRequest;
            
            List<Opportunity> listOpps = new List<Opportunity>();
            if(String.isNotBlank(accountId)) {
                List<Account> listAccounts = [Select Id,Credit_terms__c,ODP_Customer_Old_SF_Id__c,Parent.Credit_terms__c,Is_Distributor__c,
                                              Parent.Is_Distributor__c, ParentId,SAP_Key__c from Account where id=:accountId];
                if(!listAccounts.isEmpty()){
                    String odpCustomerOldSfId = listAccounts[0].ODP_Customer_Old_SF_Id__c;
                    
                    if(String.isBlank(odpCustomerOldSfId)){
                        listOpps = [Select Name,Account.Credit_terms__c,AccountId,Service_PSON__c,
                                                         StageName,CloseDate, Payment_Option__c, CreatedDate,Order_Date__c,CurrencyISOCode,Amount,
                                    					 Delivery_Company__c,Delivery_Address_Line1__c,Delivery_Address_Line2__c,
                                                         Delivery_Address_Line3__c,Delivery_City__c,Delivery_State__c,Delivery_Zip_Code__c,
                                                         Delivery_Country__c,Delivery_Contact_Details__c,Delivery_Email_Recipient__c,Estimated_Delivery_Lead_Time__c,                    
                                    					 Invoice_Company_Name__c,Invoice_Address_Line1__c,Invoice_Address_Line2__c,
                                                         Invoice_Address_Line3__c,Invoice_City__c,Invoice_State__c,Invoice_Zip_Code__c,
                                                         Invoice_Country__c,Purchase_Order_No__c,Finance_Contact_Name__c,
                                                         Finance_Email__c,Finance_Phone__c,Internal_Hardware_Stock_Transfer__c,
                                    					 Warehouse__c,Vessel_Name__c,Tracking_URL__c,Exxegon_dispatch_customer_advised_AWB_no__c,Delivery_Method__c,Delivery_Or_Collection_Status__c,Comments__c,
                                                         Delivery_Type_FreeText__c,Courier_Type_FreeText__c,DHL_FedEx_Account_Number__c,
                                                         Collection_Agent_Name__c,Collection_Agent_Address1__c,Collection_Agent_Address2__c,Collection_Agent_Address3__c,
                                    					 Collection_Agent_City__c,Collection_Agent_State__c,Collection_Agent_Country__c,Collection_Agent_Postal_Code__c,
                                    					Collection_Agent_Mobile__c,Collection_Agent_Phone__c,Collection_Agent_Email__c,
                                    					(Select Id,Product2.Name,Product2.SAP_Item_Code__c,Product2.Description,Serial_Number_Req__c,Serial_Numbers__c,Exegon_Serial_Numbers__c,HS_Code__c,
                                                          Hardware_Stock_Status__c,RMA_Number__c,UnitPrice,TotalPrice,Discounted_Total_Price__c,VAT_Amount__c,Discount,ListPrice,
                                                          Quantity,Arrived_Quantity__c,BatchID__c FROM OpportunityLineItems)FROM Opportunity 
                                                         WHERE AccountId =: accountId 
                                                         AND Type = 'Portal Ondemand Hardware'
                                                         Order by CreatedDate desc,Estimated_Delivery_Lead_Time__c asc NULLS LAST];    
                    }
                    else{
                        listOpps = [Select Name,Account.Credit_terms__c,AccountId,Service_PSON__c,
                                                         StageName,CloseDate, Payment_Option__c, CreatedDate,Order_Date__c,CurrencyISOCode,Amount,
                                                         Delivery_Company__c,Delivery_Address_Line1__c,Delivery_Address_Line2__c,
                                                         Delivery_Address_Line3__c,Delivery_City__c,Delivery_State__c,Delivery_Zip_Code__c,
                                                         Delivery_Country__c,Delivery_Contact_Details__c,Delivery_Email_Recipient__c,Estimated_Delivery_Lead_Time__c,                    
                                    					 Invoice_Company_Name__c,Invoice_Address_Line1__c,Invoice_Address_Line2__c,
                                                         Invoice_Address_Line3__c,Invoice_City__c,Invoice_State__c,Invoice_Zip_Code__c,
                                                         Invoice_Country__c,Purchase_Order_No__c,Finance_Contact_Name__c,
                                                         Finance_Email__c,Finance_Phone__c,Internal_Hardware_Stock_Transfer__c,
                                    					 Warehouse__c,Vessel_Name__c,Tracking_URL__c,Exxegon_dispatch_customer_advised_AWB_no__c,Delivery_Method__c,Delivery_Or_Collection_Status__c,Comments__c,
                                    					 Delivery_Type_FreeText__c,Courier_Type_FreeText__c,DHL_FedEx_Account_Number__c,
                                    					Collection_Agent_Name__c,Collection_Agent_Address1__c,Collection_Agent_Address2__c,Collection_Agent_Address3__c,
                                    					 Collection_Agent_City__c,Collection_Agent_State__c,Collection_Agent_Country__c,Collection_Agent_Postal_Code__c,
                                    					Collection_Agent_Mobile__c,Collection_Agent_Phone__c,Collection_Agent_Email__c,
                                    					(Select Id,Product2.Name,Product2.SAP_Item_Code__c,Product2.Description,Serial_Number_Req__c,Serial_Numbers__c,Exegon_Serial_Numbers__c,HS_Code__c,
                                                          Hardware_Stock_Status__c,RMA_Number__c,UnitPrice,TotalPrice,Discounted_Total_Price__c,VAT_Amount__c,Discount,ListPrice,
                                                          Quantity,Arrived_Quantity__c,BatchID__c FROM OpportunityLineItems)                     
                                    					FROM Opportunity  
                                                         WHERE (AccountId =: accountId Or AccountId =: odpCustomerOldSfId) 
                                                         AND Type = 'Portal Ondemand Hardware'
                                                         Order by CreatedDate desc,Estimated_Delivery_Lead_Time__c asc NULLS LAST];    
                    }
            	}
            }
            else if(String.isNotBlank(pson)) {
                listOpps = [Select Name,Account.Credit_terms__c,AccountId,Service_PSON__c,
                            StageName,CloseDate, Payment_Option__c, CreatedDate,Order_Date__c,CurrencyISOCode,Amount,
                            Delivery_Company__c,Delivery_Address_Line1__c,Delivery_Address_Line2__c,
                                                         Delivery_Address_Line3__c,Delivery_City__c,Delivery_State__c,Delivery_Zip_Code__c,
                                                         Delivery_Country__c,Delivery_Contact_Details__c,Delivery_Email_Recipient__c,Estimated_Delivery_Lead_Time__c,                    
                            Invoice_Company_Name__c,Invoice_Address_Line1__c,Invoice_Address_Line2__c,
                            Invoice_Address_Line3__c,Invoice_City__c,Invoice_State__c,Invoice_Zip_Code__c,
                            Invoice_Country__c,Purchase_Order_No__c,Finance_Contact_Name__c,
                            Finance_Email__c,Finance_Phone__c,Internal_Hardware_Stock_Transfer__c,
                            Warehouse__c,Vessel_Name__c,Tracking_URL__c,Exxegon_dispatch_customer_advised_AWB_no__c,Delivery_Method__c,Delivery_Or_Collection_Status__c,Comments__c,
                            Delivery_Type_FreeText__c,Courier_Type_FreeText__c,DHL_FedEx_Account_Number__c,
                            Collection_Agent_Name__c,Collection_Agent_Address1__c,Collection_Agent_Address2__c,Collection_Agent_Address3__c,
                            Collection_Agent_City__c,Collection_Agent_State__c,Collection_Agent_Country__c,Collection_Agent_Postal_Code__c,
                            Collection_Agent_Mobile__c,Collection_Agent_Phone__c,Collection_Agent_Email__c,
                            (Select Id,Product2.Name,Product2.SAP_Item_Code__c,Product2.Description,Serial_Number_Req__c,Serial_Numbers__c,Exegon_Serial_Numbers__c,HS_Code__c,
                                                          Hardware_Stock_Status__c,RMA_Number__c,UnitPrice,TotalPrice,Discounted_Total_Price__c,VAT_Amount__c,Discount,ListPrice,
                             								Quantity,Arrived_Quantity__c,BatchID__c FROM OpportunityLineItems)
                            FROM Opportunity  
                            WHERE Service_PSON__c=:pson];   	    
            }
            else if(String.isNotBlank(warehouse)){
            	listOpps = [Select Name,Account.Credit_terms__c,AccountId,Service_PSON__c,
                            StageName,CloseDate, Payment_Option__c, CreatedDate,Order_Date__c,CurrencyISOCode,Amount,
                            Delivery_Company__c,Delivery_Address_Line1__c,Delivery_Address_Line2__c,
                                                         Delivery_Address_Line3__c,Delivery_City__c,Delivery_State__c,Delivery_Zip_Code__c,
                                                         Delivery_Country__c,Delivery_Contact_Details__c,Delivery_Email_Recipient__c,Estimated_Delivery_Lead_Time__c,                    
                            Invoice_Company_Name__c,Invoice_Address_Line1__c,Invoice_Address_Line2__c,
                            Invoice_Address_Line3__c,Invoice_City__c,Invoice_State__c,Invoice_Zip_Code__c,
                            Invoice_Country__c,Purchase_Order_No__c,Finance_Contact_Name__c,
                            Finance_Email__c,Finance_Phone__c,Internal_Hardware_Stock_Transfer__c,
                            Warehouse__c,Vessel_Name__c,Tracking_URL__c,Exxegon_dispatch_customer_advised_AWB_no__c,Delivery_Method__c,Delivery_Or_Collection_Status__c,Comments__c,
                            Delivery_Type_FreeText__c,Courier_Type_FreeText__c,DHL_FedEx_Account_Number__c,
                            Collection_Agent_Name__c,Collection_Agent_Address1__c,Collection_Agent_Address2__c,Collection_Agent_Address3__c,
                            Collection_Agent_City__c,Collection_Agent_State__c,Collection_Agent_Country__c,Collection_Agent_Postal_Code__c,
                            Collection_Agent_Mobile__c,Collection_Agent_Phone__c,Collection_Agent_Email__c,
                            (Select Id,Product2.Name,Product2.SAP_Item_Code__c,Product2.Description,Serial_Number_Req__c,Serial_Numbers__c,Exegon_Serial_Numbers__c,HS_Code__c,
                                                          Hardware_Stock_Status__c,RMA_Number__c,UnitPrice,TotalPrice,Discounted_Total_Price__c,VAT_Amount__c,Discount,ListPrice,
                             								Quantity,Arrived_Quantity__c,BatchID__c FROM OpportunityLineItems)
                            FROM Opportunity  
                            WHERE Warehouse__c=:warehouse
                            AND Type = 'Portal Ondemand Hardware'
                            Order by CreatedDate desc,Estimated_Delivery_Lead_Time__c asc NULLS LAST];     
            }
            else {
                listOpps = [Select Name,Account.Credit_terms__c,AccountId,Service_PSON__c,
                            StageName,CloseDate, Payment_Option__c, CreatedDate,Order_Date__c,CurrencyISOCode,Amount,
                            Delivery_Company__c,Delivery_Address_Line1__c,Delivery_Address_Line2__c,
                                                         Delivery_Address_Line3__c,Delivery_City__c,Delivery_State__c,Delivery_Zip_Code__c,
                                                         Delivery_Country__c,Delivery_Contact_Details__c,Delivery_Email_Recipient__c,Estimated_Delivery_Lead_Time__c,                    
                            Invoice_Company_Name__c,Invoice_Address_Line1__c,Invoice_Address_Line2__c,
                            Invoice_Address_Line3__c,Invoice_City__c,Invoice_State__c,Invoice_Zip_Code__c,
                            Invoice_Country__c,Purchase_Order_No__c,Finance_Contact_Name__c,
                            Finance_Email__c,Finance_Phone__c,Internal_Hardware_Stock_Transfer__c,
                            Warehouse__c,Vessel_Name__c,Tracking_URL__c,Exxegon_dispatch_customer_advised_AWB_no__c,Delivery_Method__c,Delivery_Or_Collection_Status__c,Comments__c,
                            Delivery_Type_FreeText__c,Courier_Type_FreeText__c,DHL_FedEx_Account_Number__c,
                            Collection_Agent_Name__c,Collection_Agent_Address1__c,Collection_Agent_Address2__c,Collection_Agent_Address3__c,
                            Collection_Agent_City__c,Collection_Agent_State__c,Collection_Agent_Country__c,Collection_Agent_Postal_Code__c,
                            Collection_Agent_Mobile__c,Collection_Agent_Phone__c,Collection_Agent_Email__c,
                            (Select Id,Product2.Name,Product2.SAP_Item_Code__c,Product2.Description,Serial_Number_Req__c,Serial_Numbers__c,Exegon_Serial_Numbers__c,HS_Code__c,
                                                          Hardware_Stock_Status__c,RMA_Number__c,UnitPrice,TotalPrice,Discounted_Total_Price__c,VAT_Amount__c,Discount,ListPrice,
                             							Quantity,Arrived_Quantity__c,BatchID__c FROM OpportunityLineItems)
                            FROM Opportunity  
                            WHERE Type = 'Portal Ondemand Hardware'
                            AND CreatedDate >= Last_N_Days:90
                            Order by CreatedDate desc,Estimated_Delivery_Lead_Time__c asc NULLS LAST];     
            }
            if(!listOpps.isEmpty()) {  
                HardwareOppWrapper oppObj = new HardwareOppWrapper();
                List<HardwareOpp> hardwareOpps = new List<HardwareOpp>();
                for(Opportunity opp:listOpps){
                    HardwareOpp hardwareOpp= new HardwareOpp();
                    hardwareOpp.pson = opp.Service_PSON__c;
                    if(opp.Internal_Hardware_Stock_Transfer__c == true)
                    {
                    	hardwareOpp.internalStockTransfer = 'Yes';    
                    }
                    else {
                    	hardwareOpp.internalStockTransfer = 'No';     
                    }
                        
                    hardwareOpp.customerid = opp.AccountId;
                    hardwareOpp.currencyCode = opp.CurrencyISOCode;
                    if(opp.Amount != null){
                    	hardwareOpp.amount = String.valueOf(opp.Amount);    
                    }
                    else{
                    	hardwareOpp.amount = '';
                    }
                    
                    hardwareOpp.billingCompanyName = opp.Invoice_Company_Name__c;
                    hardwareOpp.billingAddressLine1 = opp.Invoice_Address_Line1__c;
                    hardwareOpp.billingAddressLine2 = opp.Invoice_Address_Line2__c;
                    hardwareOpp.billingAddressLine3 = opp.Invoice_Address_Line3__c;
                    hardwareOpp.billingCity = opp.Invoice_City__c;
                    hardwareOpp.billingState = opp.Invoice_State__c;
                    hardwareOpp.billingZipcode = opp.Invoice_Zip_Code__c;
                    hardwareOpp.billingCountry = opp.Invoice_Country__c;
                    hardwareOpp.deliveryCompanyName = opp.Delivery_Company__c;
                    hardwareOpp.deliveryAddressLine1 = opp.Delivery_Address_Line1__c;
                    hardwareOpp.deliveryAddressLine2 = opp.Delivery_Address_Line2__c;
                    hardwareOpp.deliveryAddressLine3 = opp.Delivery_Address_Line3__c;
                    hardwareOpp.deliveryCity = opp.Delivery_City__c;
                    hardwareOpp.deliveryState = opp.Delivery_State__c;
                    hardwareOpp.deliveryZipcode = opp.Delivery_Zip_Code__c;
                    hardwareOpp.deliveryCountry = opp.Delivery_Country__c;
                    hardwareOpp.deliveryContactDetails = opp.Delivery_Contact_Details__c;
                    hardwareOpp.deliveryEmail = opp.Delivery_Email_Recipient__c;
                    hardwareOpp.estimatedDeliveryLeadTime = opp.Estimated_Delivery_Lead_Time__c;
                    hardwareOpp.financeEmail = opp.Finance_Email__c;
                    hardwareOpp.financePhone = opp.Finance_Phone__c;
                    hardwareOpp.financeContactName = opp.Finance_Contact_Name__c;
                    hardwareOpp.collectionAgentName = opp.Collection_Agent_Name__c;
                    hardwareOpp.collectionAgentAddressLine1 = opp.Collection_Agent_Address1__c;
                    hardwareOpp.collectionAgentAddressLine2 = opp.Collection_Agent_Address2__c;
                    hardwareOpp.collectionAgentAddressLine3 = opp.Collection_Agent_Address3__c;
                    hardwareOpp.collectionAgentState = opp.Collection_Agent_State__c;
                    hardwareOpp.collectionAgentCity = opp.Collection_Agent_City__c;
                    hardwareOpp.collectionAgentCountry = opp.Collection_Agent_Country__c;
                    hardwareOpp.collectionAgentZipcode = opp.Collection_Agent_Postal_Code__c;
                    hardwareOpp.collectionAgentMobile = opp.Collection_Agent_Mobile__c;
                    hardwareOpp.collectionAgentPhone = opp.Collection_Agent_Phone__c;
                    hardwareOpp.collectionAgentEmail = opp.Collection_Agent_Email__c;
                    
                    DateTime closeDate = opp.CloseDate;
                    if(closeDate != null) {
                    	hardwareOpp.closeDate = String.valueOf(closeDate.date());
                    }
                    hardwareOpp.purchaseOrderNo = opp.Purchase_Order_No__c;
                    hardwareOpp.psonStatus = opp.StageName;
                    hardwareOpp.paymentOption = opp.Payment_Option__c;
                    hardwareOpp.trackingURL = opp.Tracking_URL__c;
                    hardwareOpp.awbReferenceNo = opp.Exxegon_dispatch_customer_advised_AWB_no__c;
                    hardwareOpp.deliveryMethod = opp.Delivery_Method__c;
                    hardwareOpp.deliveryType = opp.Delivery_Type_FreeText__c;
                    hardwareOpp.courierType = opp.Courier_Type_FreeText__c;
                    hardwareOpp.DHLOrFedExAccNum = opp.DHL_FedEx_Account_Number__c;
                    hardwareOpp.deliveryOrCollectionStatus = opp.Delivery_Or_Collection_Status__c;
                    hardwareOpp.comments = opp.Comments__c;
                    hardwareOpp.warehouse = opp.Warehouse__c;
                    hardwareOpp.vesselName = opp.Vessel_Name__c;
                    hardwareOpp.createdDate = String.valueOf(opp.CreatedDate.date());
                    if(opp.Order_Date__c != null) {
                    	hardwareOpp.orderDate = String.valueOf(opp.Order_Date__c.date());
                    }
                    else{
                    	hardwareOpp.orderDate = null;    
                    }
                    Decimal totalVAT = 0;
                    List<HardwareOppLine> hardwareOppLines = new List<HardwareOppLine>();
                    for(OpportunityLineItem opl : opp.OpportunityLineItems){
                    	HardwareOppLine hardwareOppLine = new HardwareOppLine();
                        hardwareOppLine.oppLineId = opl.Id;
                        hardwareOppLine.productName = opl.Product2.Name;
                        hardwareOppLine.productCode = opl.Product2.SAP_Item_Code__c;
                        hardwareOppLine.productDescription = opl.Product2.Description;
                        if(opl.Serial_Number_Req__c == true){
                        	hardwareOppLine.isSerialNumberReq = 'true';    
                        }
                        else{
                        	hardwareOppLine.isSerialNumberReq = 'false';      
                        }                        
                        hardwareOppLine.serialNumber = opl.Serial_Numbers__c;
                        hardwareOppLine.exegonSerialNumber = opl.Exegon_Serial_Numbers__c;
                        hardwareOppLine.hscode = opl.HS_Code__c;
                        hardwareOppLine.RMANumber = opl.RMA_Number__c;
                        hardwareOppLine.hardwareStockStatus = opl.Hardware_Stock_Status__c;
                        //hardwareOppLine.price = opl.ListPrice + opl.VAT_Amount__c;
                        if(opl.VAT_Amount__c > 0) {
                        	hardwareOppLine.price = (opl.UnitPrice*opl.Quantity) + opl.VAT_Amount__c;
                            totalVAT = totalVAT + opl.VAT_Amount__c;
                        }
                        else {
                        	hardwareOppLine.price = opl.UnitPrice*opl.Quantity;    
                        }
                        if(opl.Discount > 0) {
                        	hardwareOppLine.discountedPriceExcludedVAT = opl.UnitPrice - ((opl.UnitPrice*opl.Discount)/100); //discountedPriceExcludedVAT is Unit Price after discount    
                        }
                        else{
                        	hardwareOppLine.discountedPriceExcludedVAT = opl.UnitPrice;    
                        }
                        
                        hardwareOppLine.discountedPrice = opl.Discounted_Total_Price__c;
                        hardwareOppLine.vatAmount = opl.VAT_Amount__c;
                        hardwareOppLine.listPrice = opl.UnitPrice;
                        hardwareOppLine.discount = opl.Discount;
                        hardwareOppLine.quantity = Integer.valueOf(opl.Quantity);
                        hardwareOppLine.arrivedQuantity = Integer.valueOf(opl.Arrived_Quantity__c);
                        hardwareOppLine.batchId = opl.BatchID__c;
                        hardwareOppLines.add(hardwareOppLine);
                    }
                    hardwareOpp.hardwareOppLines = hardwareOppLines; 
                    hardwareOpp.totalAmountWithoutVAT = opp.amount;
                    hardwareOpp.totalAmountWithVAT = opp.amount + totalVAT;
                    hardwareOpp.totalVAT = totalVAT;
                    hardwareOpps.add(hardwareOpp);
                }
                oppObj.hardwareOpps = hardwareOpps;                
                oppObj.statuscode = '200';
                oppObj.message = 'success';
                String jsonString = JSON.serialize(oppObj);
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Get Hardware Opportunities Success:'+accountId;
                log.Functionality__c = 'Get Hardware Opportunities';
                insert log;
            }
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No Opportunities Found" }');    
            }
        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+accountId;
            log.Functionality__c = 'Get Hardware Opportunities';
            insert log;
        }
    }
    
    class HardwareOppWrapper{
        public String statuscode;
        public String message;
        public List<HardwareOpp> hardwareOpps;        
    }
    class HardwareOpp{
    	public String pson;
        public String internalStockTransfer;
        public String customerid;
        public String currencyCode;
        public String amount;
        public Decimal totalAmountWithoutVAT;
        public Decimal totalAmountWithVAT;
        public Decimal totalVAT;
        public String billingCompanyName;
        public String billingAddressLine1;
        public String billingAddressLine2;
        public String billingAddressLine3;
        public String billingCity;
        public String billingState;
        public String billingZipcode;
        public String billingCountry;
        public String collectionAgentName;
        public String collectionAgentAddressLine1;
        public String collectionAgentAddressLine2;
        public String collectionAgentAddressLine3;
        public String collectionAgentCity;
        public String collectionAgentState;
        public String collectionAgentZipcode;
        public String collectionAgentCountry;
        public String collectionAgentPhone;
        public String collectionAgentMobile;
        public String collectionAgentEmail;
        public String deliveryCompanyName;
        public String deliveryAddressLine1;
        public String deliveryAddressLine2;
        public String deliveryAddressLine3;
        public String deliveryCity;
        public String deliveryState;
        public String deliveryZipcode;
        public String deliveryCountry;
        public String deliveryContactDetails;
        public String deliveryEmail;
        public String estimatedDeliveryLeadTime;
        public String purchaseOrderNo;
        public String financeEmail;
        public String financePhone;
        public String financeContactName;
        public String closeDate;
        public String psonStatus;
        public String paymentOption;
        public String trackingURL;
        public String awbReferenceNo;
        public String deliveryMethod;
        public String deliveryType;
        public String courierType;
        public String DHLOrFedExAccNum;
        public String deliveryOrCollectionStatus;
   		public String comments;
        public String warehouse;
        public String vesselName;
        public String createdDate;
        public String orderDate;
        public List<HardwareOppLine> hardwareOppLines;
        
    } 
    class HardwareOppLine{
        public String oppLineId;
        public String productName;
        public String productCode;
        public String productDescription;
        public String isSerialNumberReq;
        public String serialNumber;
        public String exegonSerialNumber;
        public String hscode;
        public String RMANumber;
        public String hardwareStockStatus;
        public Integer quantity;
        public Integer arrivedQuantity;
        public String batchId;
        public Decimal price;
        public Decimal discountedPrice;
        public Decimal discountedPriceExcludedVAT;
        public Decimal discount;
        public Decimal listPrice;
        public Decimal vatAmount;
    }
}