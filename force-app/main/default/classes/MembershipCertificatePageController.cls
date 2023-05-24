/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class MembershipCertificatePageController {

    public String contactId;
    public Contact contact = new Contact();
    public String contactName {get; set;}
    public String accountName {get; set;}
    
    public MembershipCertificatePageController() {
        this.contactId = ApexPages.currentPage().getParameters().get('Id');
        this.contact = [SELECT Id, Name, Account.Name FROM Contact WHERE Id = :(Id)this.contactId];
        this.contactName = getContactName();
        this.accountName = getAccountName();
    }

    private String getContactName() {
        String contactName = this.contact.Name;
        return contactName;
    }

    private String getAccountName() {
        String accountName = this.contact.Account.Name;
        return accountName;
    }
}