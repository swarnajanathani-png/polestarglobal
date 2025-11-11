/**
* @who Tiago Lopes - CloudSocius
* @when 03/01/17
* @what class used to log Error record on LRIT CTR Request each time an Attachment fails to upload to S3
*/
public with sharing class ErrorLog {

	public Id parentId;
	public Id attachId;
	public Attachment attach;

	public ErrorLog() {
		
	}

	/**
	* Constructor with Attachment Id and XML body with error
	*/
	public ErrorLog(Id attachId, String errorMsg){

		if(attachId != null){
			this.attachId = attachId;
			getParent();
			parentId = getParentId();
			if(parentId != null){
				insertErrorLog(errormsg);

			}
		}

	}

	/**
	* @Description method attempts to insert Error record
	* @param       errorMsg with XML body - Reason
	*/
	public void insertErrorLog(String errorMsg){

		LRIT_CTR_Request_S3upload_Error__c error = new LRIT_CTR_Request_S3upload_Error__c();
		error.Name = attach.Name + ' failed to upload';
		error.LRIT_CTR_Request__c = attach.ParentId;
		String err = errorMsg;
		if(!Test.isRunningTest()){
			System.debug('####' + err.split('soapenv:Reason',2)[1]);
			error.Error_message__c = err.split('soapenv:Reason',2)[1];
		}
		else{
			error.Error_message__c = errorMsg;
		}
		try{
			insert error;
			System.debug('Error log inserted!');
		}
		catch(DmlException e){
			System.debug(e.getMessage());
		}
	}


	/**
	* @Description getter method to get LRIT CTR Request to insert the error record on
	*/
	 public Attachment getParent(){

	 	List<Attachment> plist = new List<Attachment>();

		if(attachId != null){
			plist = [SELECT Id, ParentId, Name FROM Attachment WHERE Id = :attachId LIMIT 1];
			if(!plist.isEmpty()){
				attach = plist.get(0);
			}
			return attach;
		}
		return null;
	}

	
	public Id getParentId(){
		return this.attach.Id;
	}
}