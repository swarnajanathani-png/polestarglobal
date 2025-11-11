@RestResource(urlMapping='/getConformanceTest/*')
global with sharing class GetLRITConformanceTestClass {
    @HttpPost
    global static void getConformanceTestDetails() {
        Map<String, Object> lritConformanceTestdata = new Map<String,Object>();
        String testNumber = '';
        String imo = '';
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'Get Conformance Test';
            apiRequest.Product_Type__c = 'LRIT CT';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;        
        
          Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                RestContext.request.requestBody.toString());
      String source = (String) params.get('Source');
          Object lritConformanceTest = (Object)params.get('LRITConformanceTest');
       
            lritConformanceTestdata = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(lritConformanceTest));
            testNumber = (String) lritConformanceTestdata.get('testNumber');
            imo =  (String) lritConformanceTestdata.get('imo');
            List<LRIT_Conformance_Tests__c> lritCTList = new List<LRIT_Conformance_Tests__c>();
            if(String.isNotBlank(testNumber) && testNumber != 'Null' && testNumber != 'null'){
              lritCTList = [Select Id,Name,Account__r.Id,Opportunity__r.Id,Reason_for_Test__c,Call_Sign__c,Customer_Email__c,Customer_Second_Email__c,Data_has_been_validated__c,
                              Distinctive_numbers_or_letters__c,Finish_Time__c,Flag__c,GMDSS__c,Gross_Tonnage__c,
                              IMO_Number__c, Last_Radio_Survey__c,Make__c,MMSI__c,Mobile_Number__c,Model__c,Opportunity__r.Service_PSON__c,
                              Override_Performance__c,Override_Screening__c,Pole_Star_LRIT_Test_Number__c,Port_of_Registry__c,
                              Sea_Area_Certificate_Reference__c,Sea_Area_Certificate_Type__c,Sea_Areas__c,Serial_Number__c,
                              Ship_Type__c,SSAS__c,Start_Time__c,Test_Finish_Date__c,Test_Finish_Time_Date__c,
                              Test_Passed__c,Test_Start_Date__c,Test_Start_Time_Date__c,Validation_Status__c,
                              Vessel_Flag__c,Vessel_Name__c,Inmarsat_Serial_Number__c From LRIT_Conformance_Tests__c WHERE Pole_Star_LRIT_Test_Number__c =: testNumber];   
            }
            else if(String.isNotBlank(imo) && imo != 'Null' && imo != 'null'){
                
              lritCTList = [Select Id,Name,Account__r.Id,Opportunity__r.Id,Reason_for_Test__c,Call_Sign__c,Customer_Email__c,Customer_Second_Email__c,Data_has_been_validated__c,
                              Distinctive_numbers_or_letters__c,Finish_Time__c,Flag__c,GMDSS__c,Gross_Tonnage__c,
                              IMO_Number__c, Last_Radio_Survey__c,Make__c,MMSI__c,Mobile_Number__c,Model__c,Opportunity__r.Service_PSON__c,
                              Override_Performance__c,Override_Screening__c,Pole_Star_LRIT_Test_Number__c,Port_of_Registry__c,
                              Sea_Area_Certificate_Reference__c,Sea_Area_Certificate_Type__c,Sea_Areas__c,Serial_Number__c,
                              Ship_Type__c,SSAS__c,Start_Time__c,Test_Finish_Date__c,Test_Finish_Time_Date__c,
                              Test_Passed__c,Test_Start_Date__c,Test_Start_Time_Date__c,Validation_Status__c,
                              Vessel_Flag__c,Vessel_Name__c,Inmarsat_Serial_Number__c From LRIT_Conformance_Tests__c WHERE IMO_Number__c =: imo order by createddate desc limit 1];    
            }
            if(!lritCTList.isEmpty()){
                String ctId = lritCTList[0].Id; 
                String ctOpportunityId = null;
                String testReason = '';
                if(String.isNotBlank(lritCTList[0].Opportunity__c)) {
                  ctOpportunityId = lritCTList[0].Opportunity__r.Id;    
                }
                
                List<Vessel_Registration__c> ctRegistrationsList = [Select Id,Reason_for_Test__c FROM Vessel_Registration__c 
                                                                   WHERE Opportunity__r.Id =:ctOpportunityId];
                if(String.isNotBlank(lritCTList[0].Reason_for_Test__c)) {
                  testReason = lritCTList[0].Reason_for_Test__c;    
                }
                else if(!ctRegistrationsList.isEmpty()){
                  testReason = ctRegistrationsList[0].Reason_for_Test__c;     
                }
                String ctrStatus = '';
                List<LRIT_CTR_Request__c> ctrRequestList = [Select Id,Status__c,Opportunity__r.StageName FROM LRIT_CTR_Request__c 
                                                            where LRIT_Conformance_Test__c =:ctId
                                                            AND Opportunity__c != null
                                                            AND (Opportunity__r.StageName = 'Closed Won' OR Opportunity__r.StageName = 'Closed Received')
                                                            AND Status__c != 'Cancelled'
                                                            AND LRIT_CTR_Status__c != 'Expired'
                                                            AND LRIT_CTR_Status__c != 'Cancelled'
                                                            AND LRIT_CTR_Status__c != 'Superseded'
                                                            Order by CreatedDate desc LIMIT 1];
                
                if(ctrRequestList.isEmpty()){
                  ctrStatus = 'New CTR';    
                }
                else if(ctrRequestList[0].Opportunity__r.StageName == 'Closed Won' && 
                       ctrRequestList[0].Status__c == 'Released for Printing'){
                  ctrStatus = 'Existing Paid CTR';           
                }
                else if(ctrRequestList[0].Opportunity__r.StageName == 'Closed Received' && 
                       ctrRequestList[0].Status__c == 'Proforma Issued'){
                  ctrStatus = 'Existing Proforma CTR';           
                }
                else{
                  ctrStatus = 'New CTR';    
                }
                String testStartDate = '';
                String testFinishDate = '';
                String lastRadioSurveyDate = '';
                String convertedLastRadioSurveyDate = '';
                
                if(lritCTList[0].Test_Start_Date__c != null) {
                    testStartDate = (''+lritCTList[0].Test_Start_Date__c).split(' ')[0]; 
                }
                if(lritCTList[0].Test_Finish_Date__c != null) {
                  testFinishDate = (''+lritCTList[0].Test_Finish_Date__c).split(' ')[0]; 
                }
                if(lritCTList[0].Last_Radio_Survey__c != null) {
                  lastRadioSurveyDate = (''+lritCTList[0].Last_Radio_Survey__c).split(' ')[0]; 
                }
                if(String.isNotBlank(lastRadioSurveyDate)) {
                    if(lastRadioSurveyDate.split('-').size() >= 2) {
                    convertedLastRadioSurveyDate = lastRadioSurveyDate.split('-')[2] + '/' + lastRadioSurveyDate.split('-')[1] + '/' + lastRadioSurveyDate.split('-')[0];     
                    }
                    else if(lastRadioSurveyDate.split('/').size() >= 2) {
                    convertedLastRadioSurveyDate = lastRadioSurveyDate.split('/')[2] + '/' + lastRadioSurveyDate.split('/')[1] + '/' + lastRadioSurveyDate.split('/')[0];     
                    }
                    else {
                      convertedLastRadioSurveyDate = lastRadioSurveyDate;  
                    }
                }
                
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "200", "testNumber" : "'+lritCTList[0].Pole_Star_LRIT_Test_Number__c
                                                                     +'", "ctRecordId" : "'+lritCTList[0].Id
                                                                     +'", "testStartTime" : "'+lritCTList[0].Start_Time__c
                                                                     +'", "testFinishTime" : "'+lritCTList[0].Finish_Time__c
                                                                     +'", "ctrStatus" : "'+ctrStatus
                                                                    +'", "testStartDate" : "'+testStartDate
                                                                    +'", "testEndDate" : "'+testFinishDate
                                                                    +'", "callSign" : "'+lritCTList[0].Call_Sign__c
                                                                    +'", "customerEmail" : "'+lritCTList[0].Customer_Email__c
                                                                    +'", "customerSecondEmail" : "'+lritCTList[0].Customer_Second_Email__c
                                                                    +'", "flagID" : "'+lritCTList[0].Flag__c
                                                                    +'", "flagName" : "'+lritCTList[0].Vessel_Flag__c
                                                                    +'", "imoNumber" : "'+lritCTList[0].IMO_Number__c
                                                                    +'", "mmsi" : "'+lritCTList[0].MMSI__c
                                                                    +'", "portOfRegistry" : "'+lritCTList[0].Port_of_Registry__c
                                                                    +'", "pson" : "'+lritCTList[0].Opportunity__r.Service_PSON__c
                                                                    +'", "salesforceAccountID" : "'+lritCTList[0].Account__r.Id
                                                                    +'", "lastRadioSurveryDate" : "'+convertedLastRadioSurveyDate
                                                                    +'", "serialNumber" : "'+lritCTList[0].Serial_Number__c
                                                                    +'", "grossTonnage" : "'+lritCTList[0].Gross_Tonnage__c
                                                                    +'", "seaAreas" : "'+lritCTList[0].Sea_Areas__c
                                                                    +'", "seaAreaCertificateReference" : "'+lritCTList[0].Sea_Area_Certificate_Reference__c
                                                                    +'", "seaAreaCertificateType" : "'+lritCTList[0].Sea_Area_Certificate_Type__c
                                                                    +'", "gmdss" : "'+lritCTList[0].GMDSS__c
                                                                    +'", "ssas" : "'+lritCTList[0].SSAS__c
                                                                    +'", "transceiverManufacturer" : "'+lritCTList[0].Make__c
                                                                    +'", "transceiverModel" : "'+lritCTList[0].Model__c
                                                                    +'", "transceiverNumber" : "'+lritCTList[0].Mobile_Number__c
                                                                    +'", "vesselName" : "'+lritCTList[0].Vessel_Name__c
                                                                    +'", "shipType" : "'+lritCTList[0].Ship_Type__c
                                                                     +'", "inmarsatSerialNumber" : "'+lritCTList[0].Inmarsat_Serial_Number__c
                                                                     +'", "testReason" : "'+testReason
                                                                    +'","message":"success" }');
                Error_Log__c log = new Error_Log__c();
              log.Error_Message__c = testNumber+'/'+imo+':Success';
                log.Functionality__c = 'Get Conformance Test';
              insert log;
        
            }
            else{
              RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500", "testnumber" : "'+testNumber+'","imo" : "'+imo+'","message":"Invalid test number or imo" }');
            Error_Log__c log = new Error_Log__c();
              log.Error_Message__c = testNumber+'/'+imo+':Invalid test number or imo';
                log.Functionality__c = 'Get Conformance Test';
              insert log;
            }
                
            }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = testNumber+'/'+imo+':'+e.getMessage();
            log.Functionality__c = 'Get Conformance Test';
            insert log;
        }
    }
}