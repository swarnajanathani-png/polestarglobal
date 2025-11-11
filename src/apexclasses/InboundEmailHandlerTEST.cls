@isTest
/**
* @description: Test class for B2B_Case_Categorisation_Class,
* 
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 26/11/2014  Graeme Cameron  Created Class   
*/


global class InboundEmailHandlerTEST implements Messaging.InboundEmailHandler{
    
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                            Messaging.InboundEnvelope env)
    {
        List<Case> casesToBeCategorised  = new List<Case>();
        
        Messaging.InboundEmailResult result = new  Messaging.InboundEmailresult();
        
        Case newCase = new Case();
        newCase.Subject = null;
        newCase.Description = email.plainTextBody;
        newCase.SuppliedEmail = email.fromAddress;
        newCase.Origin = 'Email';
        newCase.Case_Type__c = 'Pole Star';
        
        insert newCase;
        
        Case newCase2 = new Case();
        newCase2.Subject = email.Subject;
        newCase2.Description = null;
        newCase2.SuppliedEmail = email.fromAddress;
        newCase2.Origin = 'Email';
        newCase.Case_Type__c = 'Pole Star';
        
        insert newCase2;
        
        System.debug(result);
        
        return result;
        
    }
    
    public static testMethod void myUnitTest() {
        
        
        
        List<String> addresses = new String[2];
        addresses[0] = 'support@polestarglobal.com';
        
        // Create a new email and envelope object to test blank description
       Messaging.InboundEmail email  = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      
       // Create the email body
       email.plainTextBody = 'test body';
       email.fromAddress ='test@test.com';
       email.subject = 'test subject';
       email.toAddresses = addresses;
    
       InboundEmailHandlerTEST edr = new InboundEmailHandlerTEST();
        
       Test.startTest();
       Messaging.InboundEmailResult result = edr.handleInboundEmail(email, env);
       Test.stopTest();
       
       Case newCase = new Case();
        newCase.Subject = null;
        newCase.Description = email.plainTextBody;
        newCase.SuppliedEmail = email.fromAddress;
        newCase.Origin = 'Email';
        
        insert newCase;
        
       EmailMessage testEmail = new EmailMessage();
       testEmail.FromAddress = 'test@test.com';
       testEmail.Subject = email.Subject;
       testEmail.ToAddress = 'support@polestarglobal.com';
       testEmail.Incoming = true;
       testEmail.ParentId = newCase.Id;
       
       insert testEmail;
       
       
       System.assert (result.success, 'InboundEmailResult returned a failure message');
        
            
    }
    
    
}