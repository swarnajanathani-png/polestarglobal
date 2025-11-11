@IsTest
public class SendEmailWithAttachmentTest {
	static testMethod void testLRITCTRRequest() 
    {
        Account distributor = new Account(
            Name = 'Distributor',
            Account_Status__c  = 'Commercial',
            Lead_Source__c  = 'Event',
            BillingStreet = '123 Fake Street',
            BillingCountry = 'United Kingdom',
            ShowOnPortal__c = true
        );
        insert distributor;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'SIGNED-TEST',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = distributor.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        List<String> recordIds = new List<String>();
        recordIds.add(distributor.id);
        SendEmailWithAttachment.sendMailWithAttachment(recordIds);
    }
}