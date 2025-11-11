/**
*	@who TL @ 4C
*	@what  Helper class for lightning community features
*	@when  29/08/2017
**/
public with sharing class CommunityHelper {

	/**
	*	@description queries records with given parameters object and to retrieve to custom search barr using dynamic query
	*	@param objectName with object name to add to query
	*	@param fields holding the list of fields to filter by
	*	@param word with string to query using wildcard
	*	@return results holding list of rows retrieved
	*   @edit field now allows searching for IMO numbers and Name in search bar.
	*/
    @AuraEnabled
    public static List<SObject> fetchRecords(String objectName, List<String> fields, String word) {
        
        String SHIP_IMO_FIELD = 'IMO_Number__c';
        String COMPANY_IMO_FIELD = 'Company_IMO_Number__c';
        String NAME = 'Name';
        String words = word + '%';
        List<String> fieldFilters = new List<String>();
        
        if(objectName == 'Ship__c' && word.isNumeric()){
            fields.add(SHIP_IMO_FIELD);
        }
        else if(objectName == 'Account' && word.isNumeric()){
            fields.add(COMPANY_IMO_FIELD);
        }
        else{
            fields.add(NAME);
        }
        
        for (String field : fields)
            fieldFilters.add(field + ' LIKE :words');
        List<SObject> results = Database.query('SELECT Id, Name FROM ' + objectName + ' WHERE ' + String.join(fieldFilters, ' OR '));
        return results;
    }

    /**
    *	@description method to extract SObject type burried in the URL
    *	@param String url with the URL passed by front end
    *	@return String objType with the object type extracted
    **/
    @AuraEnabled
    public static String getSObjectType(String url){
    	String objType = '';
    	if(url != null && String.isNotBlank(url)){
    		// assuming URL for community navbar will not change number of directories
    		List<String> subStrings = url.split('/');
    		try{
    			objType = subStrings[4];
    		}
    		catch(Exception e){
    			System.debug('Failed to parse object type from URL string: ' + e.getMessage());
    		}
    	}
        System.debug('objType ' + objType);
    	return objType;
    }
}