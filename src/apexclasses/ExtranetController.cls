/**
 * 	@who	Samuel Arroyo (CloudSocius)
 * 	@when	08/06/2016
 * 	@what	Controller for Extranet page
 */
public class ExtranetController {

    public List<String> sections {get; set;}
    public Map<String, List<ExtranetDocument__c>> documents {get; set;}
    
    public ExtranetController() {
        // Initialise variables
        sections = new List<String>();
        documents = new Map<String, List<ExtranetDocument__c>>();
        
        // Retrieve extranet documents
        for (ExtranetDocument__c doc : [SELECT Name__c, FileType__c, Type__c, Section__c, URL__c, Service__c, CreatedDate 
                                        FROM ExtranetDocument__c ORDER BY Section__c, Name])
            if (!documents.containsKey(doc.Section__c)) {
                documents.put(doc.Section__c, new List<ExtranetDocument__c>{doc});
                sections.add(doc.Section__c);
            } else documents.get(doc.Section__c).add(doc);
    }
    
}