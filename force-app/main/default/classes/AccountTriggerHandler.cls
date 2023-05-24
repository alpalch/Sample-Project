/**
 * @description       : This class is Handler for AccountTrigger
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
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
}