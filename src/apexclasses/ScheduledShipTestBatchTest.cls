/**
 *  @who    Gen Estrada <genalyn.estrada@weare4c.com>
 *  @when   28/05/2019
 *  @what   Test class for ScheduledShipTestBatch
 */
@isTest
public with sharing class ScheduledShipTestBatchTest {
	@testSetup
	private static void setup(){
		// Create default contact
		TestUtility.createDefaultContact(true);

		// Create Accounts
		Account acc = TestUtility.createAccount('TestAccount1', false);
		insert acc;

		// Create CSO contactsa
		Contact con = TestUtility.createCSOContact('TestName1', acc.Id, false);
		insert con;

		// Create 10 month overdue Ships
		List<Ship__c> tenMonthShipList = new List<Ship__c>();
		for(Integer i = 0; i <= 9; i++){
			Ship__c ship = TestUtility.createShip('TestShip' + i, acc.Id, con.Id, '1234' + i, false);
			ship.Latest_Success_Date__c = System.today().addDays(ScheduledShipTestBatch.tenMonths);
			tenMonthShipList.add(ship);
		}

		insert tenMonthShipList;

		// Create 12 month overdue Ships
		List<Ship__c> twelveMonthShipList = new List<Ship__c>();
		for(Integer i = 10; i <= 19; i++){
			Ship__c ship = TestUtility.createShip('TestShip' + i, acc.Id, con.Id, '1234' + i, false);
			ship.Latest_Success_Date__c = System.today().addDays(ScheduledShipTestBatch.twelveMonths);
			twelveMonthShipList.add(ship);
		}

		insert twelveMonthShipList;
	}  


	private static testMethod void testHandlerTenMonths() {
		Date tenMonthsAgo = System.today().addDays(ScheduledShipTestBatch.tenMonths);
		
		Test.startTest();
			List<Ship__C> testShips = [SELECT Latest_Success_Date__c, No_Scheduled_Test_in_10_months__c, CreatedDate, 
									   Primary_CSO_Name__c, No_Scheduled_Test_in_12_months__c, Status__c, Primary_CSO_Email__c
									   FROM Ship__c WHERE Latest_Success_Date__c <= :tenMonthsAgo];
			ScheduledShipTestBatchHandler.processShips(testShips);
		Test.stopTest();

		List<Ship__c> tenMonthShipList = [SELECT Id FROM Ship__c WHERE No_Scheduled_Test_in_10_months__c = true];

		System.assertEquals(10, tenMonthShipList.size(), 'Ten month ship list is wrong.');
	}

	private static testMethod void testHandlerTwelveMonthsNoSuccessDate() {
		Date twelveMonthsAgo = System.today().addDays(ScheduledShipTestBatch.twelveMonths);

		Test.startTest();
			List<Ship__C> testShips = [SELECT Latest_Success_Date__c, No_Scheduled_Test_in_10_months__c, CreatedDate, 
									   Primary_CSO_Name__c, No_Scheduled_Test_in_12_months__c, Status__c, Primary_CSO_Email__c
									   FROM Ship__c WHERE Latest_Success_Date__c <= :twelveMonthsAgo];
			
			for(Ship__c ship : testShips){
				ship.Latest_Success_Date__c = null;
			}

			ScheduledShipTestBatchHandler.processShips(testShips);
		Test.stopTest();

		List<Ship__c> twelveMonthShipList = [SELECT Id FROM Ship__c WHERE No_Scheduled_Test_in_12_months__c = true];

		System.assertEquals(10, twelveMonthShipList.size(), 'Twelve month no success date ships list is wrong.');
	}

	private static testMethod void testHandlerTwelveMonths() {
		Date twelveMonthsAgo = System.today().addDays(ScheduledShipTestBatch.twelveMonths);

		Test.startTest();
			List<Ship__C> testShips = [SELECT Latest_Success_Date__c, No_Scheduled_Test_in_10_months__c, CreatedDate, 
									   Primary_CSO_Name__c, No_Scheduled_Test_in_12_months__c, Status__c, Primary_CSO_Email__c
									   FROM Ship__c WHERE Latest_Success_Date__c <= :twelveMonthsAgo];
			ScheduledShipTestBatchHandler.processShips(testShips);
		Test.stopTest();

		List<Ship__c> twelveMonthShipList = [SELECT Id FROM Ship__c WHERE No_Scheduled_Test_in_12_months__c = true];

		System.assertEquals(10, twelveMonthShipList.size(), 'Twelve month ship list is wrong.');
	}

	private static testMethod void testLogger(){
		Test.startTest();
			ScheduledShipTestBatchHandler.buildErrorLog('Something went wrong');
		Test.stopTest();

		System.assertEquals(1, [SELECT Count() FROM Error_Log__c], 'Error log was not created');
	}

	private static testMethod void testBatch() {
		Test.startTest();
			Database.executeBatch(new ScheduledShipTestBatch(), 50);
		Test.stopTest();
	}
	
	private static testMethod void testScheduleDaily() {
		Test.startTest();
			String jobId = ScheduledShipTestBatch.scheduleDaily();
		Test.stopTest();
	}
}