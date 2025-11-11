/**
* @description: InboundEmailHandler, sets fields on case after inbound email is process by emails-case functionality
*
* Change Log 
*
* Date        Author          Change Description
* -----------------------------------------------------------------------------
* 13/11/2014  Graeme Cameron  Created Class   
*/

public class InboundEmailHandler{
    
     public static void InboundEmailHandler(List <Case> newCases, List<String> emailAddresses, Map<Id,String> caseEmailMap, Map<Id,String> caseEmailStatusMap){
        
        List<Contact> contacts = new List<Contact>([SELECT Id, Email, AccountId FROM Contact WHERE Email in: emailAddresses]);
        System.debug('contacts: ' + contacts);
        Map<String,Id> emailContactMap = new Map<String,Id>();
        Map<String,Id> emailAccountMap = new Map<String,Id>();
        List<Case> CasestoUpdate = new List<Case>();
        
        For(Contact c : contacts){
            
            emailContactMap.put(c.Email, c.Id);
            emailAccountMap.put(c.Email, c.AccountId);
            System.debug('emailContactMap: ' + emailContactMap);
            System.debug('emailAccountMap: ' + emailAccountMap);
            
        }
        
        for(Case c : newCases){
            
            System.debug('In contact assignment loop: ');
            String emailAddress = caseEmailMap.get(c.Id);
            String emailStatus = caseEmailStatusMap.get(c.Id);
            System.debug('emailAddress: ' + emailAddress);
            System.debug('emailStatus: ' + emailStatus);
            
            if(c.ContactId == null){
               //  c.ContactId = emailContactMap.get(emailAddress);
            }
            
            if(c.AccountId == null){
                 c.AccountId = emailAccountMap.get(emailAddress);
            }
            
            if(emailStatus == '0'){
            	c.Last_Email_Received_Date__c = system.now();
            }else{
            	c.Last_Email_Received_Date__c = null; 
            }
            
            System.debug('c.ContactId: ' + c.ContactId);
            System.debug('c.AccountId: ' + c.AccountId);
            
            CasestoUpdate.add(c);
            
        }
        
        update CasestoUpdate;
     }
}