@isTest
global class HardwareODPPaidInvoiceCalloutTestMock implements HttpCalloutMock {
	global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"Message":"Internal Server Error"}');
        res.setStatusCode(500);
        return res;
    }
}