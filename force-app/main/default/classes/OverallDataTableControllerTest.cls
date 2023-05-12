/**
 * @description       : This is a test class for OverallDataTableController
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 13-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class OverallDataTableControllerTest {

    @isTest
    public static void getTableDataTest() {
        //Given
        Opportunity opportunity = TestDataFactory.createOpportunities(1, true)[0];
        String emptyOpportunityId = opportunity.Id;
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(5, true);
        String opportunityId = [SELECT Opportunity__c
                                FROM Proposal__c
                                WHERE Id = :proposalEquipments[0].Proposal__c].Opportunity__c;
        
        //When
        Test.startTest();
        List<Proposal> proposals = OverallDataTableController.getTableData(opportunityId);
        List<Proposal> emptyProposals = OverallDataTableController.getTableData(emptyOpportunityId);
        Test.stopTest();

        //Then
        System.assertEquals(1, proposals.size());
        System.assert(emptyProposals.isEmpty());
    }

    @isTest
    public static void updateIsExpandedFieldTest() {
        //Given
        List<Proposal__c> proposals = TestDataFactory.createProposals(5, true);
        proposals[1].isExpandedTableRow__c = true;
        proposals[3].isExpandedTableRow__c = true;
        List<Proposal> proposalsWrapper = new List<Proposal>();
        for(Proposal__c proposal : proposals) {
            Proposal newProposal = new Proposal();
            newProposal.proposalId = proposal.Id;
            newProposal.proposalIsExpanded = proposal.isExpandedTableRow__c;

            proposalsWrapper.add(newProposal);
        }

        //When
        Test.startTest();
        OverallDataTableController.updateIsExpandedField(JSON.serialize(proposalsWrapper));
        Test.stopTest();

        //Then
        List<Proposal__c> updatedProposals = [SELECT isExpandedTableRow__c
                                              FROM Proposal__c
                                              WHERE Id IN :proposals];
        Integer expandedProposals = 0;
        for(Proposal__c proposal :updatedProposals) {
            if(proposal.isExpandedTableRow__c) {
                expandedProposals++;
            }
        }
        System.assertEquals(2, expandedProposals);
    }
}