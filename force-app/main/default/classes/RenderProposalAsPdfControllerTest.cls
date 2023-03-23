/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class RenderProposalAsPdfControllerTest {
    
    @isTest
    public static void getProposalSuccessTest(){
        Proposal_Equipment__c proposalEquipment = DataFactory.createProposalEquipment();
        insert proposalEquipment;
        String currentProposalId = String.valueOf(proposalEquipment.Proposal__c);

        RenderProposalAsPdfController prAsPdf = new RenderProposalAsPdfController();
        prAsPdf.currentProposalId = currentProposalId;

        Proposal__c proposal = prAsPdf.getProposal();
        Proposal__c proposalToAssert = [SELECT Id, Name, Opportunity__c, Total_Price__c FROM Proposal__c WHERE Id = :Id.valueOf(currentProposalId)][0];

        System.assertEquals(proposalToAssert, proposal);
    }

    @isTest
    public static void getProposalEquipmentSuccessTest(){
        Proposal_Equipment__c proposalEquipment = DataFactory.createProposalEquipment();
        insert proposalEquipment;
        String currentProposalId = String.valueOf(proposalEquipment.Proposal__c);

        RenderProposalAsPdfController prAsPdf = new RenderProposalAsPdfController();
        prAsPdf.currentProposalId = currentProposalId;

        List<Map<String, String>> returnList = prAsPdf.getProposalEquipment();

        System.assertEquals('Test', returnList[0].get('equipmentName'));
    }

    @isTest
    public static void getProposalAccountSuccessTest(){
        Proposal_Equipment__c proposalEquipment = DataFactory.createProposalEquipment();
        insert proposalEquipment;
        String currentProposalId = String.valueOf(proposalEquipment.Proposal__c);

        RenderProposalAsPdfController prAsPdf = new RenderProposalAsPdfController();
        prAsPdf.currentProposalId = currentProposalId;

        Account account = prAsPdf.getProposalAccount();

        Proposal__c proposal = [SELECT Id, Opportunity__c FROM Proposal__c WHERE Id = :proposalEquipment.Proposal__c][0];
        List<Opportunity> listOpp = [SELECT AccountId FROM Opportunity WHERE Id = :proposal.Opportunity__c]; 
        Account accountToAssert = [SELECT Name FROM Account WHERE Id = :listOpp[0].AccountId][0];

        System.assertEquals(accountToAssert, account);
    }

    @isTest
    public static void getProposalContactSuccessTest(){
        Proposal__c proposal = DataFactory.createProposal();
        insert proposal;
        String currentProposalId = String.valueOf(proposal.Id);

        RenderProposalAsPdfController prAsPdf = new RenderProposalAsPdfController();
        prAsPdf.currentProposalId = currentProposalId;

        OpportunityContactRole ocr = DataFactory.createOCR();
        ocr.OpportunityId = proposal.Opportunity__c;
        insert ocr;

        Contact contact = prAsPdf.getProposalContact();
        Contact contactToAssert = [SELECT Name, Email FROM Contact WHERE Id = :ocr.ContactId][0];

        System.assertEquals(contactToAssert, contact);
    }
}