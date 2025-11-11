public class HardwareODPPaidInvoiceCallout {
    @InvocableMethod
    public static void httpCallOut(List<Opportunity> lstOpportunity){
        String pson = lstOpportunity[0].Service_PSON__c;
        try{
        	HttpRequest req = new HttpRequest();
            req.setEndpoint(System.Label.ODPHardwarePaidInvoiceWebhook+'&PSON='+pson);
            req.setMethod('GET');
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() != 200){
                /* Sending of email */
                List<String> contactEmailList = new List<String>{'swarnaja.nathani@polestarglobal.com'};
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = contactEmailList;
                message.htmlBody = res.getBody();
                message.subject = 'ProformaInvoice paid status is not updated in ODP';
        
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
                if (!results[0].success) {
                    Error_Log__c log = new Error_Log__c();
                	log.Error_Message__c = results[0].errors[0].message;
                	insert log; 
                } 
            }
            
        }Catch(Exception e){
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage()+pson;
            insert log;
        }
        
    }

}