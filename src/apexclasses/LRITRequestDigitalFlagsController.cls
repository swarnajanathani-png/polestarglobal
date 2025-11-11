public class LRITRequestDigitalFlagsController {
    public List<String> digitalCTROptedFlags {get;set;}
    public List<String> digitalAndCourierCTROptedFlags {get;set;}
    public List<String> courierCTROptedFlags {get;set;}
    // Constructor
    public LRITRequestDigitalFlagsController(ApexPages.StandardController ctrl) { 
        List<LRIT_Valid_Flag__mdt> flagResult = [SELECT MasterLabel, Courier_CTR__c,Digital_CTR__c FROM LRIT_Valid_Flag__mdt 
                                                 WHERE PoleStar_Supported_Flag__c =: TRUE]; 
        if(flagResult.size() > 0){
            digitalCTROptedFlags = new List<String>();
            digitalAndCourierCTROptedFlags = new List<String>();
            courierCTROptedFlags = new List<String>();
            
            for(LRIT_Valid_Flag__mdt flag:flagResult){
                if(flag.Digital_CTR__c == TRUE && flag.Courier_CTR__c == FALSE) {
            		digitalCTROptedFlags.add(flag.MasterLabel); 
                }
                else if (flag.Digital_CTR__c == TRUE && flag.Courier_CTR__c == TRUE){
                	digitalAndCourierCTROptedFlags.add(flag.MasterLabel);    
                }
                else{
                	courierCTROptedFlags.add(flag.MasterLabel);    
                }
            }  
        }
    }

}