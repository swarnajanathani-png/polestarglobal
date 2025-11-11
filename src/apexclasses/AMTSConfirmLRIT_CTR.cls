public without sharing class AMTSConfirmLRIT_CTR {
    public String ObjectId {get;set;}
    public String ResponseCode {get;set;}
    public AMTSConfirmLRIT_CTR () {
        ObjectId = ApexPages.currentPage().getParameters().get('ObjectId');
        ResponseCode = ApexPages.currentPage().getParameters().get('ResponseCode');
    }
    public PageReference InitPage() {
        List<LRIT_Conformance_Tests__c> LRITCTRRequest = [SELECT Id FROM LRIT_Conformance_Tests__c WHERE Id=:ObjectId LIMIT 1];
        if(!LRITCTRRequest.IsEmpty()){
            LRITCTRRequest[0].Validation_Status__c = ResponseCode;
            UPDATE LRITCTRRequest;
               }
      return null;
    }
}