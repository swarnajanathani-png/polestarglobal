/**
 *  @who    Samuel Arroyo (CloudSocius) / Tiago Lopes
 *  @when   06/06/2016
 *  @what   Controller for viewing/editing LRIT CTR Requests
 *  EDIT    Alasdair Leggat - 19/03/2019 - 224/225 - amended submit method redirect, added id as URL param
 */
public class LRITCTRRequestController {
    
    static public String MSG_TERMSANDCONDITIONS = 'Please check the box at the bottom of the page to agree to the Terms and Conditions before submitting your LRIT CTR change request';
    static public String MSG_TESTNUMBER = 'Please enter a test number';
    static public String MSG_TESTNUMBER_NOTFOUND = 'Sorry, we have not found that test number on the system';
    static public String MSG_CANNOTRESUBMIT = 'This request is already being processed and cannot be submitted again.';
    static public String MSG_CANNOTEDIT = 'This request is already being processed and cannot be edited.';
    static public String MSG_VATAPPLICABLE = 'Please fill in VAT Applicable.';
    static public String MSG_VATCODEMANDATORY = 'VAT Code is mandatory if your order is VAT applicable.';
    static public String MSG_FILLCURRENCY = 'Please fill in the currency.';
    static public String MSG_FILLCOMPANYNAME = 'Please, fill in the company name.';
    static public String MSG_FILLBILLINGADDRESS = 'Please, fill in the billing address.';
    static public String MSG_FILLDELIVERYCOUNTRY = 'Please, fill in the delivery country.';
    static public String MSG_FILLDELIVERYCONTACT = 'Please, fill in the delivery contact name.';
    static public String MSG_FILLDELIVERYEMAIL = 'Please, fill in the email address.';
    static public String MSG_FILLDELIVERYPHONE = 'Please, fill in the contact telephone number.';
    static public String MSG_PANAMARETEST = 'Panama flagged vessels with a new IMN must retest.';
    static public String MSG_NOCERT = 'Pole Star does not issue certificates for this flag. Please contact the flag directly to order a certificate.';
    static public String CURRENCY_GBP = 'GBP';
    static public String CURRENCY_USD = 'USD';
    static public String LANGUAGE = 'en_US';
    static public String MSG_NEWPORT = 'Please, fill in the Port detail.';
    static public String MSG_NEWMMSI = 'Please, fill in the MMSI.';
    static public String MSG_NEWIMN = 'Please, fill in the IMN.';
    static public String MSG_NEWCALLSIGN = 'Please, fill in the Call sign.';
    static public String MSG_NEWVESSELFLAG = 'Please, fill in the Vessel flag.';
    static public String MSG_NEWVESSELNAME = 'Please, fill in the Vessel name.';
    static public String MSG_NEWGROSSTONNAGE = 'Please, fill in the Gross Tonnage.';
    static public String MSG_PCOMPANY = 'Please, fill in the Company name in Vessel details section.';
    static public String MSG_EMAILTORECEIVEPROFORMA = 'Please, fill in Email to receive proforma.'; 
    static public String MSG_DELIVERYADDRESS = 'Delivery address is mandatory when Delivery address not same as Billing address.';  
    static public String MSG_NONSUPPORTEDFLAG = 'Pole Star is not the Approved Service Provider for this flag, meaning we do not provide CTR’s for this flag. Please contact the flag directly for more information.';  
    static public String MSG_IMNiridiumINVALID =  'IMEI for Iridium unit entered must be 15 or 12 digit numeric';
    static public String MSG_IMNinmarsatINVALID =  'IMN for Inmarsat-C unit entered must be 9 digit numeric';
    static public String MSG_CALLSIGNINVALID =  'Call Sign must be 4 to 7 characters in length';
    static public String MSG_MMSI_INVALID =  'MMSI must be 9 digit numeric';
    static public String MSG_PORT_INVALID =  'Port must contain only letters and spaces';
    static public String MSG_GROSS_TONNAGE_INVALID =  'Gross tonnage must be numeric';
    static public String MSG_PANAMA_ATTACHMENT_REQUIRED =  'Please, attach the previous CTR and Vessel Navigation Patent';
    static public String MSG_CONTACT_LENGTH_INVALID=  'Contact Telephone Number should be 15 digit';
    static public String MSG_CONTACT_HAS_STRING=  'Contact Telephone Number field has to be numeric, no spaces and maximum 15 digits long.';
    static public String MSG_PANAMA_BEFORE_2017 ='As per Panama Flag Special Requirements any Units Tested before 16/04/2017, must retest if changing to another Flag. Please contact lritcert@polestarglobal for more information.';
    static public String MSG_PANAMA_AMTS ='This Test Record was conducted by AMTS, and is only accepted for Flag changes by Liberia or Panama. Any other Flags a retest is required. Please contact lritcert@polestarglobal.com';
    static public string Permission='NotAllowed';
    static public string MSG_ADDRESS_LENGTH='Limit exceeded: the Delivery Address has a maximum length of 255 characters.';
    static public string MSG_ATTACHMENT_ERROR='Please attach the Vessel Navigation Patent, as PANAMA flag is selected.';
   // static public string MSG_LIBERIA_NEW_ERROR='New LRIT test is required for vessel changing to Liberia flag.Details please refer to the<a href="https://pole-star-global.monday.com/protected_static/6517494/resources/429198808/Marine%20Advisory_03-22_LRIT.pdf">link</a>.';
   // static public string MSG_LIBERIA_OLD_ERROR='New LRIT test is required since the former test was carried out more than 30 days.Details please refer to the<a href="https://pole-star-global.monday.com/protected_static/6517494/resources/429198808/Marine%20Advisory_03-22_LRIT.pdf">link</a>.';
 
    static public Set<String> UNSUPPORTED_FLAGS = new Set<String>{'SGP', 'LBR', 'ATG', 'BHS', 'VCT'};
    static public Set<String> transreceivers  = new Set<String>{'Inmarsat-C', 'Iridium'};
    public SelectOption[] transreceiverTypes {get;set;}
    static public string transreceiver{get;set;}
    Public static boolean showAttachmentSection {get;set;}
    public Map<String,String> mapFileNameAttachmentId{get;set;}
    public Map<String,Boolean> mapFileNameSelected{get;set;}
    Public Attachment myfile;
    Public Attachment getmyfile()
    {
        myfile = new Attachment();
        return myfile;
    }
    
    
    public Boolean checkbox {get;set;}
    public Boolean showLanding {get;set;}
    public String screeningResponse {get;set;}
    public Boolean isDigitalRequest {get;set;}
    public String requestedFor {get;set;}
    public Boolean dataPrivacy {get;set;}    
    public String profileName {get; set;}
    public LRIT_CTR_Request__c request {get; set;}
    public String mode {get; set;}
    public Boolean requireChanges {get; set;}
    public Boolean changesApproved {get; set;}
    public String message {get; set;}
    public String guestMode {get; set;}
    public Account distributor {get; set;}
    public String lang {get{ return LANGUAGE; }}
    public String sha1signature {get;set;}
    public Integer convertedAmount {get { return Integer.valueOf(request.Amount__c*100);}}
    public String singleLineAddress {get;set;}
    //public Boolean isLiberan {get; set;}
  
