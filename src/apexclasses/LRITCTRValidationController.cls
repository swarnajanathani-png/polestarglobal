public class LRITCTRValidationController {
	public List<LRIT_CTR_Request__c> lritCTRRequests {get; set;}
    public String imoNumber {get;set;}
    public String shipName {get;set;}
    public String callSign {get;set;}
    public String mmsi {get;set;}
    public String shipType {get;set;}
    public String gnssPosition {get;set;}
    public String errorMessage{get;set;}
    public String searchKey{get;set;}
    public String isAMP {get;set;}
    
    string username;
    String password;
    String endpoint;
    
    // Constructor
    public LRITCTRValidationController() {
        try{
        	String id = ApexPages.currentPage().getParameters().get('id');
            isAMP = ApexPages.currentPage().getParameters().get('isAMP');
            username = System.Label.NDC_Username;
        	password = System.Label.NDC_Password;
        	endpoint = System.Label.NDC_Endpoint;
            errorMessage = '';
            List<LRIT_CTR_Request__c> lritRequest = [Select Id,IMO__c,Vessel_Name__c,MMSI__c,Call_Sign__c,LRIT_Conformance_Test__r.Ship_Type__c,
                                                     Vessel_Flag__c,LRIT_CTR_Status__c,Numbers_and_Letters__c, VesselMMSI__c,
                                                     Extended_Until__c,Authorization_Number__c
                                                     FROM LRIT_CTR_Request__c WHERE Id=:id];
        	String imo =lritRequest[0].IMO__c; 
            String vesselFlag = lritRequest[0].Vessel_Flag__c;
            if(lritRequest[0].LRIT_CTR_Status__c == 'Valid'){
            	lritCTRRequests = [Select Id,Valid_Until_By_Due_Print__c,Vessel_Flag__c,Due_for_printing_date__c,Verification_Code__c,Auto_CTR__c,
                           IMO__c,IMO_Number__c,Call_Sign__c,Vessel_Name__c,MMSI__c,Sea_Area_Type__c,LRIT_CTR_Status__c,
                           Transceiver_Make__c,Transceiver_Model__c,IMN__c,Equipment_Serial_Number__c,Numbers_and_Letters__c, VesselMMSI__c,
                           Extended_Until__c, Authorization_Number__c
                           From LRIT_CTR_Request__c Where IMO__c=:imo 
                           and Vessel_Flag__c=:vesselFlag and LRIT_CTR_Status__c != null ORDER BY LRIT_CTR_Status__c ASC ];
            }
            else{
            	lritCTRRequests = [Select Id,Valid_Until_By_Due_Print__c,Vessel_Flag__c,Due_for_printing_date__c,Verification_Code__c,Auto_CTR__c,
                           IMO__c,IMO_Number__c,Call_Sign__c,Vessel_Name__c,MMSI__c,Sea_Area_Type__c,LRIT_CTR_Status__c,
                           Transceiver_Make__c,Transceiver_Model__c,IMN__c,Equipment_Serial_Number__c,Numbers_and_Letters__c, VesselMMSI__c,
                           Extended_Until__c,Authorization_Number__c
                           From LRIT_CTR_Request__c Where Id=:id 
                           and LRIT_CTR_Status__c != null];
             
            }
    		
            if(vesselFlag == 'Panama - PAN') {
                list<MDIResponceWrapper> mdiwraplist= new list<MDIResponceWrapper>();
                NDC_IMO_SearchController ndc = new NDC_IMO_SearchController();
                searchKey = imo;
                HttpResponse res = getAuthenticationResponse('identification');
                if(res.getStatusCode() == 200){
                    //message = '';
                    MDIResponceWrapper mdiRec = (MDIResponceWrapper)JSON.deserialize(res.getBody(), MDIResponceWrapper.class);
                    imoNumber = mdiRec.imoNumber;
                    shipName = mdiRec.shipName;
                    callSign = mdiRec.callSign;
                    mmsi = mdiRec.mmsi;
                    shipType = lritRequest[0].LRIT_Conformance_Test__r.Ship_Type__c; 
                 /*   HttpResponse res1 = getAuthenticationResponse('mostrecentposition');
                    if(res1.getStatusCode() == 200){
            			MDIGNSSResponceWrapper gnssWrap = (MDIGNSSResponceWrapper)JSON.deserialize(res1.getBody(), MDIGNSSResponceWrapper.class);
            			gnssPosition = gnssWrap.gnssPosition; 
        			} */
                    
                }
                else if(res.getStatusCode() == 404){
                    errorMessage = 'IMO Number '+imo +' is not currently registered under Panama NDC.';
                }
                else{
                    errorMessage = 'Server is down please try again after some time';    
                }
            }
            else{
            	imoNumber = imo;
                shipName = lritRequest[0].Vessel_Name__c;
                callSign = lritRequest[0].Numbers_and_Letters__c;
                mmsi = lritRequest[0].VesselMMSI__c;
                shipType = lritRequest[0].LRIT_Conformance_Test__r.Ship_Type__c;    
            }
        }
        Catch(Exception e){
        	System.debug('Exception Occurred'+e);    
        }
    }
    
    public HttpResponse getAuthenticationResponse(String identity){
        list<MDIResponceWrapper> mdiwraplist= new list<MDIResponceWrapper>();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint+'api/v1/flag/fleetoverview/'+searchKey+'/'+identity);                   
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');
        HttpResponse res = http.send(req);
        return res;
    }
    
    public class MDIResponceWrapper {
        public String imoNumber;
        public String shipName;
        public String callSign;
        public String mmsi;
        public String shipType;
        //public String CTRCopy;
        public String dataUserProviderName;
        public String registered;
        public String gnssPosition;
        public String flagReportingInterval;
        public String currentReportingInterval;
        public String shipborneEquipmentIdentifier;
    }
    
    public class MDIGNSSResponceWrapper {
        public String gnssPosition;
        public String latitude;
        public String longitude;
    }
}