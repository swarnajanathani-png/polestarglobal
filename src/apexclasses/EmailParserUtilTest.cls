/**
*   @who    TL @ 4C
*   @what   Test Class for EmailParserUtil
*   @when   10/10/2017
* 	@changelog		28/11/2018 Gen Estrada 	Changed asserts due to custom setting being changed
*/
@isTest
private class EmailParserUtilTest {
    
    @testSetup
    static void setupData(){
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingCountry = 'United Kingdom',
            Fleet_size__c = 100,
            Account_Type__c = 'Strategic account',
            Account_Status__c = 'Commercial',
            Lead_Source__c = 'Polestarglobal.com'
        );
        
        Account testAccount1 = new Account(
            Name = 'Test Account1',
            BillingCountry = 'United Kingdom',
            Fleet_size__c = 100,
            Account_Type__c = 'Strategic account',
            Account_Status__c = 'Commercial',
            Lead_Source__c = 'Polestarglobal.com'
        );
        insert new List<Account> {testAccount1, testAccount};
        
        //Contact required to be CSO record type
        Id csoRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CSO').getRecordTypeId();
        //Create CSO default contact, a matching contact and a non matching contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Status__c = 'Attention',
            RecordTypeId = csoRecordType,
            Email = 'testEmail@gmail.com'
        );
        Contact testContact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1',
            AccountId = testAccount1.Id,
            Status__c = 'Attention',
            RecordTypeId = csoRecordType,
            Email = 'testEmail@gmail.com'
        );
        Contact defaultContact = new Contact(
            FirstName = 'CSO',
            LastName = 'TO BE ASSIGNED',
            Email = 'richard.fosu@weare4c.com',
            Phone = '+501 989-6569',
            AccountId = testAccount.Id,
            RecordTypeId = csoRecordType
        );
        
        insert testContact;
        insert testContact1;
        insert defaultContact;
        
        //Create and insert Ship record which tests the utility class and trigger
        Ship__c testShip = new Ship__c(
            Name = 'Test Ship',
            Company__c = testAccount.Id,
            IMO_Number__c = '9400942',
            Primary_CSO_Name__c = testContact.Id,
            Alternate_CSO_Name__c = testContact.Id,
            Call_Sign__c = '3FKT',
            MMSI__c = '351218000',
            Primary_CSO_Email__c = testContact.Email
        );
        insert testShip;

    }
    // test positive parsing and full ship match
    @isTest static void test_caseParsing_positive() {

        Case c = buildCase(
            'New',
            'Email',
            '!!!! TEST TEST Call !!!! --- SSAS ALERT MESSAGE --- Vessel Name:Test Ship \r MMSI:351218000 IMN:435121811 IMO:9400942 Call Signal:3FKT SSAS TEST MSG FOR RADIO SURVEY. PLS ACK FOR RECORD PURPOSE LAT:14:26.04N LON:120:30.29E Time:22/08/2017 10:28:24 (UTC) COURSE: 230 deg SPEED: 00 kt Shani Naik Professional Service Delivery Consultant Mobile: +44 (0)7500 918753 Address: 2nd Floor Fountain House Fenchurch Street, London, Greater London, EC3M 5DJ Website: www.weare4c.com Email: Shani.naik@weare4c.com We build customer companies -- Tiago Lopes Salesforce Developer',
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSAS Alert').getRecordTypeId()
        );
        //get ship to match
        Ship__c ship = [SELECT Id, Name, MMSI__c, IMO_Number__c, Primary_CSO_Name__c, Call_Sign__c FROM Ship__c WHERE Name = 'Test Ship'];

        Test.startTest();
            insert c;
        Test.stopTest();

        c = [SELECT Id, Ship__c, Call_Sign_Parsed__c, Longitude_Parsed__c, Latitude_Parsed__c, Date_Parsed__c, 
                    Time_Parsed__c, Time_Standard_Parsed__c, IMO_Parsed__c, MMSI_Parsed__c, Ship_Name_Parsed__c,
                    SSAS_Email_Parsing_Notes_New__c, Unmatched_Ship_Fields__c, Alert_Status__c, Verification_Required__c FROM Case WHERE Id = :c.Id];
        // assert on parsed values
        System.assertEquals('9400942',c.IMO_Parsed__c);
        System.assertEquals('351218000',c.MMSI_Parsed__c);
        System.assertEquals('3FKT',c.Call_Sign_Parsed__c);
        System.assertEquals('Test Ship',c.Ship_Name_Parsed__c);
        System.assertEquals('14:26.04N',c.Latitude_Parsed__c);
        System.assertEquals('120:30.29E',c.Longitude_Parsed__c);
        System.assertEquals('10:28:24',c.Time_Parsed__c);
        System.assertEquals('22/08/2017',c.Date_Parsed__c);
        System.assertEquals('UTC',c.Time_Standard_Parsed__c);
        System.assertEquals(EmailParserUtil.FULLY_PARSED,c.SSAS_Email_Parsing_Notes_New__c);
        System.assert(String.isBlank(c.Unmatched_Ship_Fields__c));
        System.assertEquals(false, c.Verification_Required__c);
        System.assertEquals(ship.Id,c.Ship__c);
        System.assertEquals(EmailParserUtil.TEST_ALERT,c.Alert_Status__c);

    }

    // this will fail to match CS and MMSI against ship record
    @isTest static void test_casePartialMatching_positive() {

        Case c = buildCase(
            'New',
            'Email',
            '!!!! TEST Call !!!! --- SSAS ALERT MESSAGE --- Vessel Name:Test Ship \r MMSI:351218001 IMN:435121811 IMO:9400942 Call Signal:3FKL SSAS TEST MSG FOR RADIO SURVEY. PLS ACK FOR RECORD PURPOSE LAT:14:26.04N LON:120:30.29E Time:22/08/2017 10:28:24 (UTC) COURSE: 230 deg SPEED: 00 kt Shani Naik Professional Service Delivery Consultant Mobile: +44 (0)7500 918753 Address: 2nd Floor Fountain House Fenchurch Street, London, Greater London, EC3M 5DJ Website: www.weare4c.com Email: Shani.naik@weare4c.com We build customer companies This is not a test -- Tiago Lopes Salesforce Developer',
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSAS Alert').getRecordTypeId()
        );
        //get ship to match
        Ship__c ship = [SELECT Id, Name, MMSI__c, IMO_Number__c, Call_Sign__c FROM Ship__c WHERE Name = 'Test Ship'];

        Test.startTest();
        	c.Alert_Status__c = EmailParserUtil.TEST_ALERT;
            insert c;
        Test.stopTest();

        c = [SELECT Id, Ship__c, Call_Sign_Parsed__c, Longitude_Parsed__c, Latitude_Parsed__c, Date_Parsed__c, 
                    Time_Parsed__c, Time_Standard_Parsed__c, IMO_Parsed__c, MMSI_Parsed__c, Ship_Name_Parsed__c,
                    SSAS_Email_Parsing_Notes_New__c, Unmatched_Ship_Fields__c, Alert_Status__c, Verification_Required__c FROM Case WHERE Id = :c.Id];
        
        // assert on parsed values
        System.assertEquals('9400942',c.IMO_Parsed__c);
        System.assertNotEquals('351218000',c.MMSI_Parsed__c);
        System.assertNotEquals('3FKT',c.Call_Sign_Parsed__c);
        System.assertEquals('Test Ship',c.Ship_Name_Parsed__c);
        System.assertEquals('14:26.04N',c.Latitude_Parsed__c);
        System.assertEquals('120:30.29E',c.Longitude_Parsed__c);
        System.assertEquals('10:28:24',c.Time_Parsed__c);
        System.assertEquals('22/08/2017',c.Date_Parsed__c);
        System.assertEquals('UTC',c.Time_Standard_Parsed__c);
        System.assertEquals(EmailParserUtil.PARTIAL_SHIP_MATCH,c.SSAS_Email_Parsing_Notes_New__c);
        System.assert(String.isNotBlank(c.Unmatched_Ship_Fields__c));
        System.assertEquals(false, c.Verification_Required__c);
        System.assertEquals(ship.Id,c.Ship__c);
        System.assertEquals(EmailParserUtil.REAL_ALERT,c.Alert_Status__c);

    }

    // this will fail to parse MMSI and Call Sign
    @isTest static void test_casePartialParsing_positive() {

        Case c = buildCase(
            'New',
            'Email',
            '!!!! TEST Call !!!! --- SSAS ALERT MESSAGE --- Vessel Name:Test Ship \r MMSI:311218001 IMN:435121811 IMO:9400942 Call Signal:XXKL SSAS TEST MSG FOR RADIO SURVEY. PLS ACK FOR RECORD PURPOSE LAT:14:26.04N LON:120:30.29E Time:22/08/2017 10:28:24 (UTC) COURSE: 230 deg SPEED: 00 kt Shani Naik Professional Service Delivery Consultant Mobile: +44 (0)7500 918753 Address: 2nd Floor Fountain House Fenchurch Street, London, Greater London, EC3M 5DJ Website: www.weare4c.com Email: Shani.naik@weare4c.com We build customer companies -- Tiago Lopes Salesforce Developer',
            Schema.SObjectType.Case.getRecordTypeInfosByName().get('SSAS Alert').getRecordTypeId()
        );
        //get ship to match
        Ship__c ship = [SELECT Id, Name, MMSI__c, IMO_Number__c, Call_Sign__c FROM Ship__c WHERE Name = 'Test Ship'];

        Test.startTest();
            insert c;
        Test.stopTest();

        c = [SELECT Id, Ship__c, Call_Sign_Parsed__c, Longitude_Parsed__c, Latitude_Parsed__c, Date_Parsed__c, 
                    Time_Parsed__c, Time_Standard_Parsed__c, IMO_Parsed__c, MMSI_Parsed__c, Ship_Name_Parsed__c,
                    SSAS_Email_Parsing_Notes_New__c, Unmatched_Ship_Fields__c, Alert_Status__c, Verification_Required__c FROM Case WHERE Id = :c.Id];
        
        // assert on parsed values
        System.assertEquals('9400942',c.IMO_Parsed__c);
        System.assertEquals(null,c.MMSI_Parsed__c);
        System.assertEquals(null,c.Call_Sign_Parsed__c);
        System.assertEquals('Test Ship',c.Ship_Name_Parsed__c);
        System.assertEquals('14:26.04N',c.Latitude_Parsed__c);
        System.assertEquals('120:30.29E',c.Longitude_Parsed__c);
        System.assertEquals('10:28:24',c.Time_Parsed__c);
        System.assertEquals('22/08/2017',c.Date_Parsed__c);
        System.assertEquals('UTC',c.Time_Standard_Parsed__c);
        System.assertEquals(EmailParserUtil.PARTIALLY_PARSED,c.SSAS_Email_Parsing_Notes_New__c);
        System.assert(String.isNotBlank(c.Unmatched_Ship_Fields__c));
        // Cahnged to true on 28/11/18 by Gen Estrada 4C to match line 123 of EmailParserUtil
        System.assertEquals(true, c.Verification_Required__c);
        System.assertEquals(ship.Id,c.Ship__c);
        // Changed to test alert on 28/11/18 by Gen Estrada 4C to match the SSAS Test Test requirement 
        System.assertEquals(EmailParserUtil.TEST_ALERT, c.Alert_Status__c);

    }
    
    // private helpers

    private static Account buildDistributor(String name, String accStatus, Id recordTypeId, String billingCountry, String leadSource){
        Account acc = new Account(
            Name = name,
            Account_Status__c = accStatus,
            RecordTypeId = recordTypeId,
            BillingCountry = billingCountry,
            Lead_Source__c = leadSource
            );
        return acc;
    }

    private static Account buildAcc(String name, String accStatus, String accType, Integer fleetSize, Id distributor, String sector, String billingCountry, String leadSource){
        Account acc = new Account(
            Name = name,
            Account_Status__c = accStatus,
            Account_Type__c = accType,
            Fleet_Size__c = fleetSize,
            Distributor__c = distributor,
            Sector__c = sector,
            BillingCountry = billingCountry,
            Lead_Source__c = leadSource
            );
        return acc;
    }

    private static Contact buildContact(String firstName,String lastName, String email,String phone, Id recordTypeId, Id accId){
        Contact con = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Phone = phone,
            RecordTypeId = recordTypeId,
            AccountId = accId
            );
        return con;
    }

    private static Ship__c buildShip(String name, Id company, String primaryCSO, String imoNr, String mmsi, String callSign){
        Ship__c ship = new Ship__c(
            Name = name,
            Company__c = company,
            Primary_CSO_Name__c = primaryCSO,
            IMO_Number__c = imoNr,
            MMSI__c = mmsi,
            Call_Sign__c = callSign
            );
        return ship;
    }

    public static Case buildCase(String status, String origin, String description, Id recTypeId){
        Case c = new Case(
            Status = status,
            Origin = origin,
            Description = description,
            RecordTypeId = recTypeId
            );
        return c;
    }
    
    
    
}