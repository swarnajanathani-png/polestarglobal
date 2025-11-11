/**
 * @who		: Sadiq Adesanya <sadiq.adesanay@weare4c.com>
 * @when	: 04/12/2017
 * @what	: Utility class for 'ShipTrigger'
 */
public class ShipUtility {
    /**
     * @method		: validateContact()
     * @description	: Validate whether the primary contact on a ship is the primary contact to the ship's related Account
     * @return		: N/A
     * @params		: triggerShips - List of ship records passed from the Trigger to the class with values pre modification
     */
    public static void validateContact(List<Ship__c> triggerShips) {
        //Default contact called 'CSO TO BE ASSIGNED' is to be ignored
        Id defaultContactId = [SELECT Id FROM Contact WHERE Name = 'CSO TO BE ASSIGNED' Limit 1].Id;
        for(Ship__c ship : triggerShips) {
            if(ship.Primary_CSO_Name__c == defaultContactId) {
                
            } else {
                //Find an Account and Contact relationship that matches with the primary contact record
                Integer foundRelatedContact = [
                    SELECT Count()
                    FROM AccountContactRelation
                    WHERE ContactId = :ship.Primary_CSO_Name__c 
                    AND isActive = true 
                    AND AccountId =:ship.Company__c
                ];
                System.debug('Primary - FoundRelatedContact: ' + foundRelatedContact);
                if(foundRelatedContact > 0) {
                    
                } else {
                    //Present error when Contact and Account do not have a match
                   	ship.Primary_CSO_Name__c.addError('Primary CSO does not have a relationship with the ship\'s Company.');
                }
            }
            if(ship.Alternate_CSO_Name__c == defaultContactId || ship.Alternate_CSO_Name__c == null) {
                
            } else {
                //Find an Account and Contact relationship that matches with the alternate contact record
                Integer foundRelatedContact = [
                    SELECT Count()
                    FROM AccountContactRelation
                    WHERE ContactId = :ship.Alternate_CSO_Name__c 
                    AND isActive = true 
                    AND AccountId =:ship.Company__c
                ];
                System.debug('Alternate - FoundRelatedContact: ' + foundRelatedContact);
                if(foundRelatedContact > 0) {
                    
                } else {
                    //Present error when Contact and Account do not have a match
                   	ship.Alternate_CSO_Name__c.addError('Alternate CSO does not have a relationship with the ship\'s Company.');
                }
            }
        }
    }
}