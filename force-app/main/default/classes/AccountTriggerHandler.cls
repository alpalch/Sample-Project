/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 27-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class AccountTriggerHandler {
    
    public static void setShippingAddress(List<Account> triggeredAccounts) {
        for(Account account :triggeredAccounts) {
            if (account.BillingCity != null) {
                account.ShippingCountry = account.BillingCountry;
                account.ShippingCity = account.BillingCity;
                account.ShippingPostalCode = account.BillingPostalCode;
                account.ShippingCountry = 'United States';
                account.ShippingState = 'Alaska';
                account.ShippingStreet = account.BillingStreet;
            }
        }
    }

    public static void setAccountShippingState(List<Account> triggeredAccounts) {
        List<Account> accountsToUpdate = new List<Account>();
        for(Account account :triggeredAccounts) {
            if (account.BillingState != null) {
                Account newAccount = new Account(
                    Id = account.Id,
                    ShippingState = account.BillingState
                );
                accountsToUpdate.add(newAccount);
            }
        }
        update accountsToUpdate;
    }
}