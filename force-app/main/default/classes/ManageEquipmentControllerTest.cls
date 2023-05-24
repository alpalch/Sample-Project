/**
 * @description       : This is a test class for ManageEquipmentController
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 13-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class ManageEquipmentControllerTest {

    @isTest
    public static void getEquipmentCategoriesTest() {
        // Given
        List<Equipment_Category__c> equipmentCategories = TestDataFactory.createEquipmentCategories(5, true);

        // When
        Test.startTest();
        List<Equipment_Category__c> resultJSON = ManageEquipmentController.getEquipmentCategories();
        Test.stopTest();

        // Then
        System.assertEquals(equipmentCategories.size(), resultJSON.size());
    }

    @isTest
    public static void getEquipmentsTest() {
        //Given
        List<Equipment__c> equipments = TestDataFactory.createEquipments(5, true);

        //When
        Test.startTest();
        List<ProposalEquipment> result1 = ManageEquipmentController.getEquipments(null, 'Te');
        List<ProposalEquipment> result2 = ManageEquipmentController.getEquipments((String)equipments[0].Equipment_Category__c, null);
        List<ProposalEquipment> result3 = ManageEquipmentController.getEquipments((String)equipments[0].Equipment_Category__c, 'Hammer');
        Test.stopTest();

        //Then
        System.assertEquals(5, result1.size());
        System.assertEquals(5, result2.size());
        System.assertEquals(0, result3.size());
    }

    @isTest
    public static void getEquipmentDetailsTest() {
        //Given
        List<Equipment__c> equipments = TestDataFactory.createEquipments(1, true);

        //When
        Test.startTest();
        ProposalEquipment resultJSON = ManageEquipmentController.getEquipmentDetails((String)equipments[0].Id);
        Test.stopTest();

        //Then
        System.assertEquals(equipments[0].Name, resultJSON.equipmentName);
        System.assertEquals(equipments[0].Description__c, resultJSON.equipmentDescription);
    }

    @isTest
    public static void createProposalEquipmentTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];
        Equipment__c equipment = TestDataFactory.createEquipments(1, true)[0];
        Map<String, String> proposalEquipmentDataMap = new Map<String, String>();
        proposalEquipmentDataMap.put('equipmentName', 'Test Equipment');
        proposalEquipmentDataMap.put('equipmentId', (String)equipment.Id);
        proposalEquipmentDataMap.put('proposalEquipmentQuantity', '1');
        String proposalEquipmentData = JSON.serialize(proposalEquipmentDataMap);

        //When
        Test.startTest();
        ManageEquipmentController.createProposalEquipment(proposalEquipmentData, (String)proposal.Id);
        Test.stopTest();

        //Then
        List<Proposal_Equipment__c> proposalEquipments = [SELECT Id FROM Proposal_Equipment__c WHERE Proposal__c = :proposal.Id];
        System.assertEquals(1, proposalEquipments.size());
    }

    @isTest
    public static void deleteProposalEquipmentTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];
        Equipment__c equipment = TestDataFactory.createEquipments(1, true)[0];
        Proposal_Equipment__c proposalEquipment = new Proposal_Equipment__c(
            Proposal__c = proposal.Id,
            Equipment__c = equipment.Id,
            Quantity__c = 1
        );
        insert proposalEquipment;

        //When
        Test.startTest();
        ManageEquipmentController.deleteProposalEquipment((String)proposalEquipment.Id);
        Test.stopTest();

        //Then
        List<Proposal_Equipment__c> proposalEquipments = [SELECT Id FROM Proposal_Equipment__c WHERE Proposal__c = :proposal.Id];
        System.assertEquals(0, proposalEquipments.size());
    }

    @isTest
    public static void getEquipmentsForProposalTest() {
        //Given
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(5, true);

        //When
        Test.startTest();
        String resultJSON = ManageEquipmentController.getEquipmentsForProposal((String)proposalEquipments[0].Proposal__c);
        Test.stopTest();

        //Then
        List<ProposalEquipment> resultList = (List<ProposalEquipment>)JSON.deserialize(resultJSON, List<ProposalEquipment>.class);
        System.assertEquals(5, resultList.size());
    }

    @isTest
    public static void massMarginUpdateTest() {
        //Given
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(5, true);
        List<ProposalEquipment> proposalEquipmentWrappers = new List<ProposalEquipment>();
        for (Proposal_Equipment__c proposalEquipment : proposalEquipments) {
            ProposalEquipment proposalEquipmentWrapper = new ProposalEquipment();
            proposalEquipmentWrapper.proposalEquipmentId = (String)proposalEquipment.Id;
            proposalEquipmentWrapper.proposalEquipmentMargin = 10;
            proposalEquipmentWrappers.add(proposalEquipmentWrapper);
        }

        //When
        Test.startTest();
        ManageEquipmentController.massMarginUpdate(JSON.serialize(proposalEquipmentWrappers));
        Test.stopTest();

        //Then
        List<Proposal_Equipment__c> proposalEquipmentsAfterUpdate = [SELECT Id, Margin__c FROM Proposal_Equipment__c WHERE Id IN :proposalEquipments];
        for (Proposal_Equipment__c proposalEquipment : proposalEquipmentsAfterUpdate) {
            System.assertEquals(10, proposalEquipment.Margin__c);
        }
    }

    @isTest
    public static void updateProposalEquipmentsTest() {
        //Given
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(1, true);
        List<ProposalEquipment> proposalEquipmentWrappers = new List<ProposalEquipment>();
        for(Proposal_Equipment__c proposalEquipment :proposalEquipments) {
            ProposalEquipment proposalEquipmentWrapper = new ProposalEquipment();
            proposalEquipmentWrapper.proposalEquipmentId = (String)proposalEquipment.Id;
            proposalEquipmentWrapper.proposalEquipmentQuantity = 10;
            proposalEquipmentWrappers.add(proposalEquipmentWrapper);
        }

        //When
        Test.startTest();
        ManageEquipmentController.updateProposalEquipments(JSON.serialize(proposalEquipmentWrappers));
        Test.stopTest();

        //Then
        List<Proposal_Equipment__c> proposalEquipmentsAfterUpdate = [SELECT Id, Quantity__c FROM Proposal_Equipment__c WHERE Id IN :proposalEquipments];
        for (Proposal_Equipment__c proposalEquipment : proposalEquipmentsAfterUpdate) {
            System.assertEquals(10, proposalEquipment.Quantity__c);
        }
    }
}