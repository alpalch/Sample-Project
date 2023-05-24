/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
global class DropboxAPICreateFileErrorMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(401);
        response.setStatus('Error');
        response.setBody('{Error}');
        return response;
    }
}