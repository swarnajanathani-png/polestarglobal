/**
 * Updating Test status to paid in test engine when salesforce Opportunity stage is updated to closed won and payment option is invoice proforma
 **/
public class OpportunityClosedWonTestPaidClass {
    @InvocableMethod
	public static void setTestPaidStatus(List<Opportunity> lstOpportunity ){
        try{
            LRIT_API_Credential__mdt lritapicred = LRIT_API_Credential__mdt.getInstance('TestEngineTestPaidEndPoint');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(''+lritapicred.Registration_Endpoint_URL__c+'?pSON='+lstOpportunity[0].Service_PSON__c+'&paid=true');
            req.setMethod('PUT');
            req.setHeader('Content-Type','application/json'); 
            String username = lritapicred.Registration_Username__c;
            String password = lritapicred.Registration_Api_key__c;
        
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
        
            // Create a new http object to send the request object
            // A response object is generated as a result of the request  
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
            if(res.getStatusCode() != 200){
                Case c = new Case();
                c.subject = 'Test Engine API : Test Status Update to Paid Unsuccessful from Salesforce Automation';
                c.Description = 'We got below response from Test Engine API '+ res.getBody() + '\n';
                c.Description = c.Description + '1. Conformance Test has been paid for, SF opportunity set to closed/won.'+lstOpportunity[0].Service_PSON__c+'\n'
                    +'2. Conformance Test is at status of Not Paid as Test Engine API call was unsuccessful - so the Conformance Test is not visible in the Customers On Demand Portal Conformance Test Dashboard' + '\n'
                	+'3. Support team action - set Conformance Test to paid in the Test Engine directly to make it visible for the customer in their dashboard\n';
                c.Priority = 'High';
                c.OwnerId = System.Label.Triage_Queue_Id;
                insert c;
            }
            else{
            	Error_Log__c log = new Error_Log__c();
                log.Error_Message__c = lstOpportunity[0].Service_PSON__c+' Success:' + res.getBody();
                insert log;    
            }
        }
        Catch(Exception e){
            Case c = new Case();
            c.subject = 'Exception Occurred While Updating Test Payment Status to Paid from Salesforce' + lstOpportunity[0].Service_PSON__c;
            c.Description = 'Please inform salesforce team about this exception : '+ e.getMessage();
            c.Priority = 'High';
            c.OwnerId = System.Label.Triage_Queue_Id;
            insert c;
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = e.getMessage();
            insert log;
        }
    }
}