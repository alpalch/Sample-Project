@isTest
public with sharing class ProposalDatatableControllerTest {
    
    @isTest
    public static void getProposalsSuccessTest(){
        List<Proposal__c> listProposals = DataFactory.createMultipleProposal(5);
        insert listProposals;
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :listProposals[0].Opportunity__c][0];

        List<Proposal__c> listToAssert = ProposalDatatableController.getProposals(String.ValueOf(opp.Id));

        System.assertEquals(5, listToAssert.size());
    }
}
