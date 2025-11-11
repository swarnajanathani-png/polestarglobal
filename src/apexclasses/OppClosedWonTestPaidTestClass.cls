@isTest
public class OppClosedWonTestPaidTestClass {
	@isTest
    static void testProformaTestPaidException(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'Closed Received';
        opp.Payment_Option__c = 'ProformaInvoice';
        opp.CloseDate = System.today();
        insert opp;
        List<Opportunity> opprList = new List<Opportunity>();
        opprList.add(opp);
        Test.startTest();
        OpportunityClosedWonTestPaidClass.setTestPaidStatus(opprList);
        Test.stopTest();
    }
    
    @isTest
    static void testProformaTestPaid(){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Payment_Option__c = 'ProformaInvoice';
        insert opp;
        
        opp.StageName = 'Closed Won';
        opp.Approval_Status__c = 'Order Approved';
        opp.CloseDate = System.today();
        update opp;
        
        List<Opportunity> opprList = new List<Opportunity>();
        opprList.add(opp);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OppClosedWonTestPaidCalloutMock());
        OpportunityClosedWonTestPaidClass.setTestPaidStatus(opprList);
        Test.stopTest();
    }
}