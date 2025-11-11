@RestResource(urlMapping='/UpdateConformanceTest/*')
global with sharing class UpdateConformanceTest {
    @HttpPost
    global static void updateConformanceTest() {
        Map<String, Object> m = new Map<String,Object>();
        try{
        API_Request__c apiRequest = new API_Request__c();
        apiRequest.Name = 'Update Conformance Test';
        apiRequest.Product_Type__c = 'LRIT CT';
        apiRequest.Request_Type__c = 'Inbound';
        apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
        insert apiRequest;
        
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
  															RestContext.request.requestBody.toString());
		Object conformanceTestDetails = (Object)params.get('ConformanceTestDetails');
        m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(conformanceTestDetails));
        String pson = (String) m.get('pson'); 
        LRIT_Conformance_Tests__c conformanceTest = new LRIT_Conformance_Tests__c();
        conformanceTest.Id = (String) m.get('ctRecordId');
        conformanceTest.Distinctive_numbers_or_letters__c = (String) m.get('callSign');
        conformanceTest.Call_Sign__c = (String) m.get('callSign');
        conformanceTest.Vessel_Name__c = (String) m.get('vesselName');
        conformanceTest.Vessel_Flag__c = (String) m.get('flagName');
        conformanceTest.Flag__c = (String) m.get('flagID');
        conformanceTest.MMSI__c = (String) m.get('mmsi');
        conformanceTest.Port_of_Registry__c = (String) m.get('portOfRegistry');
        conformanceTest.Serial_Number__c = (String) m.get('serialNumber');
        conformanceTest.Make__c = (String) m.get('transceiverManufacturer');
        conformanceTest.Model__c = (String) m.get('transceiverModel');
        conformanceTest.Mobile_Number__c = (String) m.get('transceiverNumber');
        conformanceTest.Last_Radio_Survey__c = (String) m.get('lastRadioSurveryDate');
        conformanceTest.Gross_Tonnage__c = (String) m.get('grossTonnage');
        conformanceTest.Sea_Areas__c = (String) m.get('seaAreas');
        conformanceTest.Sea_Area_Certificate_Reference__c = (String) m.get('seaAreaCertificateReference');
        conformanceTest.Sea_Area_Certificate_Type__c = (String) m.get('seaAreaCertificateType');
        conformanceTest.Inmarsat_Serial_Number__c = (String) m.get('inmarsatSerialNumber');
        conformanceTest.Ship_Type__c = (String) m.get('shipType');
        conformanceTest.Reason_for_Test__c = (String) m.get('testReason');
        Boolean gmdss = (Boolean) m.get('gmdss');
        if(gmdss == true){
        	conformanceTest.GMDSS__c = 'Yes';	        
        }
        else {
        	conformanceTest.GMDSS__c = 'No';	        
        }
        Boolean ssas = (Boolean) m.get('ssas');
        if(ssas == true){
        	conformanceTest.SSAS__c = 'Yes';	        
        }
        else {
        	conformanceTest.SSAS__c = 'No';	        
        }
        conformanceTest.Customer_Email__c = (String) m.get('customerEmail');
        String secondaryEmail = (String) m.get('customerSecondEmail');
        if(String.isNotBlank(secondaryEmail)){
        	String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        	Pattern MyPattern = Pattern.compile(emailRegex);
        	Matcher MyMatcher = MyPattern.matcher(secondaryEmail);  
            if(MyMatcher.matches()){
        		conformanceTest.Customer_Second_Email__c = secondaryEmail; 
            }
        }
               
        conformanceTest.Account__c = (String) m.get('salesforceAccountID');
        if(String.isNotBlank(pson)) {
        	List<Opportunity> oppList = [Select Id from Opportunity where Service_PSON__c=:pson Limit 1];
            if(!oppList.isEmpty()){
            	conformanceTest.Opportunity__c = oppList[0].Id;    
            }
        }
        update conformanceTest; 
        
	    RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200","message":"success" }');
            
        Error_Log__c log = new Error_Log__c();
        log.Error_Message__c = 'Conformance Test Update Success:'+conformanceTest.Id;
        log.Functionality__c = 'Update Conformance Test';
        insert log;

        }Catch(Exception e){
            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
        	Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage() + m;
            log.Functionality__c = 'Update Conformance Test';
            insert log;    
        }
    }
}