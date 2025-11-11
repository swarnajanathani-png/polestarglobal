@isTest
public class HardwareODPPaidInvoiceCalloutTest {
   @isTest
    public static void testHardwareODPPaidInvoiceCallout(){
         Account acc = new Account();
        acc.Name = 'Test';
        acc.BillingCountry = 'United Kingdom';
        acc.Lead_Source__c = 'Self Service Portal';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test';
        opp.StageName = 'Closed Received';
        opp.CloseDate = System.today();
        insert opp;
        List<Opportunity> lstOpps = new List<Opportunity>();
        lstOpps.add(opp);
        Test.startTest();
        HardwareODPPaidInvoiceCallout.httpCallOut(lstOpps);
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
        Test.setMock(HttpCalloutMock.class, new HardwareODPPaidInvoiceCalloutTestMock());
        HardwareODPPaidInvoiceCallout.httpCallOut(opprList);
        Test.stopTest();
    }
}