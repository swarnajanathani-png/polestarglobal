public class LRITUSACTROpportunity {
    @InvocableMethod
    public static void createUSACTROpportunity(List<String> recordIds) {
        String recordId = recordIds[0];
        API_Request__c apiRequest = new API_Request__c();
        apiRequest.Name = 'Create USA CTR Opportunity';
        apiRequest.Product_Type__c = 'LRIT CTR';
        apiRequest.Request_Type__c = 'Inbound';
        apiRequest.Request_JSON__c = recordId;
        insert apiRequest; 
        // Create a savepoint while AccountNumber is null 
		Savepoint sp = Database.setSavepoint();
        try{
             
            LRIT_Conformance_Tests__c ct = [Select Id,Vessel_Name__c,Vessel_Flag__c,IMO_Number__c,
                                            Make__c, Model__c,Serial_Number__c,Mobile_Number__c,CurrencyIsoCode,
                                            Pole_Star_LRIT_Test_Number__c,Port_of_Registry__c,MMSI__c,Call_Sign__c,Gross_Tonnage__c,
                                            Sea_Areas__c,Ship_Type__c,Opportunity__r.Contact_Person1__r.Name,Opportunity__r.Contact_Person1__r.Email,
                                            Account__c,Opportunity__r.Contact_Person1__c,Opportunity__r.Additional_Invoice_Details__c,
                                            Opportunity__r.Invoice_Company_Name__c,Opportunity__r.Invoice_Address_Line1__c,
                                            Opportunity__r.Invoice_Address_Line2__c,Opportunity__r.Invoice_Address_Line3__c,
                                            Opportunity__r.Invoice_City__c,Opportunity__r.Invoice_State__c,Opportunity__r.Invoice_Country__c,
                                            Opportunity__r.Invoice_Zip_Code__c,Opportunity__r.Purchase_Order_No__c,Opportunity__r.Finance_Contact_Name__c,
                                            Opportunity__r.Finance_Email__c,Opportunity__r.Finance_Phone__c
                                            FROM LRIT_Conformance_Tests__c where id =:recordId];
            Opportunity opp = new Opportunity();
            String vesselName = ct.Vessel_Name__c;
            String imoNumer = ct.IMO_Number__c;
            String transManufacture = ct.Make__c;
            String transModel = ct.Model__c;
            String transNumber = ct.Serial_Number__c;
            String transMobileNumber = ct.Mobile_Number__c;
            String currencyType = ct.CurrencyIsoCode;
            String flagName = ct.Vessel_Flag__c; 
            String ctRecordId = ct.Id;
            
            opp.Name = vesselName + ' - ' + imoNumer + ' - ' + transManufacture + ' - ' + transModel + ' - ' + System.now();
        	opp.AccountId = ct.Account__c;
        	opp.Contact_Person1__c = ct.Opportunity__r.Contact_Person1__c;
        	opp.Product_Type__c = 'LRIT Conformance Test Report';
			opp.Type = 'Portal Conformance Test Report';
        	opp.StageName ='Closed Won';
            opp.CloseDate = System.today();
            opp.Order_Date__c = System.now();
            opp.CurrencyIsoCode = ct.CurrencyIsoCode;
            opp.Currency__c = ct.CurrencyIsoCode;
            opp.Additional_Invoice_Details__c = ct.Opportunity__r.Additional_Invoice_Details__c; 
            opp.Invoice_Company_Name__c = ct.Opportunity__r.Invoice_Company_Name__c;
            opp.Invoice_Address_Line1__c = ct.Opportunity__r.Invoice_Address_Line1__c;
            opp.Invoice_Address_Line2__c = ct.Opportunity__r.Invoice_Address_Line2__c;
            opp.Invoice_Address_Line3__c = ct.Opportunity__r.Invoice_Address_Line3__c;
            opp.Invoice_City__c = ct.Opportunity__r.Invoice_City__c;
            opp.Invoice_State__c = ct.Opportunity__r.Invoice_State__c;
            opp.Invoice_Country__c = ct.Opportunity__r.Invoice_Country__c;
            opp.Invoice_Zip_Code__c = ct.Opportunity__r.Invoice_Zip_Code__c;
            opp.Purchase_Order_No__c = ct.Opportunity__r.Purchase_Order_No__c;
            opp.Finance_Contact_Name__c = ct.Opportunity__r.Finance_Contact_Name__c;
            opp.Finance_Email__c =  ct.Opportunity__r.Finance_Email__c;
            opp.Finance_Phone__c = ct.Opportunity__r.Finance_Phone__c;
            opp.Payment_Option__c = 'Payment Not Required';
            opp.RecordTypeId = '012D0000000VAaAIAW';
            insert opp;
            
            LRIT_CTR_Request__c newTestReportReq = new LRIT_CTR_Request__c();
            newTestReportReq.Opportunity__c = opp.Id;
            newTestReportReq.Account__c = opp.AccountId;
            newTestReportReq.Billing_Address__c = opp.Additional_Invoice_Details__c;
            newTestReportReq.Pole_Star_LRIT_Test_Number__c = ct.Pole_Star_LRIT_Test_Number__c;
            newTestReportReq.Port__c = ct.Port_of_Registry__c;
            newTestReportReq.MMSI__c = ct.MMSI__c;
            newTestReportReq.IMN__c = transMobileNumber;
            newTestReportReq.Call_Sign__c = ct.Call_Sign__c;
            newTestReportReq.Vessel_Flag__c = flagName;
            newTestReportReq.Gross_Tonnage__c = ct.Gross_Tonnage__c;
            newTestReportReq.IMO_Number__c = imoNumer;
            newTestReportReq.New_Sea_Areas__c = ct.Sea_Areas__c;
            newTestReportReq.Transceiver_Type__c = ct.Ship_Type__c;
            newTestReportReq.Vessel_Name__c = vesselName;
            newTestReportReq.Equipment_Part_of_the_GDMSS__c = 'Yes';
            newTestReportReq.Equipment_Part_of_the_SSAS__c = 'No';   
            newTestReportReq.Approved_by_Admin_Regulation_V_19_1__c = 'Yes';
            newTestReportReq.Meeting_the_requirements_of_IEC__c = 'Yes';
            newTestReportReq.Is_Courier_Request__c = false; 
            newTestReportReq.Is_Digital_Request__c = true;
            newTestReportReq.Is_XML_Request__c = false;   
            newTestReportReq.Is_Free_CTR__c = true;        
            newTestReportReq.EU_Company_Name__c = ct.Opportunity__r.Invoice_Company_Name__c;
            newTestReportReq.Delivery_Contact_Name__c = ct.Opportunity__r.Contact_Person1__r.Name;
            newTestReportReq.Delivery_Email_Address__c = ct.Opportunity__r.Contact_Person1__r.Email;
            newTestReportReq.Verification_Code__c = generateRandomVerificationCode();
            newTestReportReq.RecordTypeId = '012D0000000Nd5tIAC';
            //newTestReportReq.Additional_Email_Addresses__c = (String) m.get('AdditionalEmailAddresses');
            newTestReportReq.CurrencyISOCode = currencyType;
            newTestReportReq.Currency__c = currencyType;
                       
            newTestReportReq.Delivery_Option__c = 'Standard Delivery';
            //newTestReportReq.Customer_Comments__c = ;
            newTestReportReq.Status__c = 'Released for Printing';        
            newTestReportReq.LRIT_Conformance_Test__c  = ctRecordId;  
            insert newTestReportReq; 
            
            //Adding/Updating LRIT Certificate Product    
            List<PriceBookEntry> pbe = new List<PriceBookEntry>();
            System.debug('******'+currencyType);
            pbe = [Select Id,Product2Id,Product2.Name,UnitPrice FROM PriceBookEntry Where Product2.SAP_Item_Code__c = 'SW0CTRFREE'
                                    AND CurrencyIsoCode=:currencyType AND Pricebook2Id='01s200000000BIgAAM' AND Product2.Family = 'LRIT CTR'];         
               
        	if(!pbe.isEmpty()) {
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.OpportunityId = opp.Id;
                oppLineItem.Product2Id = pbe[0].Product2Id; 
                oppLineItem.PricebookEntryId = pbe[0].Id;
                oppLineItem.Quantity=1;
                oppLineItem.Product_Sales_Type__c = 'One-off Product';
                oppLineItem.Product_Start_Date__c = System.today();
                oppLineItem.Product_End_Date__c = System.today();
                oppLineItem.TotalPrice = pbe[0].UnitPrice;
                oppLineItem.LRIT_CTR_Request__c = newTestReportReq.Id;
                insert oppLineItem;
            }
			else{
                // Rollback to the previous null value 
                Database.rollback(sp);
    			Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'PriceBookEntry is not available for USA Free CTR';
                insert log;
            
       		 }
            
        }Catch(Exception e){
            // Rollback to the previous null value 
			Database.rollback(sp);
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'Error occurred while creating USA CTR Opportunity: '+e.getMessage();
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