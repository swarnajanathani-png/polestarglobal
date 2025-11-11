public with sharing class ProductInfoLink {
  
    
        Public static void ProductInfoLink(List<Opportunity> opportunities){
              
            List<Id> accIDs = new list<Id>();
            List<Id> oppIDs = new list<Id>();
        
            for(Opportunity opp: opportunities){
                
                system.debug('opp = ' + opp);
                accIDs.add(opp.AccountId);
                oppIDs.add(opp.Id);
            
            }
            
            system.debug('accIDs = ' + accIDs);
            
            List<Product_Information__c> productInfos = [SELECT Id, Name, Record_Type_Name__c, Account__c FROM Product_Information__c WHERE Account__c in: accIDs];
            List<Opportunity_Product_Information__c> newOppProdInfos = new List <Opportunity_Product_Information__c>();
            List<Opportunity_Product_Information__c> deleteOppProdInfos = new List <Opportunity_Product_Information__c>();
            system.debug('productInfos = ' + productInfos);
            
            List<Opportunity_Product_Information__c> exisitingOppProdInfo = [SELECT Id, Name, Opportunity__c, Product_Information__c, Product_Information__r.Record_Type_Name__c FROM Opportunity_Product_Information__c WHERE Opportunity__r.Id in: oppIDs];
            system.debug('exisitingOppProdInfo = ' + exisitingOppProdInfo);
        
            for(Opportunity opp : opportunities){
                
                if(Opp.Product_Type__c != null){
            
                    for(Id AId: accIDs){
                        
                        for(Product_Information__c pI : productInfos){
                            system.debug('in create product loop = ' + opp.Id + ' ' + AId + ' ' + pI.Id);
                            
                            system.debug('compared values = ' + opp.AccountId + ' = ' + AId + ' ' + pI.Account__c + ' = ' + AId + ' ' + opp.Product_Type__c + ' contains: '+ pI.Record_Type_Name__c);
                            if(opp.AccountId == AId && pI.Account__c == AId && opp.Product_Type__c.contains(pI.Record_Type_Name__c)){
                                system.debug('passed comparison');
                                
                                set<String> recordTypesDoNotCreate = new set<String>();
                                
                                for(Opportunity_Product_Information__c opi : exisitingOppProdInfo){
                                    
                                    if(opi.Opportunity__c == opp.Id && opp.Product_Type__c.contains(opi.Product_Information__r.Record_Type_Name__c)){
                                        
                                        recordTypesDoNotCreate.add(opi.Product_Information__r.Record_Type_Name__c);
                                        
                                    }
                                    
                                }
                                
                                for(Opportunity_Product_Information__c opi : exisitingOppProdInfo){
                                    
                                    if(opi.Opportunity__c == opp.Id && !(opp.Product_Type__c.contains(opi.Product_Information__r.Record_Type_Name__c))){
                                        
                                        deleteOppProdInfos.add(opi);
                                        
                                    }
                                    
                                }
                                
                                if(!(recordTypesDoNotCreate.contains(pI.Record_Type_Name__c))){
                                    
                                    Opportunity_Product_Information__c newOppProdInfo = new Opportunity_Product_Information__c ();
                               
                                    newOppProdInfo.Opportunity__c = opp.Id;
                                   
                                    newOppProdInfo.Product_Information__c = pI.Id;
                                   
                                    newOppProdInfos.add(newOppProdInfo);
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                
                }
        
            }
            
            if(newOppProdInfos.size() > 0){
                
                insert(newOppProdInfos);
                
            }
            
            if(deleteOppProdInfos.size() > 0){
                
                delete(deleteOppProdInfos);
                
            }
      
      }
    
}