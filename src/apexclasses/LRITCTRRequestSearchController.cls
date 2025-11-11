/**
*	@Who    Tiago Lopes @CloudSocius
*	@What	Controller for InvoiceSearch page
*	@When	25/03/2017
**/
public class LRITCTRRequestSearchController {

	static public String CURRENCY_GBP = 'GBP';
    static public String CURRENCY_USD = 'USD';
    static public String LANGUAGE = 'en_US';

	public String profileName {get; set;}
    public String captchaResponse {get; set;}
    public Boolean captchaVerified {get; set;}
    public String ctrNumber {get; set;}
    public String invNumber {get;set;}
    public String objType	{get;set;}
    public Boolean searched {get; set;}
    public List<LRIT_CTR_Request__c> requests {get; set;}
    public List<sObject> results	{get;set;}
    public Invoices__c request		{get;set;}

    public String lang {get{ return LANGUAGE; }}
    public String sha1signature {get;set;}
    public Integer convertedAmount {get { return Integer.valueOf(((Invoices__c)results.get(0)).Amount__c*100);}}
    public String singleLineAddress {get;set;}
    //
    public BCard_settings__c  settings;
    // var to store PSPid depending on currency
    public String pspid         {get;set;}
    public String url           {get;set;}
    public String guid          {get;set;}


	public LRITCTRRequestSearchController() {
		profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        captchaVerified = false;
        results = new List<sObject>();
        searched = false;
	}
	
	/**
	*	@description Sets context for queries to invoice or LRITCTRR records to show in frontEnd
	*	@return null pageReference
	**/
	public PageReference searchRecords(){		
		if (captchaVerified){
			System.debug('ctrNumber -> ' + ctrNumber);
			if((ctrNumber != null && !String.isBlank(ctrNumber)) && (invNumber == null || String.isBlank(invNumber))){
				queryResults('LRIT_CTR_Request__c','Name', ctrNumber);
			}
			else if((invNumber != null && !String.isBlank(invNumber)) && (ctrNumber == null || String.isBlank(ctrNumber))){	
				queryResults('Invoices__c','Name', invNumber);
			}
			else{
				results.clear();
			}
			searched = true;
		}
		return null;
	}
	

	/**
	*	@description method to Query SObject depending on what customer searches in FrontEnd (LRITCTRR/Invoice), builds dynamic query depending on the params sent by searchRecords()
	*	@param obj with the name of the Object to query, whereClause1 with the name of the field to be filtered, whereClause2 with the value of the field to be filtered
	**/
	public void queryResults(String obj, String whereClause1, String whereClause2){
		if(obj != null && whereClause1 != null && whereClause2 != null){
			String query = 'SELECT Id, Name, Amount__c, Payed__c, Billing_Address__c, Currency__c, Delivery_Email_Address__c, EU_Company_Name__c, Delivery_phone_Number__c FROM ';
			try{
				String querystring = query + obj + ' WHERE ' + whereClause1 + ' = ' + '\'' + whereClause2 + '\'' + 'LIMIT 1';
				results = Database.query( querystring);
				searched = true;
				System.debug('results -> ' + results);
			}
			catch(Exception e){
				System.debug('There was a problem querying ' + obj + ' object: ' + e.getMessage());
			}
		}
	}

	/**
    *   @description fetches PSPID from custom settings to be used as a barclaycard identifier
    *   @return String with PSPId
    **/
    public String getPSPId(String curr){
        String idString;
        if(curr != null && !String.isBlank(curr)){
            if(curr == CURRENCY_GBP){
                idString = settings.PSPID_GBP__c;
            }
            else if(curr == CURRENCY_USD){
                idString = settings.PSPID_USD__c;
            }
        }
        return idString;
    }

	/**
    *   @description method to handle payNow button, which in this page works to pay Invoices(button only shows when invoices are searched. 
    *				 Processes parameters to send to barclaycard form url, 
    *      			 includes fetching PSPIDs from custom settings and Hashing URL with sha1
    *   @return null PageReference
    **/
    public PageReference payNow(){
    	request = (Invoices__c)results.get(0);
        if(!request.Payed__c){
            settings = BCard_settings__c.getOrgDefaults();
            //generate
            if(settings != null){
                if(request.Currency__c != null){
                    pspid = getPSPId(request.Currency__c);
                    //generate guid order id
                    guid = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(Crypto.getRandomInteger().format()))).substring(0,10);
                    //
                    generateSHA1();
                    //get form URL
                    if(!runningInASandbox()){
                        url = settings.Live_form_url__c;
                    }
                    else{
                        url = settings.Test_form_URL__c;
                    }
                }
            }
            else{
                System.debug('Error - No BarclayCard settings found in system!');
            }
        }
        else{
            System.debug('Attempt to duplicate payment');
            insert new Credit_Card_Payment_error_logs__c(Related_Invoice__c = request.Id,
                                                                Error_Description__c = 'Attempt to duplicate paymentfor this Invoice.');
        }
        return null;
    }

    //helper
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    /**
    *   @description method to generate SHA1 parameter encoding to send to barclaycard from
    **/
    public void generateSHA1(){
        String passphrase = settings.SHA1Passphrase__c;
        try{
            if(passphrase != null){
                if(request.Amount__c != null && request.EU_Company_Name__c != null && request.Currency__c != null && request.Delivery_Email_Address__c != null && request.Name != null
                 && request.Billing_Address__c != null && request.Delivery_phone_Number__c != null){
                    //remove new lines from address
                    singleLineAddress = request.Billing_Address__c.replaceAll('\r\n', ', ');
                    System.debug('billing address -> ' + singleLineAddress);
                    String url =    'AMOUNT=' + Integer.valueOf(request.Amount__c*100) + passphrase +
                                    'CN=' + request.EU_Company_Name__c + passphrase +
                                    'CURRENCY=' + request.Currency__c + passphrase +
                                    'EMAIL=' + request.Delivery_Email_Address__c + passphrase +
                                    'LANGUAGE=' + LANGUAGE + passphrase +
                                    'ORDERID=' + request.Name + '-' + guid + passphrase +
                                    'OWNERADDRESS=' + singleLineAddress + passphrase +
                                    'OWNERTELNO=' + request.Delivery_phone_Number__c + passphrase +
                                    'PARAMPLUS=' + 'RECID=' + request.Id + passphrase +
                                    'PSPID=' + pspid + passphrase;

                    Blob shasign = Blob.valueOf(url);
                    //encode with sha1
                    Blob sha1signat = Crypto.generateDigest('SHA1', shasign);
                    sha1signature = EncodingUtil.convertToHex(sha1signat);
                }
            }
        }
        catch(Exception e){
            System.debug('Something went wrong with generating SHA1 hash URL: ' + e.getMessage());
            insert new Credit_Card_Payment_error_logs__c(Related_Invoice__c = request.Id,
                                                                Error_Description__c = 'Something went wrong with generating SHA1 hash URL, it might be faulty parameters: ' + e.getMessage());
        }

    }
	//
	public void verifyCaptcha() {
        if (captchaResponse != null) {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
            request.setBody('secret=6LcoUyQTAAAAAOAQy6G3fPoATsfS36lmawfnVK4s&response='+ captchaResponse);
            
            Http http = new Http();
            HttpResponse response;
            if (Test.isRunningTest()) {
                response = new HttpResponse();
                response.setStatusCode(200);
                response.setBody('{"success": true}');
            } else {
            	response = http.send(request);        
            }

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseObject = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                captchaVerified = (Boolean)responseObject.get('success');
            }
        }
    }

}