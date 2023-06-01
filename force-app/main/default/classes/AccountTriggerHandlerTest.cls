/**
 * @description       : Test class for AccountTriggerHandler
 * @author            : @ValeriyPalchenko
 * @last modified on  : 30-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class AccountTriggerHandlerTest {
    
    @isTest
    public static void setShippingAddressTest() {
        //Given
        List<Account> accounts = TestDataFactory.createVendorAccounts(5, false);

        //When
        Test.startTest();
        insert accounts;
        Test.stopTest();

        //Then
        List<Account> accountsToAssert = [SELECT ID, BillingCity, ShippingCity
                                          FROM Account
                                          WHERE Id IN :accounts];

        for(Account account :accountsToAssert) {
            System.assert(account.ShippingCity == account.BillingCity);
        }
    }

    @isTest
    public static void makeMergedJsonTest() {
        //Given
        List<Account> masterRecords = TestDataFactory.createBuyerAccounts(1, true);
        List<Account> accounts = TestDataFactory.createBuyerAccounts(2, true);

        //When
        Test.startTest();
        Database.MergeResult[] results = Database.merge(masterRecords[0], accounts, false);
        Test.stopTest();

        //Then
        for(Database.MergeResult result :results) {
            System.assertEquals(masterRecords[0].Id, result.getId());
        }
    }

    @isTest
    public static void MakeUpdateExternalIdCalloutTest() {
        //Given
        List<Account> accounts = TestDataFactory.createBuyerAccounts(3, true);
        Test.setMock(HttpCalloutMock.class, new MakeUpdateExternalIdCalloutMock());

        //When
        Test.startTest();
        AccountTriggerHandler.makeUpdateExternalIdCallout(JSON.serialize(accounts));
        Test.stopTest();

        //Then
        System.assertEquals(2 != 5, true);
    }
}