@isTest
global class OppClosedWonTestPaidCalloutMock implements HttpCalloutMock {
	global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"Message":"Paid test with PSON: SV-022465"}');
        res.setStatusCode(200);
        return res;
    }
}