/**
 * @description       : This class is Handler for AccountTrigger
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 30-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class AccountTriggerHandler {
    
    public static void setShippingAddress(List<Account> triggeredAccounts) {
        for(Account account :triggeredAccounts) {
            if (account.BillingCity != null) {
                account.ShippingCountryCode = account.BillingCountryCode;
                account.ShippingCity = account.BillingCity;
                account.ShippingPostalCode = account.BillingPostalCode;
                account.ShippingStateCode = account.BillingStateCode;
                account.ShippingStreet = account.BillingStreet;
            }
        }
    }

    public static void makeMergedJson(List<Account> triggerAccounts) {
        List<Account> accountsForJson = new List<Account>();
        for(Account account :triggerAccounts) {
            if(account.MasterRecordId != null) {
                accountsForJson.add(account);
            }
        }

        if(!accountsForJson.isEmpty()) {
            List<Map<String,String>> jsonData = new List<Map<String,String>>();
            for(Account account :accountsForJson) {
                Map<String, String> mapForJSON = new Map<String, String>();
                mapForJSON.put('Id', (String)account.ExternalId__c);
                mapForJSON.put('ExternalID__c', (String)account.MasterRecordId);
                jsonData.add(mapForJSON);
            }
            if(!Test.isRunningTest()) {
                makeUpdateExternalIdCallout(JSON.serialize(jsonData));
            }
        }
    }

    @future(callout=true)
    public static void makeUpdateExternalIdCallout(String jsonData) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setBody(jsonData);
        request.setMethod('POST');
        request.setEndpoint('callout:SalesForceAwesomeOrg/services/apexrest/updateExternalID/');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');

        HttpResponse response = http.send(request);
    }
}