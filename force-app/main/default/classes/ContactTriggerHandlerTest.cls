/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class ContactTriggerHandlerTest {

    @isTest
    public static void afterUpdateTest() {
        //Given
        List<Contact> contacts = TestDataFactory.createContacts(1, false);
        contacts[0].Status__c = 'Active';
        insert contacts;

        Test.setMock(HttpCalloutMock.class, new DropboxAPICreateFileErrorMock());

        //When
        Test.startTest();
        contacts[0].Status__c = 'Inactive';
        update contacts;
        Test.stopTest();

        //Then
        String subject = 'Your membership has been expired';
        List<EmailMessage> emailMessages = [SELECT Id 
                                            FROM EmailMessage 
                                            WHERE Name LIKE :subject
                                            LIMIT 1];
        List<Error__c> errors = [SELECT Id
                                 FROM Error__c
                                 WHERE Status__c = 'Error'];
        System.assert(emailMessages.isEmpty());
        System.assert(!errors.isEmpty());
    }
}