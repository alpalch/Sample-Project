/**
 * @description       : Test class for ProposalTableController
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 28-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class ProposalTableControllerTest {
    
    @isTest
    public static void getProposalsTest() {
        //Given
        List<Proposal__c> proposals = TestDataFactory.createProposals(10, true);

        //When
        Test.startTest();
        List<Proposal__c> result = ProposalsTableController.getProposals((String)proposals[0].Opportunity__c);
        Test.stopTest();

        //Then
        System.assertEquals(proposals.size(), result.size());
    }

    @isTest
    public static void createProposalTest() {
        //Given
        List<String> equipmentIds = new List<String>();
        List<Equipment__c> equipments = TestDataFactory.createEquipments(10, true);
        for(Equipment__c equipment : equipments) {
            equipmentIds.add((String)equipment.Id);
        }
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(1, true);

        //When
        Test.startTest();
        ProposalsTableController.createProposal(equipmentIds, opportunities[0].Id);
        Test.stopTest();

        //Then
        List<Proposal__c> resultProposal = [SELECT Id FROM Proposal__c WHERE Opportunity__c = :opportunities[0].Id];
        System.assertEquals(1, resultProposal.size());
        List<Proposal_Equipment__c> resultProposalEquipments = [SELECT Id FROM Proposal_Equipment__c WHERE Proposal__c = :resultProposal[0].Id];
        System.assertEquals(equipments.size(), resultProposalEquipments.size());

    }
}