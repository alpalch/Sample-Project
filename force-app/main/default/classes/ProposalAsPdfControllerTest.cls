/**
 * @description       : Test class for ProposalAsPdfController
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class ProposalAsPdfControllerTest {
    @isTest
    public static void proposalPageTest() {
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(1, true);
        List<Proposal__c> proposals = TestDataFactory.createProposals(1, true);
        Test.startTest();
        Pagereference pageRef = new Pagereference('/apex/ProposalAsPdf');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('proposalId', proposals[0].Id);
        ProposalAsPdfController prAsPdf = new ProposalAsPdfController();
        Test.stopTest();
        System.assertEquals(proposals[0].Id, prAsPdf.proposalId);
    }
}