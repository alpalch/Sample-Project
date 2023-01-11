@isTest
public with sharing class RenderProposalAsPdfControllerTest {
    
    @isTest
    public static void getProposalEquipmentSuccessTest(){
        Proposal_Equipment__c proposalEquipment = DataFactory.createProposalEquipment();
        insert proposalEquipment;
        String currentProposalId = String.valueOf(proposalEquipment.Proposal__c);

        RenderProposalAsPdfController prAsPdf = new RenderProposalAsPdfController();
        

        List<Map<String, String>> listToAssert = RenderProposalAsPdfController.getProposalEquipment();

        System.assertEquals('Test', listToAssert[0].get('equipmentName'));
    }
}
