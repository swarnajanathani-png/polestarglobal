public class SendEmailWithAttachment {
    public static List<Id> contentVersionIdsList=new List<Id>();
    @InvocableMethod
    public static void sendMailWithAttachment(List<String> recordIds) {
        try{
        String emailTemplateName = ''; 
        String orgWideEmailAddress= System.Label.LRITSendEmailOrgWideEmails;
        String[] ccEmails;
        String titleStartsWith = System.Label.LRITSendEmailAttachmentTitleKey;
        String whatId = recordIds[0];
        String dummyToEmail = 'test@test.com';
        String dummyCCEmail = 'test@test.com';
        String[] toEmails;
        String[] bccEmails = UserInfo.getUserEmail().split(',');
        LRIT_CTR_Request__c ctrRequest = new LRIT_CTR_Request__c();
        if(!Test.isRunningTest()){
        	ctrRequest = [Select Id,Delivery_Email_Address__c,Digital_CTR_Copy_Emails__c,Vessel_Flag__c FROM LRIT_CTR_Request__c WHERE Id=:whatId];
        	toEmails = ctrRequest.Delivery_Email_Address__c.split(','); 
            ccEmails = ctrRequest.Digital_CTR_Copy_Emails__c.split(',');
        }
        else{
        	toEmails = dummyToEmail.split(',');	
            ccEmails = dummyCCEmail.split(',');	
        }
        if(ctrRequest.Vessel_Flag__c == 'Panama - PAN') {
        	emailTemplateName = System.Label.LRITSendEmailTemplateName; 	        
        }
        else{
        	emailTemplateName = System.Label.LRITSendEmailTemplateNameNonPanama;        
        }
                
        //String whatId='a0h0C000002J0ScQAK'; 
        
        List<EmailTemplate> emailTemplates = getEmailTemplate(emailTemplateName);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(emailTemplates.size() > 0){
            message = Messaging.renderStoredEmailTemplate(emailTemplates[0].Id, NULL, whatId);
            message.setTreatTargetObjectAsRecipient(true);
            if(String.isNotBlank(orgWideEmailAddress)){
                // Query from Organization-Wide Email Address       
        		List<OrgWideEmailAddress> owdEmail =[select Id from OrgWideEmailAddress WHERE Address=:orgWideEmailAddress];
        		message.setOrgWideEmailAddressId(owdEmail[0].Id);    
            }
            message.toAddresses = toEmails;
            message.ccAddresses = ccEmails;
            message.bccaddresses = bccEmails;
            List<Messaging.EmailFileAttachment> emailFileAttList = getContentVers(whatId,titleStartsWith);
            if(emailFileAttList.size() > 0) {
                 message.setFileAttachments(emailFileAttList); 
                 message.setEntityAttachments(contentVersionIdsList);
            }
            message.setTemplateId(emailTemplates[0].Id); 
            message.setWhatId(whatId);
            message.setSaveAsActivity(true);
            message.setUseSignature(false);
            message.setBccSender(false); 
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
            if (results[0].success) {
                System.debug('The email was sent successfully.'); 
                ctrRequest.Status__c = 'Completed';
                update ctrRequest; 
            } 
            else {
                System.debug('The email failed to send: ' + results[0].errors[0].message); 
                Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = 'Error Occurred in SendEmailWithAttachment: '+results[0].errors[0].message; 
                insert log;
            } 
            //return message;
        }
        }Catch(Exception e){
        	Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = 'Error Occurred in SendEmailWithAttachment: '+e.getMessage(); 
            insert log;
        }
        //return null;
    }
   
    public static List<Messaging.EmailFileAttachment> getContentVers(Id objId, String titleStartsWith) {  
        List<Messaging.EmailFileAttachment> emailAttachList = new List<Messaging.EmailFileAttachment>();
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: objId];
        List <Id> CDIdList = new List <Id> ();
        
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId); 
        }
        String titleSearchStr = titleStartsWith+'%';
        List<ContentDocument> entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE ContentDocument.Id IN :CDIdList AND Title Like: titleSearchStr];
        if(entries.size() > 0) {
            List<ContentVersion> cvList = [SELECT Id, title, VersionData, FileExtension, ContentDocumentId 
                                           FROM ContentVersion 
                                           WHERE ContentDocumentId IN:entries 
                                           And isLatest = true];
            for(ContentVersion cvObj : cvList) {
                contentVersionIdsList.add(cvObj.Id);
                emailAttachList.add(setEmailFileAtt(cvObj));            
            }
            return emailAttachList;
        }
        return emailAttachList;
    }
    
    public static Messaging.EmailFileAttachment setEmailFileAtt(ContentVersion cvObj) {
        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
        Blob fileData = cvObj.VersionData;
        emlAtt.setFilename(cvObj.Title +'.'+ cvObj.FileExtension);
        emlAtt.setBody(fileData);
        return emlAtt;
    }
    public static List<EmailTemplate> getEmailTemplate(String emailTemplateName){
    	List<EmailTemplate> emailTemplates =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =:emailTemplateName];
        return emailTemplates; 
    } 
}