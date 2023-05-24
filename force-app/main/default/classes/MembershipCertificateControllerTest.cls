/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public class MembershipCertificateControllerTest {
    
    @isTest
    public static void createMembershipCalloutErrorTest() {
        //Given
        List<Contact> contacts = TestDataFactory.createContacts(1, true);
        Test.setMock(HttpCalloutMock.class, new DropboxAPICreateFileErrorMock());

        //When
        Test.startTest();
        MembershipCertificateController.createMembership((String)contacts[0].Id);
        Test.stopTest();

        //Then
        String subject = 'Your membership successfuly created';
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

    @isTest
    public static void createMembershipTest() {
        //Given
        List<Contact> contacts = TestDataFactory.createContacts(1, true);
        Test.setMock(HttpCalloutMock.class, new DropboxAPICreateFileMock());

        //When
        Test.startTest();
        MembershipCertificateController.createMembership((String)contacts[0].Id);
        Test.stopTest();

        //Then
        String subject = 'Your membership successfuly created';
        List<EmailMessage> emailMessages = [SELECT Id 
                                            FROM EmailMessage 
                                            WHERE Name LIKE :subject
                                            LIMIT 1];
        List<Error__c> errors = [SELECT Id
                                 FROM Error__c
                                 WHERE Status__c = 'Error'];
        System.assert(!emailMessages.isEmpty());
        System.assert(errors.isEmpty());
    }
}