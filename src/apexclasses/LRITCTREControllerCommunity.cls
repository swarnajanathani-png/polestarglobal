public class LRITCTREControllerCommunity {
    
    public LRIT_CTR_Request__c LRITObj{set;get;} 
    public Boolean chekedVal{set;get;}
    public Boolean chekedVal2{set;get;}
    public string tempval{set;get;}
    public string tempIdToredirect{set;get;}
    
    public LRITCTREControllerCommunity(ApexPages.StandardController controller) {
        LRITObj = new LRIT_CTR_Request__c();
        //LRITObj.CTR_Chnages_required__c = true;
        tempIdToredirect  = '';
        tempval = 'test';
    }
  
  /*  public LRITCTREControllerCommunity(){
    	chekedVal = false;
         chekedVal2 = false;
        
        system.debug('chekedVal2+++++++>'+chekedVal2);
    }*/
    
    public pagereference  saveLRITRecord() 
    {    
       system.debug('chekedVal2***** >'+chekedVal2);
    	
       LRITObj.Terms_and_Conditions_Accepted__c = chekedVal; 
       LRITObj.CTR_Chnages_required__c = chekedVal2;
       
       string MessageStr = 'Please enter data in the below required field.';
        
    /*   if(chekedVal2 && (LRITObj.Port__c == null || LRITObj.Port__c ==''))
          MessageStr += '&nbsp;&nbsp;<br/> * New port.';
        else if(chekedVal2 && (LRITObj.MMSI__c == null || LRITObj.MMSI__c ==''))
          messageStr += '&nbsp;&nbsp;<br/> * New MMSI.';          
       else if(chekedVal2 && (LRITObj.IMN__c == null || LRITObj.IMN__c ==''))
          messageStr += '&nbsp;&nbsp;<br/> * New IMN.';         
       else if(chekedVal2 && (LRITObj.Call_Sign__c == null || LRITObj.Call_Sign__c ==''))
          messageStr += '&nbsp;&nbsp;<br/> * New call sign.';   */       
       if(LRITObj.Pole_Star_LRIT_Test_Number__c == null || LRITObj.Pole_Star_LRIT_Test_Number__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Pole Star test number.';          
       else if(LRITObj.Vessel_Flag__c == null || LRITObj.Vessel_Flag__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Vessel flag.';                    
       else if(LRITObj.Vessel_Name__c == null || LRITObj.Vessel_Name__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Vessel name.';          
       else if(LRITObj.IMO_Number__c == null || LRITObj.IMO_Number__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * IMO number.';
       else if(LRITObj.Equipment_Part_of_the_GDMSS__c == null || LRITObj.Equipment_Part_of_the_GDMSS__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Equipment Part of the GDMSS?.';          
       else if(LRITObj.Equipment_Part_of_the_SSAS__c == null || LRITObj.Equipment_Part_of_the_SSAS__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Equipment part of the SSAS? .';          
       else if(LRITObj.Currency__c == null || LRITObj.Currency__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Currency.';
        else if(LRITObj.Company_Name2__c == null || LRITObj.Company_Name2__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Company name.';
         else if(LRITObj.Billing_Address__c == null || LRITObj.Billing_Address__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Billing Address.';
       else if(LRITObj.Delivery_Contact_Name__c == null || LRITObj.Delivery_Contact_Name__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Delivery contact name.';          
       else if(LRITObj.Delivery_Email_Address__c == null || LRITObj.Delivery_Email_Address__c =='')
          messageStr += '&nbsp;&nbsp;<br/> * Email address.';          
       else if(LRITObj.Delivery_phone_Number__c == null || LRITObj.Delivery_phone_Number__c =='')       
          messageStr += '&nbsp;&nbsp;<br/> * Contact telephone number.';          
       else if(LRITObj.Delivery_Option__c == null || LRITObj.Delivery_Option__c == '') 
         messageStr += '&nbsp;&nbsp;<br/> * Delivery option.';         
       else if(LRITObj.Terms_and_Conditions_Accepted__c == false && chekedVal2)
         messageStr += '&nbsp;&nbsp;<br/> * Accept Terms and Conditions.';
       else 
         messageStr = '';
         
       system.debug('==messageStr===>>'+messageStr);
       
       if(messageStr != '')
        {	 
	    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,messageStr);
	        ApexPages.addMessage(myMsg);
	        messageStr = '';
	        return null;
        }
         	
    	system.debug('c111 ===>'+chekedVal);
    	system.debug('c2222 ===>'+chekedVal2);
        
        List<RecordType> lstRecTypes = [select id,Name from recordType where name = 'Non-Customer LRIT CTR Request' and SObjectType = 'LRIT_CTR_Request__c' limit 1];
        if(lstRecTypes != null && !lstRecTypes.isEmpty())
            LRITObj.recordTypeId = lstRecTypes[0].id;
            
        insert LRITObj;
        tempval ='not test';
        tempIdToredirect = LRITObj.id;
        return null;//new pagereference('/apex/LRITCTRViewpageCommunity?id='+LRITObj.id);
    }
    
    public void Rendering(){
    	system.debug('chekedVal111111111 ===>'+chekedVal);
    	system.debug('chekedVal22222222 ===>'+chekedVal2);
    	system.debug('LRITObj&&CTR_Chnages_required__c&## ===>'+LRITObj.CTR_Chnages_required__c);
    	system.debug('LRITObj&&&## ===>'+LRITObj);
    }
    
    public pagereference saveAndNewLRITRecord() {
    	saveLRITRecord();
    	if( tempval =='not test')
           LRITObj = new LRIT_CTR_Request__c();
        return null;//new pagereference('/apex/LRITCTREditpageCommunity');
    }

   public pagereference cancelIt() {
        return null;
   }
}