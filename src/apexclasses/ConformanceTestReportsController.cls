/**
 *  @who    Samuel Arroyo (CloudSocius)
 *  @what   Show list of Conformance Test Reports
 *  @when   05/07/2016
 */
public class ConformanceTestReportsController {

    public String profileName {get; set;}
    public String captchaResponse {get; set;}
    public Boolean captchaVerified {get; set;}
    public String imoNumber {get; set;}
    public String ctrNumber {get; set;}
    public Boolean searched {get; set;}
    public Boolean displayPopUp {get; set;}
    public String flagAdminEmail {get; set;}
    public String errorMessage {get;set;}
    public String successMessage{get;set;}
    public String popupHeader{get;set;}
    public String codeFromEmail {get;set;}
    public String revokeReason {get;set;}
    public String ctrStatus {get;set;}
    public Boolean hasError {get;set;}
    public Boolean showVerify {get;set;}
    public Boolean isCodeMatched {get;set;}
    public Boolean isRevokeOrCancelSuccess {get;set;}
    public String vesselFlag;
    public String ctrId;
    public String ctreportId;
    public String generatedCode;
    public List<ConformanceTestReport__c> reports {get; set;}
    
    public ConformanceTestReportsController() {
        profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        captchaVerified = profileName != 'LRITrequest Profile';
        captchaVerified = true;
        reports = new List<ConformanceTestReport__c>();
        searched = false;
        displayPopUp = false;
    }
    
    public void search() {
        reports = new List<ConformanceTestReport__c>();
        if (captchaVerified) {
            if (profileName != 'LRITrequest Profile' && ((imoNumber != null && imoNumber != '') || (ctrNumber != null && ctrNumber != ''))) {
                reports = [SELECT Id,CTRNumber__c, CTRStatus__c, IMONumber__c, Link__c, IssuedDate__c, Pole_Star_LRIT_Test_Number__c,
                           CTRRequestRecordNumber__r.Vessel_Flag__c, CTRRequestRecordNumber__c
                           FROM ConformanceTestReport__c WHERE IMONumber__c = :imoNumber OR CTRNumber__c = :ctrNumber 
                           ORDER BY IssuedDate__c DESC];
            } else if (imoNumber != null && ctrNumber != null) {
                reports = [SELECT Id,CTRNumber__c, CTRStatus__c, IMONumber__c, Link__c, IssuedDate__c,CTRRequestRecordNumber__c,CTRRequestRecordNumber__r.Vessel_Flag__c
                           FROM ConformanceTestReport__c WHERE IMONumber__c = :imoNumber AND CTRNumber__c = :ctrNumber 
                           ORDER BY IssuedDate__c DESC];
            }
            searched = true;
            if(!reports.isEmpty()) {
                vesselFlag = reports[0].CTRRequestRecordNumber__r.Vessel_Flag__c; 
                ctrId = reports[0].CTRRequestRecordNumber__c;
                ctreportId = reports[0].Id;
            }
        }
    }
    public void showVerificationPopup(){
        displayPopUp = true; 
        popupHeader = 'Verify Flag Admin';
        hasError = false;
        showVerify = false;
        successMessage = '';
        errorMessage = '';
        List<LRIT_Valid_Flag__mdt> flagResult = [SELECT Admin_Emails__c FROM LRIT_Valid_Flag__mdt WHERE MasterLabel = : vesselFlag LIMIT 1];
        if(!flagResult.isEmpty()) {
            if(String.isNotBlank(flagResult[0].Admin_Emails__c)){
                flagAdminEmail = flagResult[0].Admin_Emails__c; 
                sendOTP(flagAdminEmail);
            }
            else{
                hasError = true;
                errorMessage = 'Admin Email is not configured for this vessel. Please contact support team support@polestarglobal.com';
            }
        }
        else {
            hasError = true;
            errorMessage = 'This Vessel is not configured in Polestar. Please contact support team support@polestarglobal.com';
        }
        
    }
    
    public void closePopup(){
        displayPopUp = false;    
    }
    
    public void sendOTP(String adminEmail) {
        try {
            generatedCode = generateRandomVerificationCode();
            sendEmail(adminEmail,generatedCode);
            showVerify = true;
        } catch (Exception e) {
            hasError = true;
            errorMessage = 'Exception Occured while sending OTP to '+ adminEmail +'\n'; 
            errorMessage = errorMessage + 'Exception Message :'+ e.getMessage();
        }
    }
    
    public void verifyCode(){
        if(codeFromEmail == generatedCode){
        	showVerify = false;
            errorMessage = '';
        	successMessage = 'Code has been verified successfully';   
            isCodeMatched = true;
            popupHeader = 'Provide Revoke/Cancellation Details';
        }
        else {
        	showVerify = true;
        	errorMessage = 'Given code is not matching with emailed code please recheck it';  
            successMessage = '';
            isCodeMatched = false;
        }
    	
    }
    
    public void updateRevokeReason(){
        try{
            String statusToSet = '';
            if(ctrStatus == 'Cancel') {
            	statusToSet = 'Cancelled';   
            }
            else {
            	statusToSet = 'Revoked';    
            }
            LRIT_CTR_Request__c ctrrequest = new LRIT_CTR_Request__c();
            ctrrequest.Id = ctrId;
            ctrrequest.LRIT_CTR_Status__c = statusToSet;
            ctrrequest.Revoke_Cancellation_Reason__c = revokeReason;
            update ctrrequest;
            
            ConformanceTestReport__c ctreport = new ConformanceTestReport__c();
            ctreport.Id = ctreportId;
            ctreport.CTRStatus__c = statusToSet;
            ctreport.Revoke_Cancellation_Reason__c = revokeReason;
            update ctreport;
            
            isRevokeOrCancelSuccess = true;
            isCodeMatched = false;
            popupHeader = '';
        	successMessage = 'Your CTR has been successfully '+statusToSet+'. Thank you.';  
            errorMessage = '';
            search();
        }catch(Exception e){
        	isCodeMatched = true;
            errorMessage= e.getMessage();
            successMessage = '';
        }
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
    
    public void sendEmail(String adminEmail, String verificationCode) {
        try{
            String toEmails = adminEmail;
        	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.Subject = 'Revoke CTR Verification Code';
            message.toAddresses = toEmails.split(',');
            String messageBody = 'Verification Code : '+verificationCode;
            message.setPlainTextBody(messageBody); 
           // message.setWhatId(whatId);
            message.setSaveAsActivity(true);
            message.setUseSignature(false);
            message.setBccSender(false); 
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            if (results[0].success) {
                hasError = false;
                errorMessage = ''; 
            } 
            else {
                hasError = true;
                errorMessage = results[0].errors[0].message; 
            } 
            //return message;
        
        }Catch(Exception e){
        	hasError = true;
            errorMessage = e.getMessage(); 
        }
        //return null;
    }
   
    public void verifyCaptcha() {
        if (captchaResponse != null) {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
            //request.setBody('secret=6Lce5BMqAAAAACfjPi9E38EMA4FuSajDeBvlk0eZ&response='+ captchaResponse); //Sandbox
            request.setBody('secret=6LeA3n8lAAAAALpHfEyZ6ZSRBjnE_Z_OJh-ZI34S&response='+ captchaResponse); //Production
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