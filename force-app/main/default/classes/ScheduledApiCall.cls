/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @last modified on  : 01-06-2023
 * @last modified by  : @ValeriyPalchenko
**/
global class ScheduledApiCall implements Schedulable {

    // System.schedule('ScheduledApiCall 1',  '0 00 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 2',  '0 05 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 3',  '0 10 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 4',  '0 15 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 5',  '0 20 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 6',  '0 25 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 7',  '0 30 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 8',  '0 35 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 9',  '0 40 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 10', '0 45 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 11', '0 50 * * * ?', new ScheduledApiCall());
    // System.schedule('ScheduledApiCall 12', '0 55 * * * ?', new ScheduledApiCall());
    
    global void execute(SchedulableContext ctx) {
        if(!Test.isRunningTest()) {
            makeSchedualedApiCall();
        }
    }

    @future(callout=true)
    public static void makeSchedualedApiCall() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setEndpoint('callout:SalesForceAwesomeOrg/services/apexrest/getLastCreatedAccounts/');

        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            updateAccounts(response.getBodyAsBlob().toString());
        }
    }

    private static void updateAccounts(String accountsData) {
        if(accountsData.length() > 2) {
            List<Account> accounts = (List<Account>)JSON.deserialize(accountsData, List<Account>.class);

            for(Account account :accounts) {
                account.ShippingCountry = 'United States';
                account.ShippingState = 'New York';
                account.BillingCountry = 'United States';
                account.BillingState = 'New York';
                account.Payment__c = 'Wire';
            }
            try{
                upsert accounts;
            } catch (DmlException e) {
                System.debug(e.getMessage());
            }
        }
    }
}