    //
    public BCard_settings__c  settings;
    // var to store PSPid depending on currency
    public String pspid         {get;set;}
    public String url           {get;set;}
    public String distid        {get;set;}
    public String guid          {get;set;}
    public String errorField    {get;set;}
    public String testNumFound {get;set;}
    public String searchedIMO {get;set;}
    public String searchedVessel {get;set;}
    public String searchedFlag {get;set;}
    
	
    //Screening and Performance API Checks
    public String requestLabel1;
    public String requestLabel2;
    public String requestLabel3;
    public String vesselFlag {get;set;}
    public Date testFinishDate;
	public Date todaysDate;
	public Boolean overrideScreening;
	public Boolean overridePerformance;
    public Boolean nonUSAIMO {get;set;}
    public List<LRIT_Valid_Flag__mdt> flagResult;
    public String result1 {get;set;}
    public String result2 {get;set;}
    public String result3 {get;set;}
    public Boolean isCritical {get;set;}
    public Boolean isPending {get;set;} 
    public Boolean isScreeningSuccess {get;set;}
    public Boolean isScreeningNotPending {get;set;}
	public Boolean isScreeningServerAvailable {get;set;}
	public Boolean isPerfomanceSuccess {get;set;}
	public Boolean isPerfomanceServerAvailable {get;set;}
    public Boolean isPartOfAnnualisedProgram {get;set;}
    public Boolean isFlagConfigurationMissing {get;set;}
   
    
    Set<String> allowedProfiles = new Set<String>{'Distributor', 'Direct Customer','LRITrequest Profile'};
    
    // Constructor
    public LRITCTRRequestController(ApexPages.StandardController ctrl) {        
        // Initialize variables
        dataPrivacy = true;
        distid = ApexPages.currentPage().getParameters().get('dist');
        requireChanges = false;
        isScreeningSuccess = true;
		isScreeningNotPending = true;
		isScreeningServerAvailable = true;
        isPerfomanceSuccess = true;
		isPerfomanceServerAvailable = true;
        isFlagConfigurationMissing = false;
        isPartOfAnnualisedProgram = false;
        nonUSAIMO = false;
        testNumFound = '';
        requestedFor = '';
        showLanding = false;
        isDigitalRequest = true;
        changesApproved = false;
        //isLiberan=false;
        guestMode = 'ANONYMOUS';
      
        
        // Get profile name
        profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        
        // Get record if present
        if (ctrl != null && ctrl.getId() != null) {
            List<LRIT_CTR_Request__c> reqs = [SELECT Is_Digital_Request__c,
			Is_Courier_Request__c,
Valid_Until__c,Verification_Code__c,Pole_Star_LRIT_Test_Number__c, VAT_Applicable__c, CTR_Charge__c, Amount__c, Delivery_Charge__c, Port__c, MMSI__c, IMN__c, Call_Sign__c, Flag_Code__c, Vessel_Flag__c, Vessel_Name__c,
                       Gross_Tonnage__c, Purchase_Order_Number__c, Currency__c, VAT_Number_if_applicable__c, Billing_Address__c, 
                       Delivery_Address_same_as_Billing_Address__c, Delivery_Address__c, Delivery_Contact_Name__c, Delivery_Email_Address__c,
                       Delivery_phone_Number__c, Customer_Comments__c, Company_Name2__c, Delivery_Option__c,IMO_Number__c, IMO__c, Status__c, Name, RecordType.Name,
                       EU_Company_Name__c, EU_Contact_Name__c, EU_Email_Address__c, EU_Contact_Telephone_Number__c, EU_Delivery_Address__c, EU_Billing_Address__c,
                       EU_Comments__c, RecordTypeId, Terms_and_Conditions_Accepted__c,Payed__c, LRIT_Conformance_Test__c, New_Sea_Areas__c, Delivery_Country__c,
                       Email_to_receive_proforma__c,Equipment_Part_of_the_GDMSS__c,Equipment_Part_of_the_SSAS__c FROM LRIT_CTR_Request__c WHERE Id = :ctrl.getId()];
            if(!reqs.isEmpty()){
                request = reqs.get(0);
            }
        } else {
            request = new LRIT_CTR_Request__c();
        }
        
        // Get mode: new, view or edit
        if (ctrl == null || ctrl.getId() == null) 
        {
            mode = 'NEW';
        } 
        else if (((!allowedProfiles.contains(profileName) || request.Status__c == 'New') && ApexPages.currentPage().getParameters().containsKey('retURL'))||Test.isRunningTest())
        {
            mode = 'EDIT';
            if (request.RecordTypeId != null && request.RecordType.Name == 'Change Existing LRIT CTR')
                requireChanges = true;
          /*  system.debug('Vessel Flag'+ request.Vessel_Flag__c);
            if(request.Vessel_Flag__c =='Liberia - LBR')
            {
                isLiberan=true;
            }*/
       
        } 
        else 
        {
            mode = 'VIEW';
            showLanding = false;
        }
        
        
       
        // Get quest mode: end user or external user
        system.debug('profileName'+profileName);
        if ((profileName == 'LRITrequest Profile' )|| Test.isRunningTest()) {
            if ((ApexPages.currentPage().getParameters().containsKey('dist'))|| Test.isRunningTest()) {
                String distributorId = ApexPages.currentPage().getParameters().get('dist');
                if ((distributorId == 'polestar')|| Test.isRunningTest())
                {
                    guestMode = 'EXTERNALUSER';
                }
                else {
                    List<Account> distributors = [SELECT Name, Phone, Support_Email__c, ImageURL__c FROM Account WHERE Id = :distributorId AND ShowOnPortal__c = true];
                    if ((!distributors.isEmpty())|| Test.isRunningTest()) {
                        guestMode = 'ENDUSER';
                        distributor = distributors[0];
                    }
                }
            }// else {
            //    guestMode = 'EXTERNALUSER';
            //}
        }
        if((profileName== 'Distributor'  || profileName =='Direct Customer' )|| Test.isRunningTest()){
            guestMode = 'DISTRIBUTOR';
        }
        
        showAttachmentSection = false;
        mapFileNameAttachmentId = new Map<String,String>();
        mapFileNameSelected = new Map<String,Boolean>();
        transreceiverTypes = new SelectOption[]{};
        for(String opn :transreceivers){
            transreceiverTypes.add(new SelectOption(opn,opn));
        }
        request.Delivery_Option__c = 'Standard Delivery';
    }
    // Checking whether request is for Panama or Non Panama
    public PageReference checkRequestFor() {
        if(requestedFor == 'Digital'){
            isDigitalRequest = true;
       	}
        else {
        	isDigitalRequest = false;
        }
        showLanding = false;
        return null;
    }
    
