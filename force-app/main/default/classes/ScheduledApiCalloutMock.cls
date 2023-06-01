/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @last modified on  : 01-06-2023
 * @last modified by  : @ValeriyPalchenko
**/
global class ScheduledApiCalloutMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        List<Account> accountsJson = TestDataFactory.createBuyerAccounts(5, false);

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBodyAsBlob(Blob.valueOf(JSON.serialize(accountsJson)));
        return response;
    }
}