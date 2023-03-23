public without sharing class AccountTriggerHandler {
    
    public static void setShippingAddress(List<Account> triggerList){
        for(Account acc :triggerList){
            if (acc.BillingCity != null) {
                acc.ShippingCountry = acc.BillingCountry;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingCountry = 'United States';
                acc.ShippingState = 'Alaska';
                acc.ShippingStreet = acc.BillingStreet;
            }
        }
    }

    public static void setAccountShippingState(List<Account> triggerList){
        List<Account> listToUpdate = new List<Account>();
        for(Account acc :triggerList){
            if (acc.BillingState != null) {
                Account newAcc = new Account(
                    Id = acc.Id,
                    ShippingState = acc.BillingState
                );
                listToUpdate.add(newAcc);
            }
        }
        update listToUpdate;
    }
}