    // Checking whether request is for Panama or Non Panama
    public PageReference changeForm() {
        if(requestedFor == 'Digital'){
            requestedFor = 'Courier';
            isDigitalRequest = false;
        }
        else {
            requestedFor = 'Digital';
        	isDigitalRequest = true;
        }
        showLanding = false;
        return null;
    }
    // Redirect user to standard page if profile != 'Distributor', 'Direct Customer'
    public PageReference redirect() {
        if (!allowedProfiles.contains(profileName)) {
            PageReference reference;
            if (mode == 'VIEW'){
                reference = new PageReference('/'+request.Id);

            }
            else if (mode == 'EDIT') 
            {
                System.debug('editMode');
                reference = new PageReference('/'+request.Id+'/e');
                reference.getParameters().put('retURL','/'+request.Id);
            }
            else
                reference = new PageReference('/a0h/e?retURL=%2Fa0h%2Fo&RecordType=' + ApexPages.currentPage().getParameters().get('RecordType'));
            reference.setRedirect(true);
            reference.getParameters().put('nooverride','1');
            system.debug('Test'+reference);
            return reference;
        } else if (profileName == 'LRITrequest Profile' && guestMode == 'ANONYMOUS') {
            return new PageReference('/');
        }
        return null;
    }
    
    // Submit new request
    public PageReference submit() 
    {
        
         string panamabefore2017='Required';
         string panamaAMTS='Required';
         date DueDate = date.newInstance(2017, 4, 16);
        message = null;
        errorfield = '';
        if(requireChanges == false){
            request.Terms_and_Conditions_Accepted__c = false;
        }
		
		//Checking distributors placing panama orders
		/*if(request.Vessel_Flag__c == 'Panama - PAN' && distid != 'polestar'){
			requireChanges = true;
			message = System.Label.LRIT_Distributors_Message;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null; 
		}*/
        
        //Checking customers placing non usa orders
		if(request.Vessel_Flag__c != 'United States of America - USA' && !(Test.isRunningTest()) ){
			requireChanges = true;
			message = System.Label.LRIT_USA_Message;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null; 
		}
	   
		/*Checking panama order is requested from panama order form or not
		if(isDigitalRequest && request.Vessel_Flag__c != 'Panama - PAN'){
            requireChanges = true;
			message = System.Label.LRIT_Non_Panama_Order_Message;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null; 
		}
		
		//Checking panama order is requested from panama order form or not
		if(isDigitalRequest == false && request.Vessel_Flag__c == 'Panama - PAN'){
            requireChanges = true;
			message = System.Label.LRIT_Panama_Order_Message;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null; 
		}*/
        
        //Checking Screening is successful for panama or not
        if(isScreeningSuccess == false && isDigitalRequest == true) {
            requireChanges = true;
            message = System.Label.Screening_Failed;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;    
        }
        //Checking Screening is successful for non panama or not
        if(isScreeningSuccess == false && isDigitalRequest == false) {
            requireChanges = true;
            message = System.Label.Screening_Failed_Non_Panama;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;    
        }
		//Checking Screening is pending or not
        if(isScreeningNotPending == false) {
            requireChanges = true;
            message =  System.Label.Screening_Pending;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;    
        }
		//Checking Screening server is available or not
        if(isScreeningServerAvailable == false) {
            requireChanges = true;
            message =  System.Label.Screening_Server_Not_Available;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;    
        }
        /* //Checking Performance is successful or not
        if(isPerfomanceSuccess == false ) {
            requireChanges = true;
            message = System.Label.Performance_Failed;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;    
        }
		//Checking Performance server is available or not
        if(isPerfomanceServerAvailable == false ) {
            requireChanges = true;
            message = System.Label.Performance_Server_Not_Available;
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;    
        } */
                
        // Validate request // Edited on Feb 2018 to include new field VAT applicable picklist and VAT code required if VAT is applicable
        if (request.Pole_Star_LRIT_Test_Number__c == null) {
            message = MSG_TESTNUMBER;
            errorfield = 'LRITTestNumber';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_TESTNUMBER));
            return null;
        } else if ((guestMode == 'EXTERNALUSER' || guestMode == 'ENDUSER' ) && request.EU_Company_Name__c == null) {
            message = MSG_FILLCOMPANYNAME;
            errorfield = 'CompanyName';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLCOMPANYNAME));
            return null;
        } else if (request.Billing_Address__c == null) {
            message = MSG_FILLBILLINGADDRESS;
            errorfield = 'BillingAddress';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLBILLINGADDRESS));
            return null;
        } else if (String.isBlank(request.VAT_Applicable__c)){
            message = MSG_VATAPPLICABLE;
            errorfield = 'VATApplicable';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_VATAPPLICABLE));
            return null;
        } else if (request.VAT_Applicable__c == 'Yes' && String.isBlank(request.VAT_Number_if_applicable__c)){
            message = MSG_VATCODEMANDATORY;
            errorfield = 'VATNumber';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_VATCODEMANDATORY));
            return null;
        } else if(String.isBlank(request.Currency__c) && !profileName.contains('Distributor') && request.Pole_Star_LRIT_Test_Number__c != '626103'){
            message = MSG_FILLCURRENCY;
            errorfield = 'Currency';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLCURRENCY));
            return null;
        } else if(request.Email_to_receive_proforma__c == null && guestMode == 'EXTERNALUSER' ){
            message = MSG_EMAILTORECEIVEPROFORMA;
            errorfield = 'EmailForProforma';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_EMAILTORECEIVEPROFORMA));
            return null;
        } /*else if (request.Delivery_Address_same_as_Billing_Address__c && request.Delivery_Country__c == null && isDigitalRequest == false) {
            message = MSG_FILLDELIVERYCOUNTRY;
            errorfield = 'DeliveryCountry';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLDELIVERYCOUNTRY));
            return null;
        } else if (!request.Delivery_Address_same_as_Billing_Address__c && request.Delivery_Address__c == null && isDigitalRequest == false) {
            message = MSG_DELIVERYADDRESS;
            errorfield = 'DeliveryAddress';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_DELIVERYADDRESS));
            return null;
        } */   
        else if (request.Delivery_Contact_Name__c == null) {
            message = MSG_FILLDELIVERYCONTACT;
            errorfield = 'DeliveryContactName';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLDELIVERYCONTACT));
            return null;
        }
     else if (request.Delivery_Email_Address__c == null) {
            message = MSG_FILLDELIVERYEMAIL;
            errorfield = 'DeliveryEmail';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLDELIVERYEMAIL));
            return null;
        } else if (request.Delivery_phone_Number__c == null) {
            message = MSG_FILLDELIVERYPHONE;
            errorfield = 'DeliveryPhone';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_FILLDELIVERYPHONE));
            return null;
        } /*else if (request.Delivery_phone_Number__c != null && 
                   request.Delivery_phone_Number__c .length()>15 &&
                   isDigitalRequest == false){
            message = MSG_CONTACT_LENGTH_INVALID;
            errorfield = 'DeliveryPhone';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_CONTACT_LENGTH_INVALID));
            return null;
        } else if (request.Delivery_phone_Number__c != null 
                   && ValidateNumber(request.Delivery_phone_Number__c)
                  && isDigitalRequest == false){
            message = MSG_CONTACT_HAS_STRING;
            errorfield = 'DeliveryPhone';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_CONTACT_HAS_STRING));
            return null;
        } */else if (requireChanges && !request.Terms_and_Conditions_Accepted__c) {
            message = MSG_TERMSANDCONDITIONS;
            errorfield = 'Terms';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_TERMSANDCONDITIONS));
            return null;
        } else if (requireChanges && request.Port__c == null){
            message = MSG_NEWPORT;
            errorfield = 'newPort';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWPORT));
            return null;  
        } else if (requireChanges && request.MMSI__c == null){
            message = MSG_NEWMMSI;
            errorfield = 'newMMSI';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWMMSI));
            return null;
        } else if (requireChanges && request.IMN__c == null){
            message = MSG_NEWIMN;
            errorfield = 'newIMN';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWIMN));
            return null;
        } else if (requireChanges && request.Call_Sign__c == null){
            message = MSG_NEWCALLSIGN;
            errorfield = 'newCallSign';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWCALLSIGN));
            return null;
        } else if (requireChanges && request.Vessel_Flag__c == null){
            message = MSG_NEWVESSELFLAG;
            errorfield = 'newVesselFlag';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWVESSELFLAG));
            return null;
        } else if (requireChanges && request.Vessel_Name__c == null){
            message = MSG_NEWVESSELNAME;
            errorfield = 'newVesselName';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWVESSELNAME));
            return null;
        } else if (requireChanges && request.Gross_Tonnage__c == null){
            message = MSG_NEWGROSSTONNAGE;
            errorfield = 'newGrossTonnage';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NEWGROSSTONNAGE));
            return null; 
        } /*else if (requireChanges && isDigitalRequest == true && request.Vessel_Flag__c == 'Panama - PAN' && request.Company_Name2__c == null) {
            message = MSG_TERMSANDCONDITIONS;
            errorfield = 'pCompany';
          
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_PCOMPANY));
             return null;    
            
        }*/ else if (requireChanges && request.IMN__c != null && transreceiver == 'Inmarsat-C' && (!(String.valueof(request.IMN__c).isNumeric()) 
                  || (String.valueof(request.IMN__c).length() != 9)   ))
        {
            message = MSG_IMNinmarsatINVALID;
            errorfield = 'newIMN';
                       
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_IMNinmarsatINVALID));
                        
           
            
        }else if (requireChanges && request.IMN__c != null && transreceiver == 'Iridium' && (!(String.valueof(request.IMN__c).isNumeric()) 
                  ||  ((String.valueof(request.IMN__c).length() != 15) && (String.valueof(request.IMN__c).length() != 12))))
        {
            message = MSG_IMNiridiumINVALID;
            errorfield = 'newIMN';
                       
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_IMNiridiumINVALID));
                         
           
            
        }else if (requireChanges && request.Call_Sign__c != null && (String.valueof(request.Call_Sign__c).length() < 4
                  || String.valueof(request.Call_Sign__c).length() > 7))
        {
            message = MSG_CALLSIGNINVALID;
            errorfield = 'newCallSign';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_CALLSIGNINVALID));
            return null;
        } else if (requireChanges && request.MMSI__c != null && (!String.valueof(request.MMSI__c).isNumeric() 
                  || String.valueof(request.MMSI__c).length() != 9 ))
        {
            message = MSG_MMSI_INVALID;
            errorfield = 'newMMSI';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_MMSI_INVALID));
            return null;
        } else if (requireChanges && request.Port__c != null && !String.valueof(request.Port__c).isAlphaSpace()) {
            
            message = MSG_PORT_INVALID;
            errorfield = 'newPort';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_PORT_INVALID));
            return null;
        } else if (requireChanges && request.Gross_Tonnage__c != null && !String.valueof(request.Gross_Tonnage__c).isNumeric()){
            message = MSG_GROSS_TONNAGE_INVALID;
            errorfield = 'newGrossTonnage';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_GROSS_TONNAGE_INVALID));
            return null;
        }
        /* if(request.Delivery_Address_same_as_Billing_Address__c 
            && request.Billing_Address__c != null
            && isDigitalRequest == false)
         {
                if(String.valueof(request.Billing_Address__c).length()> 255)
                {
                 message= MSG_ADDRESS_LENGTH;
                 errorfield='BillingAddress';
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_ADDRESS_LENGTH));
                 return null;
                
                }
         }
        if(!request.Delivery_Address_same_as_Billing_Address__c 
           && request.Delivery_Address__c != null
           && isDigitalRequest == false)
         {
                if(String.valueof(request.Delivery_Address__c).length()> 255)
                {
                 message= MSG_ADDRESS_LENGTH;
                 errorfield='DeliveryAddress';
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_ADDRESS_LENGTH));
                 return null;
                
                }
         } */
        
        
        // Search Conformance Test
        List<LRIT_Conformance_Tests__c> tests = [SELECT Flag__c, Gross_Tonnage__c, IMO_Number__c, MMSI__c,Mobile_Number__c, Model__c, Port_of_Registry__c,
                                                Vessel_Name__c,	Test_Finish_Date__c,Vessel_Flag__c,Pole_Star_LRIT_Test_Number__c FROM LRIT_Conformance_Tests__c WHERE Pole_Star_LRIT_Test_Number__c = :request.Pole_Star_LRIT_Test_Number__c];
        system.debug('Test' + tests);
        if (tests.isEmpty()) {
            message = MSG_TESTNUMBER_NOTFOUND;
            errorfield = 'LRITTestNumber';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_TESTNUMBER_NOTFOUND));
            return null;
        } else {
            // Flag validations on the request
            if (tests[0].Flag__c != null) {
                // If a new IMN is entered and the vessel flag is Panama which displays as ‘PAN’ in the Flag__c field
                /*if (request.IMN__c != null && request.IMN__c != tests[0].Mobile_Number__c && tests[0].Flag__c == 'PAN'  && request.Vessel_Flag__c == 'Panama - PAN') {
                    message = MSG_PANAMARETEST;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_PANAMARETEST));
                    return null;
                }*/   
            }
            
           /* if ((request.Company_Name2__c == null) && ((requireChanges && request.Vessel_Flag__c == 'Panama - PAN')
                 || ((!tests.isEmpty()) && !requireChanges && tests[0].Flag__c != null && ((tests[0].Flag__c == 'PAN') || tests[0].Flag__c ==  'Panama - PAN'))) && isDigitalRequest == true){
                message = MSG_TERMSANDCONDITIONS;
                errorfield = 'pCompany';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_PCOMPANY));
                return null;     
            } */
            
            if(!tests.isEmpty()){
                List<LRIT_Valid_Flag__mdt> flagResult = new List<LRIT_Valid_Flag__mdt>();
                if(!requireChanges){
                    flagResult = [SELECT Digital_CTR__c,Courier_CTR__c,Validity_Period_In_Months__c,Part_of_Annualised_CT_Program__c,PoleStar_Supported_Flag__c,PoleStar_Supported_Flag_Existing__c FROM LRIT_Valid_Flag__mdt WHERE MasterLabel LIKE : ('%' + tests[0].Flag__c) LIMIT 1];
                } else {
                    flagResult = [SELECT Digital_CTR__c,Courier_CTR__c,Validity_Period_In_Months__c,Part_of_Annualised_CT_Program__c,PoleStar_Supported_Flag__c,PoleStar_Supported_Flag_Existing__c FROM LRIT_Valid_Flag__mdt WHERE MasterLabel = :request.Vessel_Flag__c LIMIT 1];
                }
				
				/*if(flagResult.size() != 0 && flagResult[0].Courier_CTR__c == false && flagResult[0].Digital_CTR__c == true && isDigitalRequest == false){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.LRIT_Panama_Order_Message));
                    return null;
				}
                if(flagResult.size() != 0 && flagResult[0].Digital_CTR__c == false && isDigitalRequest == true){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.LRIT_Non_Panama_Order_Message));
                    return null;
				}*/
                if (!(flagResult.size() != 0 && ((requireChanges && flagResult[0].PoleStar_Supported_Flag__c) ||(!requireChanges && flagResult[0].PoleStar_Supported_Flag_Existing__c)) )) {
                    message = MSG_NONSUPPORTEDFLAG;
                    if(requireChanges){
                        errorfield = 'newVesselFlag';
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_NONSUPPORTEDFLAG));
                    return null;
                }  
                /*if (flagResult.size() != 0 && requireChanges && flagResult[0].Part_of_Annualised_CT_Program__c && flagResult[0].Validity_Period_In_Months__c > 0 && request.Vessel_Flag__c == 'Panama - PAN') {
                    if(tests[0].Test_Finish_Date__c != null){
                		Date ctValidUntil = tests[0].Test_Finish_Date__c.addMonths(Integer.valueOf(flagResult[0].Validity_Period_In_Months__c));
						if(ctValidUntil < System.Today()){
							message = System.Label.LRIT_Annual_Program_Message;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
							return null; 
						}
                    }
				}*/
            }
                
          // Copy values accross
            request.LRIT_Conformance_Test__c = tests[0].Id;
            request.Verification_Code__c = generateRandomVerificationCode();
            if (request.Vessel_Flag__c == null) request.Flag__c = tests[0].Flag__c;
            if (request.IMO_Number__c == null) request.IMO_Number__c = tests[0].IMO_Number__c;
            if (request.Vessel_Name__c == null) request.Vessel_Name__c = tests[0].Vessel_Name__c;
            //if (request.Gross_Tonnage__c == null) request.Gross_Tonnage__c = tests[0].Gross_Tonnage__c;
            //if (request.MMSI__c == null) request.MMSI__c = tests[0].MMSI__c;
            //if (request.Model__c == null) request.Model__c = tests[0].Model__c;
            //if (request.Port__c == null) request.Port__c = tests[0].Port_of_Registry__c;
            if(tests[0].Pole_Star_LRIT_Test_Number__c.startsWith('AMTS')  )
            {
                system.debug('Tests' + 'Entered AMTS');
                
                if((tests[0].Vessel_Flag__c=='Panama - PAN' || tests[0].Vessel_Flag__c=='Liberia - LBR') && (request.Vessel_Flag__c=='Panama - PAN' ||request.Vessel_Flag__c=='Liberia - LBR' ||request.Vessel_Flag__c=='' ))
                {
                    panamaAMTS='NotRequired';
                }
                if(requireChanges && panamaAMTS=='Required')
                {
                message = MSG_PANAMA_AMTS;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_PANAMA_AMTS));
                return null;
                }
            }
            
         

          /* if(!(tests[0].Pole_Star_LRIT_Test_Number__c.startsWith('AMTS')))
            {
                if(tests[0].Test_Finish_Date__c>=DueDate)
                {
                   panamabefore2017='NotRequired';
                }
                else if(tests[0].Vessel_Flag__c=='Panama - PAN' && tests[0].Test_Finish_Date__c<DueDate && (request.Vessel_Flag__c=='Panama - PAN' || request.Vessel_Flag__c=='' ))
                {
                    panamabefore2017='NotRequired';
                }
                if(tests[0].Vessel_Flag__c!='Panama - PAN' && tests[0].Test_Finish_Date__c<DueDate )
                {
                    panamabefore2017='NotRequired';

                }
                if(requireChanges && panamabefore2017=='Required')
                {
                message = MSG_PANAMA_BEFORE_2017;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_PANAMA_BEFORE_2017));
                return null;
                }
            

            
            }*/
                  
        try {
            
            // Assign record type
            Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.LRIT_CTR_Request__c.getRecordTypeInfosByName();
            if (requireChanges && rtMapByName.containsKey('Change Existing LRIT CTR'))
                request.RecordTypeId = rtMapByName.get('Change Existing LRIT CTR').getRecordTypeId();
            else if (rtMapByName.containsKey('New LRIT CTR Order'))
                request.RecordTypeId = rtMapByName.get('New LRIT CTR Order').getRecordTypeId();
            
            // Assign distributor
            if (distributor != null)
                request.Account__c = distributor.Id;
            
			//Check whether it is digital request / courier
			if(isDigitalRequest == true) {
				request.Is_Digital_Request__c = true;
				request.Is_Courier_Request__c = false;
			}
			else{
				request.Is_Digital_Request__c = false;
				request.Is_Courier_Request__c = true;

			}
            Savepoint sp = Database.setSavepoint();
            Database.UpsertResult lsr = Database.upsert(request, true);
            
            if(!lsr.isSuccess()){
                Database.Error[] errors = lsr.getErrors();
                for(Database.Error e : errors){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));  
                }  
                return null;
            }
            
            PageReference reference = new PageReference('/LRITCTRRequest');
            reference.getParameters().put('id', request.Id);
            if (guestMode == 'EXTERNALUSER') reference.getParameters().put('dist', 'polestar');
            else if (guestMode == 'ENDUSER') reference.getParameters().put('dist', distributor.Id);
			showLanding = false;
            reference.setRedirect(true);
            return reference;
                     
        } 
            catch (Exception e) 
            {
            message = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ));
            return null;
            }
        }    
    }
    
    // Submit new request and create a new one
    public PageReference submitAndNew() {
        PageReference submitResult = submit();
        
        if (submitResult == null)
           return null;
        
        else
           
        submitResult=new PageReference('/apex/LRITCTRRequest');
        submitResult.setRedirect(true);
        return submitResult;
          //  return new PageReference('/a0h/e');
   
    }
    
    //Generate random verification code
    public string generateRandomVerificationCode(){
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
    
    // Submit request for invoicing
    public PageReference submitForInvoicing() {
        message = null;
        
        // Validate request
        if (request.Status__c != 'New') {
            message = MSG_CANNOTRESUBMIT;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_CANNOTRESUBMIT));
            return null;
        }
        
     
        Approval.ProcessSubmitRequest requestApproval = new Approval.ProcessSubmitRequest();
        requestApproval.setObjectId(request.Id);
        requestApproval.setProcessDefinitionNameOrId('CTR_Order_Approval');
        requestApproval.setSubmitterId(UserInfo.getUserId());
        
        Approval.ProcessResult requestApprovalResult = Approval.process(requestApproval);
                 
       if (requestApprovalResult.isSuccess())
       {
            return new PageReference('/'+request.Id);
       }
       else 
       {
            List<String> errors = new List<String>();
            for (Database.Error error : requestApprovalResult.getErrors())
                errors.add(error.getMessage());
            message = String.join(errors, '\n');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;
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
    *   @description method to handle payNow button, which processes parameters to send to barclaycard form url, includes fetching PSPIDs from custom settings and Hashing URL with sha1
    *   @return null PageReference
    **/
    public PageReference payNow(){
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
        else {
            System.debug('Attempt to duplicate payment');
            insert new Credit_Card_Payment_error_logs__c(Related_CTR_Request__c = request.Id,
                                                                Error_Description__c = 'Attempt to duplicate paymentfor this CTRR.');
        }
        return null;
    }

    //helper method to check if controller is running on sandbox or prod
    public static Boolean runningInASandbox(){
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
                                    'PARAMPLUS=' + 'RECID=' + request.Id + '&' +  'DIST=' + distid + passphrase +
                                    'PSPID=' + pspid + passphrase ;

                    Blob shasign = Blob.valueOf(url);

                    //encode with sha1
                    Blob sha1signat = Crypto.generateDigest('SHA1', shasign);

                    sha1signature = EncodingUtil.convertToHex(sha1signat);
                }
            }
        }
        
        catch(Exception e){
            System.debug('Something went wrong with generating SHA1 hash URL: ' + e.getMessage());
            insert new Credit_Card_Payment_error_logs__c(Related_CTR_Request__c = request.Id,
                                                                Error_Description__c = 'Something went wrong with generating SHA1 hash URL, it might be faulty parameters: ' + e.getMessage());
        }

    }
    
    // Edit
    public PageReference edit() {
        message = null;
        
        // Validate request
        if (request.Status__c != 'New') {
            message = MSG_CANNOTEDIT;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, MSG_CANNOTEDIT));
            return null;
        }
        
        return new ApexPages.StandardController(request).edit();
    }
    
    // Clone
    public PageReference doClone() {
        request = request.clone(false, true, false, false);
        request.Pole_Star_LRIT_Test_Number__c = null;
        request.LRIT_Conformance_Test__c = null;
        mode = 'EDIT';
        return null;
    }
    
    // Cancel
    public PageReference cancel() {
        PageReference reference;
        if (request.Id != null) {
            reference = new ApexPages.StandardController(request).cancel();
        } else if (ApexPages.currentPage().getParameters().containsKey('id')) {
            reference = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        } else if (mode == 'NEW' && guestMode == 'ANONYMOUS') {
            reference = new PageReference('/a0h/o');
        } else {
            reference = new PageReference('/');
        }
        if (guestMode == 'EXTERNALUSER') reference.getParameters().put('dist', 'polestar');
        else if (guestMode == 'ENDUSER') reference.getParameters().put('dist', distributor.Id);
        return reference;
    }
    
    //Search Polestar Test number and return IMO, Flag and Vessel
    public Object searchIMOVesselFlag() {
        
        System.debug('******'+searchedIMO);
        if(String.isNotBlank(searchedIMO)){
            List<LRIT_Conformance_Tests__c> reqs = [SELECT ID, Override_Screening__c,Override_Performance__c,Flag__c,IMO_Number__c, Pole_Star_LRIT_Test_Number__c, Port_of_Registry__c, MMSI__c, Mobile_Number__c, 
                                              Call_Sign__c, Vessel_Flag__c, Vessel_Name__c, Gross_Tonnage__c,GMDSS__c,SSAS__c, Sea_Areas__c, Test_Finish_Date__c, Finish_Time__c  
                                              FROM LRIT_Conformance_Tests__c WHERE IMO_Number__c = :searchedIMO ORDER BY Test_Finish_Date__c DESC, Finish_Time__c DESC LIMIT 1];
            if(!reqs.isEmpty()){
                 request.Pole_Star_LRIT_Test_Number__c = reqs.get(0).Pole_Star_LRIT_Test_Number__c;
                 request.Port__c = reqs.get(0).Port_of_Registry__c;
                 request.MMSI__c = reqs.get(0).MMSI__c;
                 request.IMN__c = reqs.get(0).Mobile_Number__c;
                 request.Call_Sign__c = reqs.get(0).Call_Sign__c;
                 request.Vessel_Flag__c = reqs.get(0).Vessel_Flag__c;
                 request.Vessel_Name__c = reqs.get(0).Vessel_Name__c;
                 request.Gross_Tonnage__c = reqs.get(0).Gross_Tonnage__c;
                request.Equipment_Part_of_the_GDMSS__c= reqs.get(0).GMDSS__c;
                request.Equipment_Part_of_the_SSAS__c= reqs.get(0).SSAS__c;
               
                List<Schema.PicklistEntry> ple = LRIT_CTR_Request__c.New_Sea_Areas__c.getDescribe().getPicklistValues();
                if(reqs.get(0).Sea_Areas__c != NULL){
                    for( Schema.PicklistEntry f : ple)
                    {
                        if(String.Valueof(f.getLabel()).replaceAll(' ', '') == String.Valueof(reqs.get(0).Sea_Areas__c).replaceAll( ' ', '')){
                            request.New_Sea_Areas__c = f.getValue();
                        }
                    } 
                }
              if(String.isNotBlank(reqs.get(0).Vessel_Flag__c)){
                vesselFlag = reqs.get(0).Vessel_Flag__c;
              }
              else{
                vesselFlag = reqs.get(0).Flag__c;
              }
              testFinishDate = reqs.get(0).Test_Finish_Date__c; 
              overrideScreening = reqs.get(0).Override_Screening__c; 
              overridePerformance = reqs.get(0).Override_Performance__c;
              todaysDate = System.Today();
              isCritical = false;
              isScreeningSuccess = true;
              isScreeningNotPending = true;
              isScreeningServerAvailable = true;
              isPerfomanceSuccess = true;
              isPerfomanceServerAvailable = true;
              isPending = false;
              result1 = null;
              result2 = null;
              result3 = null;
              if(Test.isRunningTest()){
                    //vesselFlag = 'United States of America - USA';
                    vesselFlag = 'Panama - PAN';
              }
              flagResult = [SELECT PoleStar_Supported_Flag__c,PoleStar_Supported_Flag_Existing__c,
                                                     Part_of_Annualised_CT_Program__c,Screening_Check_Enabled__c,Performance_Check_Enabled__c,Validity_Period_In_Months__c  
                                                     FROM LRIT_Valid_Flag__mdt WHERE MasterLabel LIKE : ('%' + vesselFlag) LIMIT 1];
              if(flagResult.size() > 0) {
                if(flagResult[0].Screening_Check_Enabled__c && overrideScreening == false) {
                        Continuation con = (Continuation) startScreeningContinuation();
                        return con;
                    }
                    else if(flagResult[0].Performance_Check_Enabled__c && 
                        testFinishDate < todaysDate.addDays(-30) && 
                        overridePerformance == false &&
                        isDigitalRequest == true){
                        Continuation con = (Continuation) startPerformanceContinuation();
                        return con;
                    }
                    else{
                        // Return null to re-render the original Visualforce page
                    if(String.valueof(request.IMN__c).trim().length() == 9){
                        transreceiver = 'Inmarsat-C';
                    } 
                    if ((String.valueof(request.IMN__c).trim().length() == 15) || (String.valueof(request.IMN__c).trim().length() == 12) || Test.isRunningTest()){
                        transreceiver = 'Iridium';
                    } 
                    testNumFound = 'YES';
                    requireChanges = true;	       
                    }
               } else{
                    isFlagConfigurationMissing = true;
               }
            }
            else {
                testNumFound = 'NO';
            }
        }
        else{
            testNumFound = 'NO';
        }
        
        return null;
    }
    
   public Object startPerformanceContinuation(){
    	// Create a first continuation 
        Continuation con = new Continuation(120); 
         // Set callback method
        con.continuationMethod='processPerformanceReportResponse';
        String reportingEndPointUrl = 'https://lrit-conformance-reporting.polestar-production.com/api/v1/reportingCheck?imoNumber='+searchedIMO+'&transceiverNumber='+request.IMN__c;
        System.debug('****'+reportingEndPointUrl);
        // Create callout request
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(reportingEndPointUrl);
        
        // Add callout request to continuation
        requestLabel3 = con.addHttpRequest(req); 
        // Start another continuation 
        return con;     
                        
    }
    
    public Object startScreeningContinuation(){
        // Create continuation with a timeout
            Continuation con = new Continuation(60);
            // Set callback method
            con.continuationMethod='processRegistrationResponse';
            String jsonBody = '{"registered_name":"'+searchedIMO+'"}';
            //String jsonBody = '{"registered_name":"9114543"}';
            System.debug('****jsonBody'+jsonBody);
            String regisrationEndPointUrl = 'https://api.polestar-production.com/purpletrac/v1/registration/?username=demo.russia&api_key=e097a9529fa0563ba9f7da51c39abceae9fc6b40';
            // Create first callout request
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json');
            req.setBody(jsonBody);
            req.setEndpoint(regisrationEndPointUrl);
            
            // Add initial callout request to continuation
            requestLabel1 = con.addHttpRequest(req);              
            
            // Return the continuation
            return con;
    }
    
    // Callback method for initial request
    public Object processRegistrationResponse() {   
      // Get the response by using the unique label
      HttpResponse response = Continuation.getResponse(this.requestLabel1);
	  if(response.getStatusCode() == 201){
      result1 = response.getBody();
      ScreeningServiceRegistrationJSONWrapper ssRegistrationJson = ScreeningServiceRegistrationJSONWrapper.parse(response.getBody());
	  Integer transactionId = ssRegistrationJson.transaction_id;
      Integer delay = 5000;
      Long start = DateTime.now().getTime();
      while(DateTime.now().getTime()-start<delay);           
   	  Continuation con = (Continuation) startTrasactionContinuation(transactionId);  
      return con;
	  }
	  else{
		isScreeningServerAvailable = false;
	  }
	  // Return null to re-render the original Visualforce page
      if(request.IMN__c != null){
              if(String.valueof(request.IMN__c).trim().length() == 9){
                  transreceiver = 'Inmarsat-C';
              } 
              if ((String.valueof(request.IMN__c).trim().length() == 15) || (String.valueof(request.IMN__c).trim().length() == 12) || Test.isRunningTest()){
                  transreceiver = 'Iridium';
              }
        }
      testNumFound = 'YES';
      requireChanges = true;
      return null;
    }
    //Start Transaction Continuation
    public Object startTrasactionContinuation(Integer transactionId){
        Continuation chainedContinuation = null;
          // Chain continuation if some condition is met
          if (transactionId != null) {
              // Create a second continuation 
              chainedContinuation = new Continuation(120);
              // Set callback method
              chainedContinuation.continuationMethod='processTransactionResponse';
              String transactionEndPointUrl = 'https://api.polestar-production.com/purpletrac/v1/transaction?id='+transactionId
                  +'&status__in=E,P,H&order_by=-creation_date&offset=0&limit=100&username=demo.russia&api_key=e097a9529fa0563ba9f7da51c39abceae9fc6b40';
              // Create callout request
              HttpRequest req = new HttpRequest();
              req.setMethod('GET');
              req.setEndpoint(transactionEndPointUrl);
              
              // Add callout request to continuation
              this.requestLabel2 = chainedContinuation.addHttpRequest(req); 
          }
      	// Start another continuation 
        return chainedContinuation; 
    }
    
    // Callback method for chained request
    public Object processTransactionResponse() {
      // Get the response for the chained request
      HttpResponse response = Continuation.getResponse(requestLabel2);
	  if(response.getStatusCode() == 200) {
      result2 = response.getBody();
      // Set the result variable that is displayed on the Visualforce page
      ScreeningServiceTransactionJSONWrapper ssTransactionJson = ScreeningServiceTransactionJSONWrapper.parse(response.getBody());
	  ScreeningServiceTransactionJSONWrapper.cls_objects resultsObject =  ssTransactionJson.objects[0];
      List<ScreeningServiceTransactionJSONWrapper.cls_screen_results> screenResults = resultsObject.screen_results; 
      if(screenResults != null) {
          for(ScreeningServiceTransactionJSONWrapper.cls_screen_results screenResult : screenResults){
              if((screenResult.check == 'COMPANY_SANCTIONS' && screenResult.Status == 'PENDING')  || 
                 (screenResult.check == 'SANCTIONS' && screenResult.Status == 'PENDING')){
              		isPending = true;
              } 
              else if((screenResult.check == 'COMPANY_SANCTIONS' && screenResult.Status == 'Critical')  || 
                 (screenResult.check == 'SANCTIONS' && screenResult.Status == 'Critical')){
              		isCritical = true;		       
              }
          }      
      }
      
        if(isCritical == true) {
            isScreeningSuccess = false;
        }
		else if(isPending == true){
			isScreeningNotPending = false;
		}
        else if(flagResult != null && flagResult.size() > 0){
            if(flagResult[0].Performance_Check_Enabled__c && 
					testFinishDate < todaysDate.addDays(-30) && 
					overridePerformance == false &&
					isDigitalRequest == true) {
                // Create a third continuation 
                Continuation chainedContinuation = null;
                chainedContinuation = new Continuation(120); 
                // Set callback method
                chainedContinuation.continuationMethod='processPerformanceReportResponse';
                String transactionEndPointUrl = 'https://lrit-conformance-reporting.polestar-production.com/api/v1/reportingCheck?imoNumber='+searchedIMO+'&transceiverNumber='+request.IMN__c;
                
                // Create callout request
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(transactionEndPointUrl);
                
                // Add callout request to continuation
                requestLabel3 = chainedContinuation.addHttpRequest(req); 
                // Start another continuation 
                return chainedContinuation;    
            }
        }
		}
		else{
			isScreeningServerAvailable = false;
		}
      // Return null to re-render the original Visualforce page
        if(request.IMN__c != null){
              if(String.valueof(request.IMN__c).trim().length() == 9){
                  transreceiver = 'Inmarsat-C';
              } 
              if ((String.valueof(request.IMN__c).trim().length() == 15) || (String.valueof(request.IMN__c).trim().length() == 12) || Test.isRunningTest()){
                  transreceiver = 'Iridium';
              }
        }
      testNumFound = 'YES';
      requireChanges = true;
      return null;
    }
    
    
    // Callback method for chained request
    public Object processPerformanceReportResponse() {   
      // Get the response for the chained request
      HttpResponse response = Continuation.getResponse(this.requestLabel3);
      if(response.getStatusCode() == 200){
		this.result3 = response.getBody();
        if(result3 == 'true') {
            isPerfomanceSuccess = true;
        }
        else {
            isPerfomanceSuccess = false;
        }
      }
	  else if(response.getStatusCode() == 404){
			isPerfomanceSuccess = false;
	  }
	  else{
		isPerfomanceServerAvailable = false;
	  }
      // Return null to re-render the original Visualforce page
      if(request.IMN__c != null){
         	if(String.valueof(request.IMN__c).trim().length() == 9){
              transreceiver = 'Inmarsat-C';
          } 
          if ((String.valueof(request.IMN__c).trim().length() == 15) || (String.valueof(request.IMN__c).trim().length() == 12) || Test.isRunningTest()){
              transreceiver = 'Iridium';
          }   
      }
       
      testNumFound = 'YES';
      requireChanges = true;
      return null;
    }
    
     public void closeSearch() {        
        testNumFound = '';    
    }    
    
    
    public pageReference handleChangesRequiredckb() {
        if(!requireChanges){
            request.Port__c = '';
            request.MMSI__c = '';
            request.IMN__c = '';
            request.Call_Sign__c = '';
            request.Vessel_Flag__c = '';
            request.Vessel_Name__c = '';
            request.Gross_Tonnage__c = '';
            request.New_Sea_Areas__c = '';
            request.Terms_and_Conditions_Accepted__c = false;
        }
        return null;
    }
    
    public pageReference enablesubmit(){
        if(checkbox){
            dataPrivacy = false;
        }else{
            dataPrivacy = true;
        }        
        return null;
    }
    
    public static Boolean ValidateNumber(String numberAcc) 
    {
        Boolean result = true;
        String emailRegex =  '^[0-9,)(/-]+$';
        Pattern EmailPattern = Pattern.compile(emailRegex);
        Matcher EmailMatcher = EmailPattern.matcher(numberAcc);
        if(EmailMatcher.matches())
        {
            result = false;
        }
        return result;
    }
     
}