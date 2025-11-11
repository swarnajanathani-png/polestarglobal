@isTest
global class LRITCTRValidationControllerMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        if (request.getEndpoint().endsWith('identification')) {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"shipName": "PAN COASTAL GXT","shipType": "SHIP_TYPE_0300","imoNumber": "5443374","mmsiNumber": "788388538","callSign": "GXT261"}');
            response.setStatusCode(200);
            //return response; 
        }else if (request.getEndpoint().endsWith('mostrecentposition')) {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"gnssPosition": "2021-09-21 06:02:52","latitude": 20.331975955167938,"longitude": -138.39492539434605}');
            response.setStatusCode(200);
            //return response; 
        }
        return response;
    }
    
}