/**
*	@Who    Tiago Lopes @CloudSocius
*	@What	Controller for Payment results page
*	@When	25/03/2017
**/
public without sharing class BarclayCardPaymentSuccessfulController {
	public String orderId 		{get;set;}
	public String amount  		{get;set;}
	public String curr			{get;set;}
	public String companyName	{get;set;}
	public String paymentId		{get;set;}
	public String paymentDate	{get;set;}
	public String paymentStatus {get;set;}
	public String recId			{get;set;}
	public String dist			{get;set;}

	//status booleans
	public Boolean isSuccess	{get;set;}
	public Boolean isDeclined	{get;set;}
	public Boolean isException	{get;set;}
	public Boolean isCancel		{get;set;}
	public Boolean isInvoice 	{get;set;}
	//
	public SObject req  {get;set;}
	@TestVisible private Boolean proceedToPaymentCreation;

	/**
	*	@description constructor is filtering Payment result code coming from barclaycard from to display result in VF
	**/
	public BarclayCardPaymentSuccessfulController() {
		isSuccess = false;
		isDeclined = false;
		isCancel = false;
		isException = false;
		proceedToPaymentCreation = false;
		isInvoice = false;
		Map<String,String> parameters = ApexPages.currentPage().getParameters();

		if(parameters != null){
			try{
				dist = parameters.get('DIST');
				if(dist == null){
					isInvoice = true;
				}
			}
			catch(Exception e){
				isInvoice = true;
			}
			//determine payment status to render Front End
			if(parameters.get('STATUS') != null ){
				String pstat = parameters.get('STATUS');
				System.debug('status -> ' + pstat);
				if(pstat == '5' || pstat == '4' || pstat == '9' || pstat == '41' || pstat == '51' || pstat == '91' ){
					//
					isSuccess = true;
					//get params to crate payment record
					try{
						orderId = parameters.get('ORDERID');
						amount = parameters.get('AMOUNT');
						curr = parameters.get('CURRENCY');
						companyName = parameters.get('CN');
						paymentId = parameters.get('PAYID');
						paymentDate = parameters.get('TRXDATE');
						paymentStatus = parameters.get('STATUS');
						recId = parameters.get('RECID');
						if(orderId != null){
							if(!isInvoice){
								List<LRIT_CTR_Request__c> tmpList = [SELECT Id, Name, Payed__c FROM LRIT_CTR_Request__c WHERE Id = :recId LIMIT 1];
								if(!tmpList.isEmpty()){
									req = (LRIT_CTR_Request__c)tmpList.get(0);
								}
							}
							else{
								List<Invoices__c> tmpList = [SELECT Id, Name, Payed__c, CC_Payment_Number__c FROM Invoices__c WHERE Id = :recId LIMIT 1];
								if(!tmpList.isEmpty()){
									req = (Invoices__c)tmpList.get(0);
								}
							}
						}
						if(req != null){ 
							//check if this CTR Req has been payed already
							if(req.get('Payed__c') == false)
								proceedToPaymentCreation = true;
							else{
								System.debug('Attempt to insert duplicate Card Payment record. Denied.This request has already been payed for.');
							}
						}
					}
					catch(Exception e){
						System.debug('Failed to load parameters sent from barclaycard: ' + e.getMessage());
					}
				}
				else if(pstat == '2' || pstat == '93'){
					isDeclined = true;
					try{
						dist = parameters.get('DIST');
						recId = parameters.get('RECID');
					}
					catch(Exception e){
						System.debug('Problem getting parameters from server: ' + e.getMessage());
					}

				}
				else if(pstat =='52' || pstat == '92'){
					isException = true;
					try{
						dist = parameters.get('DIST');
						recId = parameters.get('RECID');
					}
					catch(Exception e){
						System.debug('Problem getting parameters from server: ' + e.getMessage());
					}
				}
				else if(pstat == '1'){
					isCancel = true;
					try{
						dist = parameters.get('DIST');
						recId = parameters.get('RECID');
					}
					catch(Exception e){
						System.debug('Problem getting parameters from server: ' + e.getMessage());
					}
				}
			}
		}
	}
	
	/**
	*	@description method to insert Credit Card Payment records in the system after successful barclaycard payments
	*	@return null pageRreference
	**/
	public PageReference createNewPayment(){
		Credit_Card_Payment__c newPayment = new Credit_Card_Payment__c();
		if(proceedToPaymentCreation){
			try{
				newPayment.Name = companyName + '-' + req.get('Name');
				newPayment.BCard_CrossReference__c = paymentId;
				newPayment.Amount__c = Decimal.valueOf(amount);
				newPayment.Company_Name__c = companyName;
				newPayment.Currency__c = curr;
				if(!isInvoice)
					newPayment.LRIT_CTR_Request__c = (Id)req.get('Id');
				else {
					newPayment.Invoice_Number__c = (Id)req.get('Id');
				}
				newPayment.Payment_Date__c = paymentDate;
				newPayment.Payment_Status__c = paymentStatus;
				//newPayment.LRIT_CTR_Request__r.Payed__c = true;

				insert newPayment;

				try{
					req.put('Payed__c',true);
					if(isInvoice)
						req.put('CC_Payment_Number__c', newPayment.Id);
					update req;
				}
				catch(DmlException e){
					System.debug('There was a problem updating LRIT_CTR_Request record Payed field: ' + e.getMessage());
					if(!isInvoice)
						insert new Credit_Card_Payment_error_logs__c(Related_CTR_Request__c = req.Id,
																Error_Description__c = 'There was a problem updating LRIT_CTR_Request record Payed field: ' + e.getMessage());
					else{
						insert new Credit_Card_Payment_error_logs__c(Related_Invoice__c = req.Id,
																Error_Description__c = 'There was a problem updating Invoice record Payed field: ' + e.getMessage());
					}
				}
				System.debug('Credit Card Payment inserted successfully.');
			}
			catch(Exception e){
				System.debug('There was a problem creating Payment Record: ' + e.getMessage());
				if(!isInvoice)
					insert new Credit_Card_Payment_error_logs__c(Related_CTR_Request__c = req.Id,
																Error_Description__c = 'There was a problem creating a Payment Record for this request: ' + e.getMessage());
				else{
					insert new Credit_Card_Payment_error_logs__c(Related_Invoice__c = req.Id,
																Error_Description__c = 'There was a problem creating a Payment Record for this request: ' + e.getMessage());
				}
			}
		}
		return null;
	}
}