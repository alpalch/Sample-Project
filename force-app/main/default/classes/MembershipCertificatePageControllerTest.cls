/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public class MembershipCertificatePageControllerTest {

    @isTest
    public static void pageTest() {
        //Given
        List<Contact> contacts = TestDataFactory.createContacts(1, true);

        //When
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/MemberCertificatePage');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', contacts[0].Id);
        MembershipCertificatePageController mcController = new MembershipCertificatePageController();
        Test.stopTest();

        //Then
        System.assertEquals(contacts[0].Id, mcController.contactId);
        System.assert(true); // Assert for assert :)
    }
}