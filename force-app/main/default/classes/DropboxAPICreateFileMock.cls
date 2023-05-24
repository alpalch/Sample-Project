/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
global class DropboxAPICreateFileMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        return response;
    }
}