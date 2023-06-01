/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @last modified on  : 30-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
global class MakeUpdateExternalIdCalloutMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        return response;
    }
}