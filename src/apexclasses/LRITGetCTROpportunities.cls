@RestResource(urlMapping='/getCTROpportunities/*')
global with sharing class LRITGetCTROpportunities {
    @HttpGet
    global static void getCTROpportunities() {
        String accountId = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get CTR Opportunities';
            apiRequest.Product_Type__c = 'LRIT CTR';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = 'CustomerId: '+ req.params.get('customerid') 
                						+ ', SearchString: ' + req.params.get('searchstring')
                						+ ', RecordCount: ' + req.params.get('recordcount')
                						+ ', PageNumber: ' + req.params.get('pagenumber');
            insert apiRequest;
            
            accountId = req.params.get('customerid');
            Integer recordCount = 100;
            Integer pageNumber = 0;
            Integer offsetRecords = 0;
            String searchString = req.params.get('searchstring');
            if(String.isNotBlank(req.params.get('recordcount'))){
            	recordCount = Integer.valueOf(req.params.get('recordcount'));      
            }
            if(String.isNotBlank(req.params.get('pagenumber'))){
            	pageNumber = Integer.valueOf(req.params.get('pagenumber'));     
            }
            if(recordCount > 0 && pageNumber > 0) {
                offsetRecords = pageNumber * recordCount;
            }
            apiRequest.Account__c = accountId;
            update apiRequest;
        
            List<Account> listAccounts = [Select Id,Credit_terms__c,ODP_Customer_Old_SF_Id__c,Parent.Credit_terms__c,Is_Distributor__c,
                                          Parent.Is_Distributor__c, ParentId,SAP_Key__c from Account where id=:accountId];
            if(!listAccounts.isEmpty()){
                String odpCustomerOldSfId = listAccounts[0].ODP_Customer_Old_SF_Id__c;
                List<LRIT_CTR_Request__c> listCTRs = new List<LRIT_CTR_Request__c>();
                List<LRIT_CTR_Request__c> totalCTRs = new List<LRIT_CTR_Request__c>();
                if(String.isBlank(odpCustomerOldSfId)){
                    if(String.isBlank(searchString) || searchString == null || searchString == 'null'){
                    	totalCTRs =[Select Id FROM LRIT_CTR_Request__c WHERE Opportunity__r.AccountId =: accountId 
                                                     AND Status__c != 'Pending Payment']; 
                		listCTRs = [Select Name,Status__c,LRIT_CTR_Status__c,Account__r.Credit_terms__c,Account__r.Id,Opportunity__r.AccountId,Opportunity__r.Service_PSON__c,
                                                     Opportunity__r.StageName,Opportunity__r.CloseDate, Opportunity__r.Payment_Option__c, Pole_Star_LRIT_Test_Number__c,
                                                     LRIT_Conformance_Test__r.Test_Finish_Date__c,Port__c,MMSI__c,IMN__c,Call_Sign__c,Vessel_Flag__c,
                                                     Gross_Tonnage__c,New_Sea_Areas__c,Vessel_Name__c,IMO_Number__c,Transceiver_Make__c,
                                                     Transceiver_Model__c,Equipment_Serial_Number__c,Transceiver_Type__c,LRIT_Conformance_Test__r.Ship_Type__c,
                                                     Due_for_printing_date__c,CreatedDate,Opportunity__r.Order_Date__c,Opportunity__r.CurrencyISOCode,Opportunity__r.Amount,
                                                     Opportunity__r.Invoice_Company_Name__c,Opportunity__r.Invoice_Address_Line1__c,Opportunity__r.Invoice_Address_Line2__c,
                                                     Opportunity__r.Invoice_Address_Line3__c,Opportunity__r.Invoice_City__c,Opportunity__r.Invoice_State__c,Opportunity__r.Invoice_Zip_Code__c,
                                                     Opportunity__r.Invoice_Country__c,Opportunity__r.Purchase_Order_No__c,Opportunity__r.Finance_Contact_Name__c,
                                                     Opportunity__r.Finance_Email__c,Opportunity__r.Finance_Phone__c,Delivery_Option__c
                                                     FROM LRIT_CTR_Request__c 
                                                     WHERE Opportunity__r.AccountId =: accountId 
                                                     AND Status__c != 'Pending Payment'
                                                     Order by CreatedDate desc LIMIT:recordCount OFFSET:offsetRecords ];    
    
                    }
                    else {
                    	totalCTRs =[Select Id FROM LRIT_CTR_Request__c WHERE Opportunity__r.AccountId =: accountId 
                                                     AND Status__c != 'Pending Payment'
                                   					 AND (Pole_Star_LRIT_Test_Number__c LIKE  :('%' + searchString + '%')
                                                          OR Vessel_Name__c LIKE :('%' + searchString + '%')
                                                          OR IMO_Number__c LIKE :('%' + searchString + '%')
                                                          OR Opportunity__r.Service_PSON__c LIKE :('%' + searchString + '%')
                                                          OR NAME LIKE :('%' + searchString + '%')
                                                          OR Vessel_Flag__c LIKE :('%' + searchString + '%')
                                                         )
                                   ]; 
                		listCTRs = [Select Name,Status__c,LRIT_CTR_Status__c,Account__r.Credit_terms__c,Account__r.Id,Opportunity__r.AccountId,Opportunity__r.Service_PSON__c,
                                                     Opportunity__r.StageName,Opportunity__r.CloseDate, Opportunity__r.Payment_Option__c, Pole_Star_LRIT_Test_Number__c,
                                                     LRIT_Conformance_Test__r.Test_Finish_Date__c,Port__c,MMSI__c,IMN__c,Call_Sign__c,Vessel_Flag__c,
                                                     Gross_Tonnage__c,New_Sea_Areas__c,Vessel_Name__c,IMO_Number__c,Transceiver_Make__c,
                                                     Transceiver_Model__c,Equipment_Serial_Number__c,Transceiver_Type__c,LRIT_Conformance_Test__r.Ship_Type__c,
                                                     Due_for_printing_date__c,CreatedDate,Opportunity__r.Order_Date__c,Opportunity__r.CurrencyISOCode,Opportunity__r.Amount,
                                                     Opportunity__r.Invoice_Company_Name__c,Opportunity__r.Invoice_Address_Line1__c,Opportunity__r.Invoice_Address_Line2__c,
                                                     Opportunity__r.Invoice_Address_Line3__c,Opportunity__r.Invoice_City__c,Opportunity__r.Invoice_State__c,Opportunity__r.Invoice_Zip_Code__c,
                                                     Opportunity__r.Invoice_Country__c,Opportunity__r.Purchase_Order_No__c,Opportunity__r.Finance_Contact_Name__c,
                                                     Opportunity__r.Finance_Email__c,Opportunity__r.Finance_Phone__c,Delivery_Option__c
                                                     FROM LRIT_CTR_Request__c 
                                                     WHERE Opportunity__r.AccountId =: accountId 
                                                     AND Status__c != 'Pending Payment'
                                    				 AND (Pole_Star_LRIT_Test_Number__c LIKE  :('%' + searchString + '%')
                                                          OR Vessel_Name__c LIKE :('%' + searchString + '%')
                                                          OR IMO_Number__c LIKE :('%' + searchString + '%')
                                                          OR Opportunity__r.Service_PSON__c LIKE :('%' + searchString + '%')
                                                          OR NAME LIKE :('%' + searchString + '%')
                                                          OR Vessel_Flag__c LIKE :('%' + searchString + '%')
                                                         )
                                                     Order by CreatedDate desc LIMIT:recordCount OFFSET:offsetRecords ];    
    
                    }
                }
                else{
                    if(String.isBlank(searchString) || searchString == null || searchString == 'null'){
                        totalCTRs =[Select Id FROM LRIT_CTR_Request__c WHERE (Opportunity__r.AccountId =: accountId Or Opportunity__r.AccountId =: odpCustomerOldSfId)
                                                     AND Status__c != 'Pending Payment']; 
                    	listCTRs = [Select Name,Status__c,LRIT_CTR_Status__c,Account__r.Credit_terms__c,Account__r.Id,Opportunity__r.AccountId,Opportunity__r.Service_PSON__c,
                                                     Opportunity__r.StageName,Opportunity__r.CloseDate, Opportunity__r.Payment_Option__c, Pole_Star_LRIT_Test_Number__c,
                                                     LRIT_Conformance_Test__r.Test_Finish_Date__c,Port__c,MMSI__c,IMN__c,Call_Sign__c,Vessel_Flag__c,
                                                     Gross_Tonnage__c,New_Sea_Areas__c,Vessel_Name__c,IMO_Number__c,Transceiver_Make__c,
                                                     Transceiver_Model__c,Equipment_Serial_Number__c,Transceiver_Type__c,LRIT_Conformance_Test__r.Ship_Type__c,
                                                     Due_for_printing_date__c,CreatedDate,Opportunity__r.Order_Date__c,Opportunity__r.CurrencyISOCode,Opportunity__r.Amount,
                                                     Opportunity__r.Invoice_Company_Name__c,Opportunity__r.Invoice_Address_Line1__c,Opportunity__r.Invoice_Address_Line2__c,
                                                     Opportunity__r.Invoice_Address_Line3__c,Opportunity__r.Invoice_City__c,Opportunity__r.Invoice_State__c,Opportunity__r.Invoice_Zip_Code__c,
                                                     Opportunity__r.Invoice_Country__c,Opportunity__r.Purchase_Order_No__c,Opportunity__r.Finance_Contact_Name__c,
                                                     Opportunity__r.Finance_Email__c,Opportunity__r.Finance_Phone__c,Delivery_Option__c
                                                     FROM LRIT_CTR_Request__c 
                                                     WHERE (Opportunity__r.AccountId =: accountId Or Opportunity__r.AccountId =: odpCustomerOldSfId) 
                                                     AND Status__c != 'Pending Payment'
                                                     Order by CreatedDate desc LIMIT:recordCount OFFSET:offsetRecords];
                    }
                    else {
                    	totalCTRs =[Select Id FROM LRIT_CTR_Request__c WHERE (Opportunity__r.AccountId =: accountId Or Opportunity__r.AccountId =: odpCustomerOldSfId)
                                                     AND Status__c != 'Pending Payment'
                                    				 AND (Pole_Star_LRIT_Test_Number__c LIKE  :('%' + searchString + '%')
                                                          OR Vessel_Name__c LIKE :('%' + searchString + '%')
                                                          OR IMO_Number__c LIKE :('%' + searchString + '%')
                                                          OR Opportunity__r.Service_PSON__c LIKE :('%' + searchString + '%')
                                                          OR NAME LIKE :('%' + searchString + '%')
                                                          OR Vessel_Flag__c LIKE :('%' + searchString + '%')
                                                         )
                                   ]; 
                    	listCTRs = [Select Name,Status__c,LRIT_CTR_Status__c,Account__r.Credit_terms__c,Account__r.Id,Opportunity__r.AccountId,Opportunity__r.Service_PSON__c,
                                                     Opportunity__r.StageName,Opportunity__r.CloseDate, Opportunity__r.Payment_Option__c, Pole_Star_LRIT_Test_Number__c,
                                                     LRIT_Conformance_Test__r.Test_Finish_Date__c,Port__c,MMSI__c,IMN__c,Call_Sign__c,Vessel_Flag__c,
                                                     Gross_Tonnage__c,New_Sea_Areas__c,Vessel_Name__c,IMO_Number__c,Transceiver_Make__c,
                                                     Transceiver_Model__c,Equipment_Serial_Number__c,Transceiver_Type__c,LRIT_Conformance_Test__r.Ship_Type__c,
                                                     Due_for_printing_date__c,CreatedDate,Opportunity__r.Order_Date__c,Opportunity__r.CurrencyISOCode,Opportunity__r.Amount,
                                                     Opportunity__r.Invoice_Company_Name__c,Opportunity__r.Invoice_Address_Line1__c,Opportunity__r.Invoice_Address_Line2__c,
                                                     Opportunity__r.Invoice_Address_Line3__c,Opportunity__r.Invoice_City__c,Opportunity__r.Invoice_State__c,Opportunity__r.Invoice_Zip_Code__c,
                                                     Opportunity__r.Invoice_Country__c,Opportunity__r.Purchase_Order_No__c,Opportunity__r.Finance_Contact_Name__c,
                                                     Opportunity__r.Finance_Email__c,Opportunity__r.Finance_Phone__c,Delivery_Option__c
                                                     FROM LRIT_CTR_Request__c 
                                                     WHERE (Opportunity__r.AccountId =: accountId Or Opportunity__r.AccountId =: odpCustomerOldSfId) 
                                                     AND Status__c != 'Pending Payment'
                                    				 AND (Pole_Star_LRIT_Test_Number__c LIKE  :('%' + searchString + '%')
                                                          OR Vessel_Name__c LIKE :('%' + searchString + '%')
                                                          OR IMO_Number__c LIKE :('%' + searchString + '%')
                                                          OR Opportunity__r.Service_PSON__c LIKE :('%' + searchString + '%')
                                                          OR NAME LIKE :('%' + searchString + '%')
                                                          OR Vessel_Flag__c LIKE :('%' + searchString + '%')
                                                         )
                                                     Order by CreatedDate desc LIMIT:recordCount OFFSET:offsetRecords];    
                    }
                	    
                }
                
                LRITConformanceTestReports ctrObj = new LRITConformanceTestReports();
                ctrObj.customerId = accountId;
                if(listAccounts[0].ParentId != null && listAccounts[0].Parent.Is_Distributor__c == true) {
                    ctrObj.creditTerms = listAccounts[0].Parent.Credit_terms__c;
                }
                else{
                	ctrObj.creditTerms = listAccounts[0].Credit_terms__c;    
                }
                ctrObj.sapKey = listAccounts[0].SAP_Key__c;
                ctrObj.numberOfRecords = totalCTRs.size(); 
                //Fasttrack Price
                List<PriceBookEntry> fasttrackPbeList = new List<PriceBookEntry>(); 
                Map<String,PriceBookEntry> currencyPbeMap = new Map<String,PriceBookEntry>();
                fasttrackPbeList = [Select Id,Product2Id,Product2.Name,UnitPrice,CurrencyIsoCode FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000212'
                                AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];
                for(PriceBookEntry pbe : fasttrackPbeList){
                	currencyPbeMap.put(pbe.CurrencyIsoCode,pbe);    
                }
                List<Holiday> listHolidays = [Select Id,ActivityDate  from Holiday];
                List<LRITConformanceTestReports.ConformanceTestRequest> ctrs = new List<LRITConformanceTestReports.ConformanceTestRequest>();
                for(LRIT_CTR_Request__c ctr:listCTRs){
                    LRITConformanceTestReports.ConformanceTestRequest ctrInfo= new LRITConformanceTestReports.ConformanceTestRequest();
                    ctrInfo.pson = ctr.Opportunity__r.Service_PSON__c;
                    ctrInfo.currencyCode = ctr.Opportunity__r.CurrencyISOCode;
                    if(ctr.Opportunity__r.Amount != null){
                    	ctrInfo.amount = String.valueOf(ctr.Opportunity__r.Amount);    
                    }
                    else{
                    	ctrInfo.amount = '';
                    }
                    ctrInfo.billingCompanyName = ctr.Opportunity__r.Invoice_Company_Name__c;
                    ctrInfo.billingAddressLine1 = ctr.Opportunity__r.Invoice_Address_Line1__c;
                    ctrInfo.billingAddressLine2 = ctr.Opportunity__r.Invoice_Address_Line2__c;
                    ctrInfo.billingAddressLine3 = ctr.Opportunity__r.Invoice_Address_Line3__c;
                    ctrInfo.billingCity = ctr.Opportunity__r.Invoice_City__c;
                    ctrInfo.billingState = ctr.Opportunity__r.Invoice_State__c;
                    ctrInfo.billingZipcode = ctr.Opportunity__r.Invoice_Zip_Code__c;
                    ctrInfo.billingCountry = ctr.Opportunity__r.Invoice_Country__c;
                    ctrInfo.purchaseOrderNo = ctr.Opportunity__r.Purchase_Order_No__c;
                    ctrInfo.financeEmail = ctr.Opportunity__r.Finance_Email__c;
                    ctrInfo.financePhone = ctr.Opportunity__r.Finance_Phone__c;
                    ctrInfo.financeContactName = ctr.Opportunity__r.Finance_Contact_Name__c;
                    
                    Decimal ftPrice = 0;
                    if(currencyPbeMap.get(ctrInfo.currencyCode) != null) {
                            Decimal price = 0;
                            Decimal vatPrice = 0;
                            
                            price = currencyPbeMap.get(ctrInfo.currencyCode).UnitPrice;
                            
                            if((ctr.Opportunity__r.Invoice_Country__c == 'United Kingdom' 
                                || ctr.Opportunity__r.Invoice_Country__c == 'Isle of Man')
                               && listAccounts[0].Is_Distributor__c == false && listAccounts[0].Parent.Is_Distributor__c == false) {
                                   vatPrice = (price*20)/100;
                            }
                            ftPrice = price + vatPrice;
                    }
                    ctrInfo.fasttrackPrice = String.valueOf(ftPrice); 
                    DateTime closeDate = ctr.Opportunity__r.CloseDate;
                    if(closeDate != null) {
                    	ctrInfo.closeDate = String.valueOf(closeDate.date());
                    }
                    ctrInfo.psonStatus = ctr.Opportunity__r.StageName;
                    ctrInfo.ctrRequestNumber = ctr.Name;
                    ctrInfo.ctrRequestStatus = ctr.Status__c;
                    ctrInfo.ctrStatus = ctr.LRIT_CTR_Status__c;
                    ctrInfo.paymentOption = ctr.Opportunity__r.Payment_Option__c;
                   /* if(ctr.Opportunity__c != null) {
                        if(ctrInfo.paymentOption == 'Credit Terms'){
                            ctrInfo.ctrPaymentStatus = 'Invoiced';     
                        }
                        else if(ctrInfo.paymentOption == 'ProformaInvoice' || ctrInfo.paymentOption == 'Payment Not Required'){
                            ctrInfo.ctrPaymentStatus = 'Paid';     
                        }
                        else {
                            ctrInfo.ctrPaymentStatus = '';       
                        }
                    }
                    else*/
                    if(ctrInfo.ctrRequestStatus == 'Cancelled'){
                    	ctrInfo.ctrPaymentStatus = 'Cancelled';  
                        ctrInfo.showCancel = false;
                        ctrInfo.showFastTrack = false;
                    }
                    else if(ctrInfo.paymentOption == 'Credit Terms' && (ctrInfo.ctrRequestStatus == 'Released for Printing'
                                                                   || ctrInfo.ctrRequestStatus == 'Completed')) {
                    	ctrInfo.ctrPaymentStatus = 'Invoiced'; 
                        ctrInfo.showCancel = false;                                                
                    }
                    else if(ctrInfo.ctrRequestStatus == 'Released for Printing' || ctrInfo.ctrRequestStatus == 'Completed') {
                    	ctrInfo.ctrPaymentStatus = 'Paid';   
                        ctrInfo.showCancel = false;
                    }
                    else {
                        ctrInfo.ctrPaymentStatus = 'Pending';
                        ctrInfo.showCancel = true;
                    }
                    if((ctrInfo.ctrPaymentStatus == 'Pending' 
                        || ctrInfo.ctrPaymentStatus == 'Paid' 
                        || ctrInfo.ctrPaymentStatus == 'Invoiced')
                       && ctr.Delivery_Option__c == 'Standard'
                       && ctrInfo.paymentOption != 'ProformaInvoice'
                       && ctrInfo.paymentOption != 'Payment Not Required') {
                        
                    	DateTime fastTrackUpgradeDuedate = ctr.Opportunity__r.Order_Date__c;
                        Boolean ftUpgradeDueDateHoliday = false;
                        if(fastTrackUpgradeDuedate != null) {
                            fastTrackUpgradeDuedate = fastTrackUpgradeDuedate + 1; 
                        	 
                            do{
                                //Checking whether its holiday
                                for(Holiday h:listHolidays){
                                    if(h.ActivityDate == Date.valueOf(fastTrackUpgradeDuedate)) {
                                        ftUpgradeDueDateHoliday = true; 
                                        fastTrackUpgradeDuedate = fastTrackUpgradeDuedate + 1;
                                    }
                                    else {
                                        ftUpgradeDueDateHoliday = false;    
                                    }
                                }
                                //Checking whether its weekend
                                if(ftUpgradeDueDateHoliday == false) {
                                    String dayOfWeek = fastTrackUpgradeDuedate.format('EEEE');
                                    if(dayOfWeek == 'Sunday' || dayOfWeek == 'Saturday'){
                                        ftUpgradeDueDateHoliday = true; 
                                        fastTrackUpgradeDuedate = fastTrackUpgradeDuedate + 1;    
                                    }
                               }
                                
                            }while(ftUpgradeDueDateHoliday);
                            
                            if(Date.valueOf(fastTrackUpgradeDuedate) > System.today()){
                            	ctrInfo.showFastTrack = true; 
                                if(ctr.Delivery_Option__c == 'Standard' && ctrInfo.ctrPaymentStatus == 'Invoiced') {
                        			ctrInfo.showCancel = true; 
                                }
                       		}
                            else {
                            	ctrInfo.showFastTrack = false; 
                            }
                                                                
                        }
                        else {
                        	ctrInfo.showFastTrack = false;       
                        }
                    }
                    else {
                    	ctrInfo.showFastTrack = false;    
                    }
                    ctrInfo.polestarTestNumber = ctr.Pole_Star_LRIT_Test_Number__c;
                    Date testFinishDate = ctr.LRIT_Conformance_Test__r.Test_Finish_Date__c;
                    if(testFinishDate != null){
                    ctrInfo.testEndDate = String.valueOf(testFinishDate); 
                    }
                    ctrInfo.portOfRegistry = ctr.Port__c;
                    ctrInfo.mmsi = ctr.MMSI__c;
                    ctrInfo.callsign = ctr.Call_Sign__c;
                    ctrInfo.vesselFlag = ctr.Vessel_Flag__c;
                    ctrInfo.seaAreas = ctr.New_Sea_Areas__c;
                    ctrInfo.grossTonnage = ctr.Gross_Tonnage__c;
                    ctrInfo.transceiverMobileNumber = ctr.IMN__c;
                    ctrInfo.transceiverManufacturer = ctr.Transceiver_Make__c;
                    ctrInfo.transceiverModel = ctr.Transceiver_Model__c;
                    ctrInfo.transceiverSerialNumber = ctr.Equipment_Serial_Number__c;
                    ctrInfo.transceiverType = ctr.Transceiver_Type__c;
                    ctrInfo.vesselName = ctr.Vessel_Name__c;
                    ctrInfo.imo = ctr.IMO_Number__c;
                    ctrInfo.shipType = ctr.LRIT_Conformance_Test__r.Ship_Type__c;
                    Date dueDateForPrint = ctr.Due_for_printing_date__c;
                    if(dueDateForPrint != null) {
                    	ctrInfo.dueDateForPrint = String.valueOf(dueDateForPrint);
                    }
                    ctrInfo.createdDate = String.valueOf(ctr.CreatedDate.date());
                    if(ctr.Opportunity__r.Order_Date__c != null) {
                    	ctrInfo.orderDate = String.valueOf(ctr.Opportunity__r.Order_Date__c.date());
                    }
                    else{
                    	ctrInfo.orderDate = null;    
                    }
                    ctrInfo.deliveryOption = ctr.Delivery_Option__c;
                    ctrs.add(ctrInfo);
                }
                ctrObj.ctrs = ctrs;
                ctrObj.statuscode = '200';
                ctrObj.message = 'success';
                String jsonString = JSON.serialize(ctrObj);
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(jsonString);
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Get CTR Opportunities Success:'+accountId;
                log.Functionality__c = 'Get CTR Opportunities';
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
            log.Functionality__c = 'Get CTR Opportunities';
            insert log;
        }
    }
}