/**
* @who Tiago Lopes - CloudSocius
* @when 04/01/17
* @what Handler class for Attachment Trigger
*/
public with sharing class AttachmentTriggerHandler {

	private static AttachmentTriggerHandler instance = null;

	private AttachmentTriggerHandler() {
		
	}

	public static AttachmentTriggerHandler getInstance(){
		if(instance == null){
			instance = new AttachmentTriggerHandler();
		}

		return instance;
	}

	public void uploadToAmazonS3(List<Attachment> attachs){

		Set<Id> parentObjectIds = new Set<Id>();
		List<LRIT_CTR_Request__c> reqs = new List<LRIT_CTR_Request__c>();

		for(Attachment a : attachs){
			if(a.ParentId != null){
				parentObjectIds.add(a.ParentId);
			}
		}
		System.debug('parentObjectIds ->' + parentObjectIds);

		reqs = [SELECT Id, Name, Pole_Star_LRIT_Test_Number__c, Certificate_Number__c FROM LRIT_CTR_Request__c WHERE Id IN :parentObjectIds ];
		System.debug('reqs ->' + reqs);

		for(Attachment a : attachs){
			for( LRIT_CTR_Request__c req : reqs){
				if(a.Name.contains(req.Pole_Star_LRIT_Test_Number__c) && a.Name.contains(req.Certificate_Number__c)){
					AwsConnectHelper.uploadToAmazonS3Soap(a.Id);
				}
			}
		}
	}

}