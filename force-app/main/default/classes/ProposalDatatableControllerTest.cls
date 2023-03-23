/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
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

    @isTest
    public static void deleteProposalSuccessTest(){
        Proposal__c prop = DataFactory.createProposal();
        insert prop;

        ProposalDatatableController.deleteProposal(String.valueOf(prop.Id));
        List<Proposal__c> listToAssert = [SELECT Id FROM Proposal__c WHERE Id = :prop.Id];

        System.assertEquals(true, listToAssert.isEmpty());
    }
}