@RestResource(urlMapping='/CreateCTROpportuntity/*')
global with sharing class LRITCTROpportunityRestService {
    @HttpPost
    global static void postOpportunity() {
        Map<String, Object> m = new Map<String, Object>();
        API_Request__c apiRequest = new API_Request__c();
        apiRequest.Name = 'Create CTR Opportunity';
        apiRequest.Product_Type__c = 'LRIT CTR';
        apiRequest.Request_Type__c = 'Inbound';
        apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
        insert apiRequest; 
        // Create a savepoint while AccountNumber is null 
		Savepoint sp = Database.setSavepoint(); 
        try{
                       
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
        Object Opportunity = (Object)params.get('Opportunity');
        m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Opportunity));
        Contact con = new Contact();
        String accountId = (String) m.get('CustomerId');
        String email = (String) m.get('DeliveryContactEmail');
        String firstName = (String) m.get('DeliveryFirstName');
        String lastName = (String) m.get('DeliveryContactLastName');
        String fullName = firstName + ' '+ lastName;
        
        apiRequest.Account__c = accountId;
        update apiRequest;
            
        List<Account> lstAccounts = [Select Id, ParentId,Parent.Credit_terms__c,Credit_terms__c From Account where Id=:accountId];
        List<Contact> contactsList = [Select Id from Contact Where (AccountId=:accountId and FirstName=:firstName and LastName=:lastName
         							and Email =: email) OR (AccountId=:accountId and LastName=:fullName
         							and Email =: email) Limit 1];
        String contactId = '';
        if(!contactsList.isEmpty()){
        	contactId = contactsList[0].Id;	  
        }
        else{
        	con.accountId = accountId;
        	con.FirstName = firstName;
            con.LastName = lastName;
            con.Email = email;
            con.Phone = (String) m.get('DeliveryContactPhone');
            con.MobilePhone = (String) m.get('DeliveryContactMobile');
         	insert con;
            contactId = con.Id;
        }
        
        
        Opportunity opp = new Opportunity();
        String vesselName = (String) m.get('VesselName');
        String imoNumer = (String) m.get('IMONumber');
        String transManufacture = (String) m.get('TransceiverManufacturer');
        String transModel = (String) m.get('TransceiverModel');
        String transNumber = (String) m.get('TransceiverSerialNumber');
        String transMobileNumber = (String) m.get('TransceiverMobileNumber');
        String currencyType = (String) m.get('PaymentCurrency');
        String flagName = (String) m.get('FlagName'); 
        String paymentOption = (String) m.get('PaymentOption');
        String ctRecordId = (String) m.get('CTRecordId');
        String isFreeCTR = (String) m.get('IsFreeCTR');
            
        opp.Name = vesselName + ' - ' + imoNumer + ' - ' + transManufacture + ' - ' + transModel + ' - ' + System.today();
        opp.AccountId = accountId;
        opp.Contact_Person1__c = contactId;
        opp.Product_Type__c = 'LRIT Conformance Test Report';
		opp.Type = 'Portal Conformance Test Report';
        if((lstAccounts[0].Credit_terms__c == 'Payment on invoice' ||
            (String.isNotBlank(lstAccounts[0].ParentId)) && lstAccounts[0].Parent.Credit_terms__c == 'Payment on invoice') 
            && paymentOption == 'Credit Terms'){
        	opp.StageName ='Closed Won';
        } 
        else if(paymentOption == 'Payment Not Required'){
        	opp.StageName ='Closed Won';        
        }
        else if(isFreeCTR == 'true' || isFreeCTR=='TRUE'){
        	opp.StageName ='Closed Won';         
        }
        else{
        	opp.StageName ='Closed Received';    
        }
        opp.CloseDate = System.today();
        opp.Order_Date__c = System.now();
        opp.CurrencyIsoCode = currencyType;
        opp.Currency__c = currencyType;
        //opp.Pricebook2Id = '01s200000000BIgAAM';
        String billingName = (String) m.get('BillingName');
        String billingAddressLine1 = (String) m.get('BillingAddressLine1');
        String billingAddressLine2 = (String) m.get('BillingAddressLine2');
        String billingAddressLine3 = (String) m.get('BillingAddressLine3');
        String billingCity = (String) m.get('BillingCity');
        String billingState = (String) m.get('BillingStateOrProvince');
        String billingCountry = (String) m.get('BillingCountry');
        String billingZipCode = (String) m.get('BillingZipOrPostalCode');
        opp.Additional_Invoice_Details__c = billingName; 
        opp.Invoice_Company_Name__c = billingName;
        if(String.isNotBlank(billingAddressLine1)){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingAddressLine1; 
        }
        if(String.isNotBlank(billingAddressLine2) && billingAddressLine2 != 'null'){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingAddressLine2; 
        }
        if(String.isNotBlank(billingAddressLine3) && billingAddressLine3 != 'null'){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingAddressLine3; 
        }
        if(String.isNotBlank(billingCity)){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingCity; 
        }
        if(String.isNotBlank(billingState)){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingState; 
        }
        if(String.isNotBlank(billingCountry)){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingCountry; 
        }
        if(String.isNotBlank(billingZipCode)){
               opp.Additional_Invoice_Details__c =  opp.Additional_Invoice_Details__c + ' , ' + billingZipCode; 
        }
        opp.Invoice_Address_Line1__c = billingAddressLine1;
        opp.Invoice_Address_Line2__c = billingAddressLine2 != 'null'?billingAddressLine2:'';
        opp.Invoice_Address_Line3__c = billingAddressLine3 != 'null'?billingAddressLine3:'';
        opp.Invoice_City__c = billingCity;
        opp.Invoice_State__c = billingState;
        opp.Invoice_Country__c = billingCountry;
        opp.Invoice_Zip_Code__c = billingZipCode;
        opp.Purchase_Order_No__c = (String) m.get('PurchaseOrderReference');
        
        opp.Finance_Contact_Name__c = (String) m.get('FinanceFirstName') + ' ' + (String) m.get('FinanceLastName');
        opp.Finance_Email__c =  (String) m.get('FinanceEmail');
        opp.Finance_Phone__c = (String) m.get('FinancePhone') + ',' +(String) m.get('FinanceMobile')+'(Mobile)';
        if(paymentOption != null && paymentOption != '' && paymentOption != 'null') {
            opp.Payment_Option__c = paymentOption;
        }
        else {
        	opp.Payment_Option__c = '';
        }
        opp.RecordTypeId = '012D0000000VAaAIAW';
        upsert opp;
        
               
        LRIT_CTR_Request__c newTestReportReq = new LRIT_CTR_Request__c();
        newTestReportReq.Opportunity__c = opp.Id;
        newTestReportReq.Account__c = opp.AccountId;
        newTestReportReq.Billing_Address__c = opp.Additional_Invoice_Details__c;
        newTestReportReq.Pole_Star_LRIT_Test_Number__c = (String) m.get('PolestarTestNumber');
        newTestReportReq.Port__c = (String) m.get('PortOfRegistry');
        newTestReportReq.MMSI__c = (String) m.get('MMSI');
        newTestReportReq.IMN__c = transMobileNumber;
        newTestReportReq.Call_Sign__c = (String) m.get('CallSign');
        newTestReportReq.Vessel_Flag__c = flagName;
        newTestReportReq.Gross_Tonnage__c = (String) m.get('GrossTonnage');
        newTestReportReq.IMO_Number__c = imoNumer;
        newTestReportReq.New_Sea_Areas__c = (String) m.get('SeaAreas');
        newTestReportReq.Transceiver_Type__c = (String) m.get('TransceiverType');
        newTestReportReq.Vessel_Name__c = vesselName;
        String GMDSSTypeApproved = (String) m.get('ApprovedByAdminRegulationIV/14');
        if(GMDSSTypeApproved == 'true' || GMDSSTypeApproved=='TRUE') {
            newTestReportReq.Equipment_Part_of_the_GDMSS__c = 'Yes';
        }
        else{
        	newTestReportReq.Equipment_Part_of_the_GDMSS__c = 'No';        
        }
        String SSASCompliant = (String) m.get('SSASCompliant');
        if(SSASCompliant == 'true' || SSASCompliant=='TRUE') {
        	newTestReportReq.Equipment_Part_of_the_SSAS__c = 'Yes';
        }
        else{
        	newTestReportReq.Equipment_Part_of_the_SSAS__c = 'No';        
        }
        String ApprovedByAdminRegulationV19_1 = (String) m.get('ApprovedByAdminRegulationV19_1');
        if(ApprovedByAdminRegulationV19_1 == 'true' || ApprovedByAdminRegulationV19_1=='TRUE') {
        	newTestReportReq.Approved_by_Admin_Regulation_V_19_1__c = 'Yes';
        }
        else{
        	newTestReportReq.Approved_by_Admin_Regulation_V_19_1__c = 'No';        
        }
        String MeetsIEC = (String) m.get('MeetsIEC');
        if(MeetsIEC == 'true' || MeetsIEC =='TRUE') {
        	newTestReportReq.Meeting_the_requirements_of_IEC__c = 'Yes';
        }
        else{
        	newTestReportReq.Meeting_the_requirements_of_IEC__c = 'No';        
        }
        String courierRequest = (String) m.get('IsCourierRequest');
        if(courierRequest == 'true' || courierRequest=='TRUE') {
                newTestReportReq.Is_Courier_Request__c = true;
        }
        else{
        	newTestReportReq.Is_Courier_Request__c = false;        
        }
        String digitalRequest = (String) m.get('IsDigitalRequest');
        if(digitalRequest == 'true' || digitalRequest=='TRUE') {
                newTestReportReq.Is_Digital_Request__c = true;
        }
        else{
        	newTestReportReq.Is_Digital_Request__c = false;        
        }
        String xmlRequest = (String) m.get('IsXMLRequest');
        if(xmlRequest == 'true' || xmlRequest=='TRUE') {
                newTestReportReq.Is_XML_Request__c = true;
        }
        else{
        	newTestReportReq.Is_XML_Request__c = false;        
        }
        if(isFreeCTR == 'true' || isFreeCTR=='TRUE') {
                newTestReportReq.Is_Free_CTR__c = true;
        }
        else{
        	newTestReportReq.Is_Free_CTR__c = false;        
        }
        newTestReportReq.EU_Company_Name__c = billingName;
        newTestReportReq.Company_Name2__c = (String) m.get('VesselCompanyName');
        newTestReportReq.Delivery_Contact_Name__c = fullName;
        newTestReportReq.Delivery_Email_Address__c = email;
        newTestReportReq.Verification_Code__c = generateRandomVerificationCode();
        newTestReportReq.RecordTypeId = '012D0000000Nd5tIAC';
        newTestReportReq.Additional_Email_Addresses__c = (String) m.get('AdditionalEmailAddresses');
        if(String.isNotBlank(newTestReportReq.Additional_Email_Addresses__c)) {
        	List<String> additionEmails =  newTestReportReq.Additional_Email_Addresses__c.split(';');
            if(additionEmails.size() == 1) {
            	newTestReportReq.Additional_Email_1__c = additionEmails[0]; 
            }
            else if(additionEmails.size() == 2){
                newTestReportReq.Additional_Email_1__c = additionEmails[0]; 
                newTestReportReq.Additional_Email_2__c = additionEmails[1]; 
            }
            else if(additionEmails.size() == 3){
                newTestReportReq.Additional_Email_1__c = additionEmails[0]; 
                newTestReportReq.Additional_Email_2__c = additionEmails[1]; 
                newTestReportReq.Additional_Email_3__c = additionEmails[2]; 
            }
            else if(additionEmails.size() == 4){
                newTestReportReq.Additional_Email_1__c = additionEmails[0]; 
                newTestReportReq.Additional_Email_2__c = additionEmails[1];
                newTestReportReq.Additional_Email_3__c = additionEmails[2]; 
                newTestReportReq.Additional_Email_4__c = additionEmails[3]; 
            }
            else {
            	newTestReportReq.Additional_Email_1__c = additionEmails[0];
                newTestReportReq.Additional_Email_2__c = additionEmails[1]; 
                newTestReportReq.Additional_Email_3__c = additionEmails[2]; 
                newTestReportReq.Additional_Email_4__c = additionEmails[3]; 
                newTestReportReq.Additional_Email_5__c = additionEmails[4]; 
            }
        }
        newTestReportReq.CurrencyISOCode = currencyType;
        newTestReportReq.Currency__c = currencyType;
        newTestReportReq.Delivery_Address__c = (String) m.get('DeliveryAddressLine1'); 
        newTestReportReq.Delivery_Country__c = (String) m.get('DeliveryCountry');
        String deliveryOption = (String) m.get('DeliveryOption');
        newTestReportReq.Delivery_Option__c = deliveryOption;
        newTestReportReq.Customer_Comments__c = (String) m.get('CustomerComments');
        if(isFreeCTR == 'true' || isFreeCTR=='TRUE' || paymentOption == 'Credit Terms' || paymentOption == 'Payment Not Required') {
            if(paymentOption == 'Payment Not Required' && (isFreeCTR == 'false' || isFreeCTR == 'FALSE')) {
            	newTestReportReq.Status__c = 'Completed';    
            }
            else {
            	newTestReportReq.Status__c = 'Released for Printing';    
            }
        }
        else if(paymentOption == 'ProformaInvoice') {
        	newTestReportReq.Status__c = 'Proforma Issued';    
        }
        else{
        	newTestReportReq.Status__c = 'Pending Payment';       
        }
        newTestReportReq.LRIT_Conformance_Test__c  = ctRecordId;  
        newTestReportReq.ElementiAWSS3BucketURL__c  = (String) m.get('ElementiAWSS3BucketURL');  
        newTestReportReq.InmarsatCFormAWSS3BucketURL__c  = (String) m.get('InmarsatCFormAWSS3BucketURL'); 
        newTestReportReq.New_Radio_Survey_Date__c = (String) m.get('LastRadioSurveyDate');
        if(m.get('ChangesRequired') != null) {
        	newTestReportReq.CTR_Chnages_required__c =  (Boolean) m.get('ChangesRequired');        
        }        
        upsert newTestReportReq; 
                
        Opportunity oppRec = [Select Id,Service_PSON__c,SAP_Key__c,Account.Account_Type__c,Account.Is_Distributor__c,Account.Credit_terms__c,
                              Account.ParentId,Account.Parent.Is_Distributor__c,Account.Parent.Credit_terms__c  from Opportunity where Id=:opp.Id];
        
        //Adding/Updating LRIT Certificate Product    
        List<PriceBookEntry> pbe = new List<PriceBookEntry>();
        System.debug('******'+currencyType);
        if(isFreeCTR == 'true' || isFreeCTR == 'TRUE') {
        	pbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW0CTRFREE'
                                AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];         
        }
        else{
        	pbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.Vessel_Flag__c =: flagName
                                 AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];         
        }
               
        List<OpportunityLineItem> oppLineItemList = [Select Id from OpportunityLineItem WHERE OpportunityId=:opp.Id AND Product2.Name like 'LRIT Certificate%'];
        
        if(!pbe.isEmpty()) {
            Decimal salesPrice = 0;
        	OpportunityLineItem oppLineItem = new OpportunityLineItem();
            if(!oppLineItemList.isEmpty()){
            	oppLineItem.Id = oppLineItemList[0].Id;  
            }
            else{
            	oppLineItem.OpportunityId = opp.Id;
            	oppLineItem.Product2Id = pbe[0].Product2Id; 
                oppLineItem.PricebookEntryId = pbe[0].Id;
            }
            oppLineItem.Quantity=1;
            oppLineItem.Product_Sales_Type__c = 'One-off Product';
            oppLineItem.Product_Start_Date__c = System.today();
            oppLineItem.Product_End_Date__c = System.today();
            //oppLineItem.UnitPrice = pbe[0].UnitPrice;
            salesPrice = pbe[0].UnitPrice;
            
            if(billingCountry == 'United Kingdom' && oppRec.Account.Is_Distributor__c == false && oppRec.Account.Parent.Is_Distributor__c == false) {
                oppLineItem.VAT_Amount__c = (salesPrice*20)/100;
            }
            else{
            	oppLineItem.VAT_Amount__c = 0;    
            }
            oppLineItem.TotalPrice = salesPrice + oppLineItem.VAT_Amount__c;
            
            //oppLineItem.TotalPrice = oppLineItem.TotalPrice + oppLineItem.VAT_Amount__c;
            oppLineItem.LRIT_CTR_Request__c = newTestReportReq.Id;
            upsert oppLineItem;
            
                    
            //Adding Courier Price
            List<PriceBookEntry> courierPbe = new List<PriceBookEntry>();
            List<OpportunityLineItem> courierOppLineItemList = new List<OpportunityLineItem>(); 
            if(courierRequest == 'true' || courierRequest=='TRUE') {
                if(isFreeCTR == 'true' || isFreeCTR == 'TRUE') { 
            		courierPbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW000CFREE'
                                AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];    
                	courierOppLineItemList = [Select Id from OpportunityLineItem WHERE OpportunityId=:opp.Id AND Product2.SAP_Item_Code__c = 'SW000CFREE'];
                }
                else if(paymentOption != 'Payment Not Required') {
                    courierPbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000213'
                                     AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];    
                    courierOppLineItemList = [Select Id from OpportunityLineItem WHERE OpportunityId=:opp.Id AND Product2.SAP_Item_Code__c = 'SW00000213'];
                }
                
                if(!courierPbe.isEmpty()) {
                    Decimal courierPrice = 0;
                    OpportunityLineItem courierOppLineItem = new OpportunityLineItem();
                    if(!courierOppLineItemList.isEmpty()){
                        courierOppLineItem.Id = courierOppLineItemList[0].Id;  
                    }
                    else{
                        courierOppLineItem.OpportunityId = opp.Id;
                        courierOppLineItem.Product2Id = courierPbe[0].Product2Id; 
                        courierOppLineItem.PricebookEntryId = courierPbe[0].Id;
                    }
                    courierOppLineItem.Quantity=1;
                    courierOppLineItem.Product_Sales_Type__c = 'One-off Product';
                    courierOppLineItem.Product_Start_Date__c = System.today();
                    courierOppLineItem.Product_End_Date__c = System.today();
                    //oppLineItem.UnitPrice = pbe[0].UnitPrice;
                    courierPrice = courierPbe[0].UnitPrice;
                    
                    if(billingCountry == 'United Kingdom' && oppRec.Account.Is_Distributor__c == false && oppRec.Account.Parent.Is_Distributor__c == false) {
                        courierOppLineItem.VAT_Amount__c = (courierPrice*20)/100;
                    }
                    else{
                        courierOppLineItem.VAT_Amount__c = 0;    
                    }
                    courierOppLineItem.TotalPrice = courierPrice + courierOppLineItem.VAT_Amount__c;
                    
                    //oppLineItem.TotalPrice = oppLineItem.TotalPrice + oppLineItem.VAT_Amount__c;
                    courierOppLineItem.LRIT_CTR_Request__c = newTestReportReq.Id;
                    upsert courierOppLineItem;
                }
                
            }
                       
            //Adding Fasttrack Price
            List<PriceBookEntry> fasttrackPbe = new List<PriceBookEntry>();
            List<OpportunityLineItem> fasttrackOppLineItemList = new List<OpportunityLineItem>();
            if(deliveryOption == 'Fast Track') {
                if(isFreeCTR == 'true' || isFreeCTR == 'TRUE') { 
            		fasttrackPbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00FTFREE'
                                AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];    
                }
                else if(paymentOption != 'Payment Not Required') {
                	fasttrackPbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW00000212'
                                AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];    
                }
                if(!fasttrackPbe.isEmpty()) {
                    Decimal fasttrackPrice = 0;
                    OpportunityLineItem fasttrackOppLineItem = new OpportunityLineItem();
                    if(!fasttrackOppLineItemList.isEmpty()){
                        fasttrackOppLineItem.Id = fasttrackOppLineItemList[0].Id;  
                    }
                    else{
                        fasttrackOppLineItem.OpportunityId = opp.Id;
                        fasttrackOppLineItem.Product2Id = fasttrackPbe[0].Product2Id; 
                        fasttrackOppLineItem.PricebookEntryId = fasttrackPbe[0].Id;
                    }
                    fasttrackOppLineItem.Quantity=1;
                    fasttrackOppLineItem.Product_Sales_Type__c = 'One-off Product';
                    fasttrackOppLineItem.Product_Start_Date__c = System.today();
                    fasttrackOppLineItem.Product_End_Date__c = System.today();
                    //oppLineItem.UnitPrice = pbe[0].UnitPrice;
                    fasttrackPrice = fasttrackPbe[0].UnitPrice;
                    
                    if(billingCountry == 'United Kingdom' && oppRec.Account.Is_Distributor__c == false && oppRec.Account.Parent.Is_Distributor__c == false) {
                        fasttrackOppLineItem.VAT_Amount__c = (fasttrackPrice*20)/100;
                    }
                    else{
                        fasttrackOppLineItem.VAT_Amount__c = 0;    
                    }
                    fasttrackOppLineItem.TotalPrice = fasttrackPrice + fasttrackOppLineItem.VAT_Amount__c;
                    
                    //oppLineItem.TotalPrice = oppLineItem.TotalPrice + oppLineItem.VAT_Amount__c;
                    fasttrackOppLineItem.LRIT_CTR_Request__c = newTestReportReq.Id;
                    upsert fasttrackOppLineItem;
                }
            }
            if(deliveryOption == 'Fast Track' && fasttrackPbe.isEmpty() && paymentOption != 'Payment Not Required'){
                // Rollback to the previous null value 
                Database.rollback(sp);
                
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Fasttrack PriceBookEntry is not available for the Product"}');	        
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Fasttrack PriceBookEntry is not available for the Product' + m;
                log.Functionality__c = 'Create CTR Opportunity';
                insert log;
            }
            else if((courierRequest == 'true' || courierRequest=='TRUE') && courierPbe.isEmpty() && paymentOption != 'Payment Not Required'){
            	// Rollback to the previous null value 
                Database.rollback(sp);
                
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"Courier PriceBookEntry is not available for the Product"}');	        
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Courier PriceBookEntry is not available for the Product' + m;
                log.Functionality__c = 'Create CTR Opportunity';
                insert log;
            }
            else{
            	List<OpportunityLineItem> allLineItemList = [Select Id,TotalPrice,OpportunityId from OpportunityLineItem where OpportunityId =:opp.Id];
                Decimal totalPrice = 0;
                for(OpportunityLineItem oli : allLineItemList){
                    totalPrice = totalPrice + oli.TotalPrice;       
                }
    
                RestContext.response.addHeader('Content-Type', 'application/json');
                if(oppRec.Account.ParentId != null && oppRec.Account.Parent.Is_Distributor__c == true) {
                    RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "PSON" :"'+oppRec.Service_PSON__c+'" ,"CreditTerms" :"'+oppRec.Account.Parent.Credit_terms__c+'" ,"SAPCode":"'+oppRec.SAP_Key__c+'","Price":"'+totalPrice+'","Currency":"'+currencyType+'","message":"success" }');
                }
                else {
                    RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "PSON" :"'+oppRec.Service_PSON__c+'" ,"CreditTerms" :"'+oppRec.Account.Credit_terms__c+'" ,"SAPCode":"'+oppRec.SAP_Key__c+'","Price":"'+totalPrice+'","Currency":"'+currencyType+'","message":"success" }');    
                }
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'CTR Opportunity Creation is successful' + oppRec.Service_PSON__c;
                log.Functionality__c = 'Create CTR Opportunity';
                insert log;    
            }
        }
        else{
            // Rollback to the previous null value 
			Database.rollback(sp);

        	RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"PriceBookEntry is not available for the Product"}');	        
        	Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'PriceBookEntry is not available for the Product' + m;
            log.Functionality__c = 'Create CTR Opportunity';
            insert log;
            
        }
        
        }Catch(Exception e){
            // Rollback to the previous null value 
			Database.rollback(sp);

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage() + m;
            log.Functionality__c = 'Create CTR Opportunity';
            insert log;
            
        }
    }
    
    //Generate random verification code
    public static string generateRandomVerificationCode(){
        final String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        String token = '';
        while (token.length() < 16) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        token += chars.substring(idx, idx+1);
        }
        String formattedToken = token.substring(0, 4) + '-' + 
                                token.substring(4,8) + '-' +
                                token.substring(8,12) + '-' +
                                token.substring(12,16);
        return formattedToken; 
    }
    
}