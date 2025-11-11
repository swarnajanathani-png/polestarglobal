/**
 * 	@who	Samuel Arroyo (CloudSocius)
 * 	@when	07/06/2016
 * 	@what	Controller for listing distributors
 */
public class LRITCTRHomeController {

    public List<Account> distributors {get; set;}
    
    // Constructor
    public LRITCTRHomeController() {
        // Get distributors
        distributors = [SELECT Name, ImageURL__c FROM Account WHERE RecordType.Name = 'Distributor' AND ShowOnPortal__c = true ORDER BY Name];
    }
    
}