/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class ProposalDetailBodyControllerTest {
    
    @isTest
    public static void createNewProposalSuccessTest(){
        List<String> equipIds = new List<String>();
        List<Equipment__c> listEquip = DataFactory.createMultipleEquipment(5);
        insert listEquip;

        for(Equipment__c equip :listEquip){
            equipIds.add(String.valueOf(equip.Id));
        }

        Opportunity opp = DataFactory.createOpportunity();
        insert opp;

        ProposalDetailBodyController.createNewProposal(equipIds, opp.Id);

        Proposal__c proposalToAssert = [SELECT Id FROM Proposal__c WHERE Opportunity__c = :opp.Id][0];
        List<Proposal_Equipment__c> listToAssert = [SELECT Id FROM Proposal_Equipment__c WHERE Proposal__c = :proposalToAssert.Id];

        System.assertEquals(5, listToAssert.size());
        System.assertEquals(true, String.isNotBlank(String.valueOf(proposalToAssert.Id)));
    }
}