/**
* @author Prakash Burru
* @date Sep 15, 2021
*
*
* @description This class handles the search input to get the appropriate data from the NDC server
*
*/
public class NDC_IMO_SearchController {
    public String searchKey {get;set;}
    public String imoNumber {get;set;}
    public String shipName {get;set;}
    public String callSign {get;set;}
    public String mmsi {get;set;}
    public String shipType {get;set;}
    public String message {get;set;}
    public String emptyMessage {get;set;}
    public String dataUserProviderName {get;set;}
    public String registered {get;set;}
    public String flagReportingInterval {get;set;}
    public String currentReportingInterval {get;set;}
    public String shipborneEquipmentIdentifier {get;set;}
    public String gnssPosition {get;set;}
    public String latitude {get;set;}
    public String longitude {get;set;}
    public String link {get;set;}
    public boolean showlink {get; set;}
    //public String CTRCopy {get;set;} 
    string username;
    String password;
    String endpoint;
    
    public NDC_IMO_SearchController(){
        username = System.Label.NDC_Username;
        password = System.Label.NDC_Password;
        endpoint = System.Label.NDC_Endpoint;
    }
    
    public void clear(){
        searchKey = '';
        imoNumber = '';
        shipName = '';
        callSign = '';
        mmsi = '';
        shipType = '';   
        message = '';
        emptyMessage = '';
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
    
    public void searchIMO(){
        System.debug('searchKey ::: '+searchKey);
        message = '';
        emptyMessage = '';
        if(String.isBlank(searchKey)){
            searchKey = '';
            imoNumber = '';
            shipName = '';
            callSign = '';
            mmsi = '';
            shipType = ''; 
            emptyMessage = 'Please enter a valid IMO number.';
        }else{
            emptyMessage = '';
            try{
            //List<ConformanceTestReport__c> cftr = [Select Id, Link__c from ConformanceTestReport__c where CTRRequestRecordNumber__r.IMO__c =:searchKey and CTRRequestRecordNumber__r.Vessel_Flag__c='Panama' and CTRRequestRecordNumber__r.Status__c = 'Completed' LIMIT 1];
            List<LRIT_CTR_Request__c> lritctrL = [Select Id, Vessel_Flag__c, CreatedDate, (Select Id, Link__c from Conformance_Test_Reports__r where CTRStatus__c='Valid' order by createddate desc) from LRIT_CTR_Request__c where Status__c = 'Completed' and IMO__c=:searchKey order by createddate desc];
            System.debug('>>>>>'+lritctrL);
            if(lritctrL.size() > 0){
                if(lritctrL[0].Vessel_Flag__c != 'Panama - PAN' && lritctrL[0].Conformance_Test_Reports__r.size() > 0){
                    //showlink = false;
                    System.debug('lritctrL[0].Conformance_Test_Reports__r[0].Link__c ::::: '+lritctrL[0].Conformance_Test_Reports__r[0].Link__c);
                    if(!String.isBlank(lritctrL[0].Conformance_Test_Reports__r[0].Link__c)){
                        showlink = true;
                        message = 'Ship has a newer CTR under a different Flag i.e.,'+lritctrL[0].Vessel_Flag__c+' and was created on '+lritctrL[0].createddate;
                        link = lritctrL[0].Conformance_Test_Reports__r[0].Link__c;
                    }else{
                        showlink = false;
                        link = 'CTR is not available, Please contact Pole Star support team.';
                    }
                    
                }else if(lritctrL[0].Vessel_Flag__c == 'Panama - PAN' && lritctrL[0].Conformance_Test_Reports__r.size() > 0){
                    if(!String.isBlank(lritctrL[0].Conformance_Test_Reports__r[0].Link__c)){
                        showlink = true;
                        link = lritctrL[0].Conformance_Test_Reports__r[0].Link__c;
                    }else{
                        showlink = false;
                        link = 'CTR is not available, Please contact Pole Star support team.';
                    } 
                }
            }else{
                showlink = false;
                link = 'CTR is not available, Please contact Pole Star support team.';
            }
            
            list<MDIResponceWrapper> mdiwraplist= new list<MDIResponceWrapper>();
            HttpResponse res = getAuthenticationResponse('identification');
            MDIGNSSResponceWrapper gnsswrap = getGnssData();
            if(res.getStatusCode() == 200){
                //message = '';
                MDIResponceWrapper mdiRec = (MDIResponceWrapper)JSON.deserialize(res.getBody(), MDIResponceWrapper.class);
                if(gnsswrap != null){
                   if((Datetime.valueOf(gnsswrap.gnssPosition) > DateTime.now().addDays(-1)))
                   {
                   //if(mdiRec.flagReportingInterval == 'EVERY_6_HOURS'){
                       assignValues(mdiRec, gnsswrap);
                   }
                       else{
                        //imoNumber = '';
                        assignValues(mdiRec, gnsswrap);
                        message = 'IMO number '+mdiRec.imoNumber+' is registered in the Panama NDC but it is not reporting since '+gnsswrap.gnssPosition;
                        
                       }
                     
                }else{
                    imoNumber = '';
                    message = 'Ship is not reporting yet .';
                    assignValues(mdiRec, gnsswrap);
                }
            }else{
                imoNumber = '';
                /*List<String> subs = new List<String>();
                subs.add('IMO Number ');          
                subs.add('[');
                subs.add(']');*/
                //message= String.format('{0}{1}'+searchKey+ '{2}'+ ' is not currently registered under Panama NDC.', subs);
                message = 'IMO Number '+searchKey +' is not currently registered under Panama NDC.';
                
               
            }
             
        }catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
        }
        }
        
    }
    
    public MDIGNSSResponceWrapper getGnssData(){
        HttpResponse res = getAuthenticationResponse('mostrecentposition');
        if(res.getStatusCode() == 200){
            MDIGNSSResponceWrapper mdiRec = (MDIGNSSResponceWrapper)JSON.deserialize(res.getBody(), MDIGNSSResponceWrapper.class);
            return mdiRec;
        }else{
            return null;
        }
    }
    
    public void assignValues(MDIResponceWrapper mdiRec, MDIGNSSResponceWrapper gnsswrap){
        imoNumber = mdiRec.imoNumber;
                        shipName = mdiRec.shipName;
                        callSign = mdiRec.callSign;
                        mmsi = mdiRec.mmsi;
                        shipType = mdiRec.shipType;  
                        dataUserProviderName = mdiRec.dataUserProviderName; 
                        registered = mdiRec.registered; 
                        flagReportingInterval = mdiRec.flagReportingInterval; 
                        currentReportingInterval = mdiRec.currentReportingInterval; 
                        shipborneEquipmentIdentifier = mdiRec.shipborneEquipmentIdentifier;
        if(gnsswrap != null){
            gnssPosition = gnsswrap.gnssPosition;
                        latitude = gnsswrap.latitude;
                        longitude = gnsswrap.longitude;
        }
                        
    }
    
    public class MDIGNSSResponceWrapper {
        public String gnssPosition;
        public String latitude;
        public String longitude;
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
    
}