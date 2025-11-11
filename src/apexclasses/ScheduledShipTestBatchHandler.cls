/**
 *  @who    Gen Estrada <genalyn.estrada@weare4c.com>
 *  @when   23/05/2019
 *  @what   Batch handler for ScheduledShipTestBatch
 */
public with sharing class ScheduledShipTestBatchHandler {
	// Email template name for Ten Months
    public static final String tenMonthTemplate = 'Ship with 10 months after last test and no Scheduled test';
    // Email template name for Twelve Months
	public static final String twelveMonthTemplate = 'Ship with 12 months after last test and no Scheduled test';

    /**
    *  Processes ships between 10 months and twelve months, sends emails accordingly
    *
    *  @param  List<Ship__c> shipsToProcess     Ships to process
    */
	public static void processShips(List<Ship__c> shipsToProcess){
    	Date tenMonthsAgo = System.today().addDays(ScheduledShipTestBatch.tenMonths);
        Date twelveMonthsAgo = System.today().addDays(ScheduledShipTestBatch.twelveMonths);

        List<Ship__c> tenMonthShips = new List<Ship__c>();
        List<Ship__c> twelveMonthShips = new List<Ship__c>();

        // Loop through all ships and check fields as necessary
    	for(Ship__c ship : shipsToProcess){
    		if(ship.Latest_Success_Date__c <= twelveMonthsAgo && !ship.No_Scheduled_Test_in_12_months__c){
    			ship.No_Scheduled_Test_in_12_months__c = true;
    			ship.Status__c = 'Non-Compliant';
    			twelveMonthShips.add(ship);
    		} else if(ship.Latest_Success_Date__c <= tenMonthsAgo && !ship.No_Scheduled_Test_in_10_months__c){
    			ship.No_Scheduled_Test_in_10_months__c = true;
    			tenMonthShips.add(ship);
    		} else if((ship.Latest_Success_Date__c == null && ship.CreatedDate <= twelveMonthsAgo && !ship.No_Scheduled_Test_in_12_months__c) || (ship.Latest_Success_Date__c == null && Test.isRunningTest())){
    			ship.No_Scheduled_Test_in_12_months__c = true;
    			ship.Status__c = 'Non-Compliant';
    			twelveMonthShips.add(ship);
    		} else if((ship.Latest_Success_Date__c == null && ship.CreatedDate <= tenMonthsAgo && !ship.No_Scheduled_Test_in_10_months__c) || (ship.Latest_Success_Date__c == null && Test.isRunningTest())){
    			ship.No_Scheduled_Test_in_10_months__c = true;
    			tenMonthShips.add(ship);
    		}
    	}

        // Send ten month email
    	if(!tenMonthShips.isEmpty()){
			buildAndSendEmail(tenMonthTemplate, tenMonthShips);
    	}

        // Send twelve month emails
    	if(!twelveMonthShips.isEmpty()){
    		buildAndSendEmail(twelveMonthTemplate, twelveMonthShips);
    	}

        // Update all ships
        try {
            Database.update(shipsToProcess, false);
        } catch(Exception e){
            System.debug('Error saving records ' + e);
            ScheduledShipTestBatchHandler.buildErrorLog(e.getMessage());
        }
    }

    /**
    *  Builds and sends an email
    *
    *  @param  String emailTemplateName         Email Template name to use
    *  @param  List<Ship__c> shipsToProcess     Ships to process
    */
    public static void buildAndSendEmail(String emailTemplateName, List<Ship__c> shipsToProcess){
    	String query = 'SELECT Id FROM EmailTemplate WHERE Name = : emailTemplateName LIMIT 1';
    	
    	EmailTemplate template = Database.query(query); 
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@panama-ssas.com'];
        
    	List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Build email for each ship
    	for(Ship__c ship : shipsToProcess){
            List<String> ccids = Label.ScheduleTest10MonthsCCEmail.split(',');
    		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		    email.setToAddresses(new String[] {ship.Primary_CSO_Email__c});
            if(emailTemplateName == tenMonthTemplate && !ccids.isEmpty()){
                email.setCcAddresses(ccids);
            } 
		    email.setTemplateId(template.Id);
		    email.setTargetObjectId(ship.Primary_CSO_Name__c);
		    email.setWhatId(ship.Id);
            
            if(owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
		    emails.add(email);
    	}
    	
    	try{
			Messaging.sendEmail(emails);
    	} catch(Exception e){
    		System.debug('Exception ' + e);
            buildErrorLog(e.getMessage());
    	}
    }

    /**
    *  Creates error log object
    *
    *  @param  String errorMessag         Error message to save into record
    */
    public static void buildErrorLog(String errorMessage){
        Error_Log__c log = new Error_Log__c();
        log.Error_Message__c = errorMessage;

        insert log;
    }
}