@RestResource(urlMapping='/CreateOpportuntity/*')
global with sharing class OpportunityRestClass {
    @HttpPost
    global static void postOpportunity() {
        Map<String, Object> m = new Map<String, Object>();
        // Create a savepoint while AccountNumber is null 
		Savepoint sp = Database.setSavepoint(); 
        
        try{
        API_Request__c apiRequest = new API_Request__c();
        apiRequest.Name = 'Create CT Opportunity';
        apiRequest.Product_Type__c = 'LRIT CT';
        apiRequest.Request_Type__c = 'Inbound';
        apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
        insert apiRequest; 
            
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
        Object Opportunity = (Object)params.get('Opportunity');
        m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(Opportunity));
        Contact con = new Contact();
        String accountId = (String) m.get('CustomerId');
        String email = (String) m.get('LRITContactEmail');
        String firstName = (String) m.get('LRITContactFirstName');
        String lastName = (String) m.get('LRITContactLastName');
        String fullName = firstName + ' '+ lastName;
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
        	con.FirstName = (String) m.get('LRITContactFirstName');
            con.LastName = (String) m.get('LRITContactLastName');
            con.Email = (String) m.get('LRITContactEmail');
            con.Title = (String) m.get('LRITContactTitle');
            con.Phone = (String) m.get('LRITContactPhone');
            con.MobilePhone = (String) m.get('LRITContactMobile');
         	insert con;
            contactId = con.Id;
        }
        
        apiRequest.Account__c = accountId;
        update apiRequest;
            
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
            
        List<Vessel_Registration__c> registrationList = [SELECT Id,Opportunity__r.Id FROM Vessel_Registration__c
                                                    WHERE Opportunity__r.AccountId =: accountId
                                                    AND Opportunity__r.StageName = 'Closed Received'
                                                    AND Opportunity__r.CurrencyISOCode =:currencyType
                                                    AND Name =:vesselName AND IMO_Number__c =:imoNumer
                                                    AND Flag_Name__c =:flagName AND Transceiver_Manufacturer__c=:transManufacture
                                                    AND Transceiver_Model__c =: transModel
                                                    AND Mobile_Number__c =: transMobileNumber];
            
        if(!registrationList.isEmpty()) {
        	opp.Id = registrationList[0].Opportunity__r.Id;         
        }
        opp.Name = vesselName + ' - ' + imoNumer + ' - ' + transManufacture + ' - ' + transModel + ' - ' + System.now();
        opp.AccountId = accountId;
        opp.Contact_Person1__c = contactId;
        opp.Product_Type__c = 'LRIT Conformance Test';
		opp.Type = 'Portal Conformance Test';
        if((lstAccounts[0].Credit_terms__c == 'Payment on invoice' || 
            (String.isNotBlank(lstAccounts[0].ParentId)) && lstAccounts[0].Parent.Credit_terms__c == 'Payment on invoice') 
            && paymentOption == 'Credit Terms'){
        	opp.StageName ='Closed Won';
        } 
        else if(paymentOption == 'Payment Not Required') {
        	opp.StageName ='Closed Won';      
        }
        else{
        	opp.StageName ='Closed Received';    
        }
        opp.CloseDate = System.today();
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
        
        opp.Finance_Contact_Name__c = (String) m.get('BillingorFinanceFirstName') + ' ' + (String) m.get('BillingorFinanceLastName');
        opp.Finance_Email__c =  (String) m.get('BillingorFinanceEmail');
        opp.Finance_Phone__c = (String) m.get('BillingorFinancePhone') + ',' +(String) m.get('BillingorFinanceMobile')+'(Mobile)';
        if(paymentOption != null && paymentOption != '' && paymentOption != 'null')
        opp.Payment_Option__c = paymentOption;
        else
        opp.Payment_Option__c = '';
        opp.RecordTypeId = '012D0000000VAaAIAW';
        upsert opp;
        
        
        
        Vessel_Registration__c newTestReg = new Vessel_Registration__c();
        if(!registrationList.isEmpty()) {
        	newTestReg.Id = registrationList[0].Id;         
        }
        else{
        	newTestReg.Opportunity__c = opp.Id;
        }
        newTestReg.Call_Sign__c = (String) m.get('CallSign');
        newTestReg.CurrencyIsoCode = (String) m.get('PaymentCurrency');
        //newTestReg.Flag_Identifier__c = (String) m.get('FlagIdentifier');
        newTestReg.Flag_Name__c = flagName;
        newTestReg.Gross_Tonnage__c = (String) m.get('GrossTonnage');
        newTestReg.IMO_Number__c = imoNumer;
        if(String.isNotBlank((String) m.get('LastRadioSurveyDate'))){
        	newTestReg.Last_Radio_Survey_Date__c = Date.valueOf((String) m.get('LastRadioSurveyDate'));        
        }
        newTestReg.MMSI__c = (String) m.get('MMSI');
        newTestReg.Mobile_Number__c = transMobileNumber;
        newTestReg.Port_of_Registry__c = (String) m.get('PortOfRegistry');
        newTestReg.Sea_Areas__c = (String) m.get('SeaAreas');
        newTestReg.Sea_Areas_Certificate_Reference__c = (String) m.get('SeaAreasCertificateReference');
        newTestReg.Sea_Areas_Certificate_Type__c = (String) m.get('SeaAreasCertificateType');
        newTestReg.Serial_Number__c = transNumber;
        newTestReg.Test_Start_Date__c = (String) m.get('TestStartDate');
        newTestReg.Transceiver_Manufacturer__c = transManufacture;
        newTestReg.Transceiver_Model__c = transModel;
        newTestReg.Transceiver_Type__c = (String) m.get('TransceiverType');
        newTestReg.Test_Start_Option__c = (String) m.get('TestStartOption');    
        newTestReg.Name = vesselName;
        newTestReg.Reason_for_Test__c = (String) m.get('TestReason'); 
        newTestReg.Can__c = (String) m.get('GMDSSTypeApproved');
        newTestReg.Is_Used_for_SSAS__c = (String) m.get('SSASCompliant');
        newTestReg.Ship_Type__c = (String) m.get('ShipType');
        newTestReg.Customer_Email__c = (String) m.get('LRITContactEmail');
        String secondEmail = (String) m.get('AdditionalContactInformation');
        if(secondEmail != '' && secondEmail !='null' && String.isNotBlank(secondEmail)){
        	newTestReg.Customer_Second_Email__c = (String) m.get('AdditionalContactInformation');
        }
        upsert newTestReg; 
        
		Opportunity oppRec = [Select Id,Service_PSON__c,SAP_Key__c,Account.Account_Type__c,Account.Is_Distributor__c,Account.Credit_terms__c,
                              Account.ParentId,Account.Parent.Is_Distributor__c,Account.Parent.Credit_terms__c  from Opportunity where Id=:opp.Id];
        List<PriceBookEntry> pbe = new List<PriceBookEntry>();
        System.debug('******'+currencyType);
            
        //Updated if condition https://pole-star.atlassian.net/browse/REV-406
        if(oppRec.Account.Is_Distributor__c == true || oppRec.Account.Parent.Is_Distributor__c == true) {
                pbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.Vessel_Flag__c =: flagName
                                     AND CurrencyIsoCode=:currencyType AND Pricebook2.Name like '%Wholesale%' AND Pricebook2.IsActive = true]; 
        }
        else {
                pbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.Vessel_Flag__c =: flagName
                       AND CurrencyIsoCode=:currencyType AND Pricebook2.Name like '%Retail%' AND Pricebook2.IsActive = true];         
        }
            
        
        List<OpportunityLineItem> oppLineItemList = [Select Id from OpportunityLineItem WHERE OpportunityId=:opp.Id];
        
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
            if(oppRec.Account.Account_Type__c == 'National Agent' && flagName == 'Liberia - LBR'){
            	oppLineItem.Discount = 20;  
                salesPrice = pbe[0].UnitPrice - ((pbe[0].UnitPrice*20)/100);
            }
            else{
            	oppLineItem.Discount = 0;    
            }
            
            //Updated if condition https://pole-star.atlassian.net/browse/REV-406
            if((billingCountry == 'United Kingdom' || billingCountry == 'Isle of Man') && oppRec.Account.Is_Distributor__c == false && oppRec.Account.Parent.Is_Distributor__c == false) {
                oppLineItem.VAT_Amount__c = (salesPrice*20)/100;
            }
            else{
            	oppLineItem.VAT_Amount__c = 0;    
            }
            oppLineItem.TotalPrice = salesPrice + oppLineItem.VAT_Amount__c;
            
            //oppLineItem.TotalPrice = oppLineItem.TotalPrice + oppLineItem.VAT_Amount__c;
            oppLineItem.LRIT_Test_Registration__c = newTestReg.Id;
            upsert oppLineItem;
            
            OpportunityLineItem oppLineItem1 = [Select Id,TotalPrice from OpportunityLineItem where Id=:oppLineItem.Id];
            RestContext.response.addHeader('Content-Type', 'application/json');
            if(oppRec.Account.ParentId != null && oppRec.Account.Parent.Is_Distributor__c == true) {
        		RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "PSON" :"'+oppRec.Service_PSON__c+'" ,"CreditTerms" :"'+oppRec.Account.Parent.Credit_terms__c+'" ,"SAPCode":"'+oppRec.SAP_Key__c+'","Price":"'+oppLineItem1.TotalPrice+'","Currency":"'+currencyType+'","message":"success" }');
            }
            else {
            	RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "PSON" :"'+oppRec.Service_PSON__c+'" ,"CreditTerms" :"'+oppRec.Account.Credit_terms__c+'" ,"SAPCode":"'+oppRec.SAP_Key__c+'","Price":"'+oppLineItem1.TotalPrice+'","Currency":"'+currencyType+'","message":"success" }');    
            }
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'Success: CT Opportunity Created Successfully' + oppRec.Service_PSON__c;
            log.Functionality__c = 'Create CT Opportunity';
            insert log;
        }
        else{
            // Rollback to the previous null value 
			Database.rollback(sp);

        	RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"PriceBookEntry is not available for the Product"}');	        
        	Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'PriceBookEntry is not available for the Product' + m;
            log.Functionality__c = 'Create CT Opportunity';
            insert log;
            
        }
        
        }Catch(Exception e){
            // Rollback to the previous null value 
			Database.rollback(sp);

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Functionality__c = 'Create CT Opportunity';
            log.Error_Message__c = e.getMessage() + m;
            insert log;
            
        }
    }
}