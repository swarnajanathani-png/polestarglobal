@RestResource(urlMapping='/LRITCTRSearchByIMO/*')
global with sharing class LRITCTRSearchByIMO {
    Static String imo = '';
    @HttpPost
    global static void ctrSearchByIMO() {
        Map<String, Object> m = new Map<String,Object>();
        try{
            RestRequest req = RestContext.request;
            API_Request__c apiRequest = new API_Request__c();
            apiRequest.Name = 'CTR Search';
            apiRequest.Product_Type__c = 'LRIT CTR';
            apiRequest.Request_Type__c = 'Inbound';
            apiRequest.Request_JSON__c = RestContext.request.requestBody.toString();
            insert apiRequest;
                    
            Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(
                                                                RestContext.request.requestBody.toString());
            Object LRITCTR = (Object)params.get('LRITCTR');
            m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(LRITCTR));
            imo = (String) m.get('IMO');
                    
            List<LRIT_CTR_Request__c> lritctrL = [Select Id,IMO__c,Vessel_Name__c,MMSI__c,Call_Sign__c,LRIT_Conformance_Test__r.Ship_Type__c,
                                                     Vessel_Flag__c,LRIT_CTR_Status__c,Numbers_and_Letters__c, VesselMMSI__c from LRIT_CTR_Request__c where Status__c = 'Completed' and IMO__c=:imo order by createddate desc];
            if(lritctrL.size() > 0){
				IMOSearchWrapper imoSearchWrapper = new IMOSearchWrapper();
                imoSearchWrapper.ctrId = lritctrL[0].Id;
				imoSearchWrapper.imoNumber = lritctrL[0].IMO__c;
				imoSearchWrapper.shipName = lritctrL[0].Vessel_Name__c;
				imoSearchWrapper.callSign = lritctrL[0].Numbers_and_Letters__c;
				imoSearchWrapper.mmsi = lritctrL[0].VesselMMSI__c;
				imoSearchWrapper.shipType = lritctrL[0].LRIT_Conformance_Test__r.Ship_Type__c;
				imoSearchWrapper.validationPortalURL = System.Label.LRITValidationPortalURL+lritctrL[0].Id;
				imoSearchWrapper.StatusCode = '200';
				imoSearchWrapper.message = 'Success';
				String jsonString = JSON.serialize(imoSearchWrapper);
				RestContext.response.addHeader('Content-Type', 'application/json');
				RestContext.response.responseBody = Blob.valueOf(jsonString);
				Error_Log__c log = new Error_Log__c();
				log.Error_Message__c = 'CTR Search by IMO is success' + jsonString;
				insert log;
				
			}
            else {
            	RestContext.response.addHeader('Content-Type', 'application/json');
            	RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"No CTR Found" }');
            	Error_Log__c log = new Error_Log__c();
            	log.Error_Message__c = 'No CTR Found with given ' + imo;
                log.Functionality__c = 'CTR Search';
            	insert log;    
            }

        }Catch(Exception e){
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{ "statuscode" : "500","message":"'+e.getMessage()+'"}');
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+m;
            log.Functionality__c = 'CTR Search';
            insert log;
        }
    }
	    
	public class IMOSearchWrapper {
        public String ctrId;
        public String imoNumber;
        public String shipName;
        public String callSign;
        public String mmsi;
        public String shipType;
        public String gnssPosition;
		public String validationPortalURL;
        public String statusCode;
        public String message;
    }
}