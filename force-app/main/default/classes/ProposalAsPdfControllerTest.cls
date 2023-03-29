/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 29-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
/**
 * @description       : Test class for ProposalAsPdfController
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 29-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class ProposalAsPdfControllerTest {
    @isTest
    public static void proposalPageTest() {
        // Given
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(1, false);
        List<Contact> contacts = TestDataFactory.createContacts(1, true);
        List<Proposal__c> proposals = TestDataFactory.createProposals(1, true);
        proposalEquipments[0].Proposal__c = proposals[0].Id;
        insert proposalEquipments;
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = proposals[0].Opportunity__c,
            ContactId = contacts[0].Id,
            isPrimary = true
        );
        insert opportunityContactRole;

        // When
        Test.startTest();
        Pagereference pageRef = new Pagereference('/apex/ProposalAsPdf');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('proposalId', proposals[0].Id);
        ProposalAsPdfController prAsPdf = new ProposalAsPdfController();
        Test.stopTest();
        
        // Then
        System.assertEquals(proposals[0].Id, prAsPdf.proposalId);
        Proposal__c proposal = prAsPdf.getProposal();
        List<Map<String, String>> proposalEquipmentsMap = prAsPdf.getProposalEquipment();
        String accountName = prAsPdf.getAccountName();
        String contactName = prAsPdf.getContactName();
        String contactEmail = prAsPdf.getContactEmail();
    }
}