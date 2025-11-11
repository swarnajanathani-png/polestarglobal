public class AwsConnectHelper {


	@testVisible private static final String AWSCredentialName = 'salesforce';
	public static final String host = 's3-eu-west-1.amazonaws.com';
	public static S3.AmazonS3 as3;
	public static final String accessType = 'public-write';
	public static final String bucketname = 'lrit-ctr-salesforce';

/**
* @who Tiago Lopes - CloudSocius
* @when 03/01/17
* @what class used to invoke ad-hoc amazon webservices from S3 class
*/
	public AwsConnectHelper(){

	}

	//
	@Future(callout=true)
	public static void uploadToAmazonS3Soap(Id attachId){

		System.debug('attachId ->' + attachId);

		if(attachId != null){

			 
			AWSKeys awsc = new AWSKeys(AWSCredentialName);
			as3 = new S3.AmazonS3(awsc.key,awsc.secret);
			System.debug('AS3 ->' + as3);
			String OwnerId;

			try{

				Attachment attach = [SELECT Id, Name, Body, bodyLength, ContentType FROM Attachment WHERE Id =: attachId];

				System.debug('credentials ->' + awsc);

				Datetime now = Datetime.now();
          		String docBody = EncodingUtil.base64Encode(attach.body);
          		String filename = attach.Name;
          		Integer fileSize = attach.bodyLength;
          
		         System.debug('body length: ' + fileSize);
		         System.debug('docbody -> ' + docBody);

		         //This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account. skip is if testmethod
		         if(!Test.isRunningTest()){
		        	S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(as3.key,now,as3.signature('ListAllMyBuckets',now));
		        	//Store the Canonical User Id for your account
		        	OwnerId  = allBuckets.Owner.Id;
		        }
		        else{
		        	OwnerId = '3491e7f21666a92bc13c7848f01b5745ce6326fc15285a595ee2fcba34c6f1bf';
		        }
	        	System.debug('OwnerId ->' + OwnerId);

	        	//performing callout
		         Boolean putObjResult = as3.PutObjectInline_ACL(bucketname,filename,null,docBody,fileSize,accessType,awsc.key,now,as3.signature('PutObjectInline',now),awsc.secret, OwnerId );
		         if(putObjResult==true){
              		System.debug('putobjectinline successful - deleting object...');
              		deleteAttachment(attach);
              		
              	}
			}
			catch(Exception e){
				System.debug(e.getMessage());
				

			}
		}
	
	}

	public static void deleteAttachment(Attachment attach){

		if(attach != null){
			try{
				delete attach;
				System.debug('Attachment successfully deleted');
			}
			catch(DmlException e){
				System.debug('Attachment failed to be deleted - ' + e.getMessage() );
			}
		}

	}

	/*
	//
	@future(callout=true)
	public static void uploadToAmazonS3Rest(List<Id> attachIds){

		if(!attachIds.isEmpty()){

			AWSKey__c awsc = new AWSKey__c();

			try{

				Attachment attach = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id =: attachIds.get(0)];

				List<AWSKey__c> awscList = [SELECT Id, Name, Key__c, Secret__c FROM  AWSKey__c WHERE Name = :AWSCredentialName LIMIT 1];
				if(!awscList.isEmpty()){
					awsc = awscList.get(0);
				}

				System.debug('credentials ->' + awsc);

				String attachmentBody = EncodingUtil.base64Encode(attach.Body);
				String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
				String key = awsc.Key__c;
				String secret = awsc.Secret__c;
				String method = 'PUT';
				String filename = attach.Id + '-' + attach.Name;

				HttpRequest req = new HttpRequest();
				req.setMethod(method);
				req.setEndpoint('https://' + bucketname + '.' + host + '/' + filename);
				req.setHeader('Host', bucketname + '.' + host);
				req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
				req.setHeader('Content-Encoding', 'UTF-8');
				req.setHeader('Content-type', attach.ContentType);
				req.setHeader('Connection', 'keep-alive');
				req.setHeader('Date', formattedDateString);
				req.setHeader('ACL', 'public-read');
				req.setBody(attachmentBody);

				String stringToSign = 'PUT\n\n' +
				    attach.ContentType + '\n' +
				    formattedDateString + '\n' +
				    '/' + bucketname +  '/' + filename;

				String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
				Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
				String signed = EncodingUtil.base64Encode(mac);
				String authHeader = 'AWS' + ' ' + key + ':' + signed;
				req.setHeader('Authorization',authHeader);
				String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');

				System.debug(authHeader);
				System.debug('req -->:' + req);

				Http http = new Http();
				HTTPResponse res = http.send(req);
				System.debug('*Resp:' + String.ValueOF(res.getBody()));
				System.debug('RESPONSE STRING: ' + res.toString());
				System.debug('RESPONSE STATUS: ' + res.getStatus());
				System.debug('STATUS_CODE: ' + res.getStatusCode());
				
			}
			catch(Exception e){
				System.debug(e.getMessage());
			}
		}
	}
	*/

	

}