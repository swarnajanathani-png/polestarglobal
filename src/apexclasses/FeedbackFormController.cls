public class FeedbackFormController 
{

 public String serviceteamVal{set;get;}
 public String PoleStarVal{set;get;}
 public String AccountManagVal{set;get;}
 public String RecPolstarVal{set;get;}
 public String ProductSatisfactionVal{set;get;}
 public String RecLikelyVal{set;get;}
 public Feedback__c feebackObj{set;get;}
 
 public FeedbackFormController()
 {
 	feebackObj = new Feedback__c(); 
 }
 
 public pagereference saveFeedbackRec()
 {
 	system.debug('====hiiiiii======'+feebackObj);
 	
 	if(serviceteamVal != null)
 	  feebackObj.Customer_Service_Score__c = serviceteamVal;
 	  
 	if(AccountManagVal != null)
 	    feebackObj.Account_Review_Requested__c = AccountManagVal; 	
 	
 	if(PoleStarVal != null)
 	   feebackObj.Overall_Experience_Score__c = PoleStarVal;

 	if(RecPolstarVal != null)
 		feebackObj.Recommend_Pole_Star__c = RecPolstarVal;

 	if(ProductSatisfactionVal != null)
 		feebackObj.Product_Satisfaction__c = ProductSatisfactionVal;

 	if(RecLikelyVal != null)
 		feebackObj.Net_Promoter_Score__c = RecLikelyVal;
 	
 	insert feebackObj;
 	feebackObj = new Feedback__c();
 	serviceteamVal = null;
 	AccountManagVal = null;
 	PoleStarVal = null;
 	RecPolstarVal = null;
 	ProductSatisfactionVal = null;
 	RecLikelyVal = null;
 	
 	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Thank you! Your feedback has been submitted successfully.');
    ApexPages.addMessage(myMsg);
            
 	return null;
 }
 
 public pagereference CancelRec()
 {
 	return null;
 }
 
}