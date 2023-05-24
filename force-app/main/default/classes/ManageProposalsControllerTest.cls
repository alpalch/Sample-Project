/**
 * @description       : Test class for ManageProposalsController
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class ManageProposalsControllerTest {

    @isTest
    public static void getContentDocumentIdTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];

        //When
        Test.startTest();
        String contentDocumentId = ManageProposalsController.getContentDocumentId((String)proposal.Id);
        Test.stopTest();

        //Then
        System.assert(contentDocumentId != null);
    }

    @isTest
    public static void deleteProposalDocumentTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];
        String contentDocumentId = ManageProposalsController.getContentDocumentId((String)proposal.Id);

        //When
        Test.startTest();
        ManageProposalsController.deleteProposalDocument(contentDocumentId);
        Test.stopTest();

        //Then
        List<ContentDocument> contentDocuments = [
                                                 SELECT Id 
                                                 FROM ContentDocument 
                                                 WHERE Id = :(Id)contentDocumentId 
                                                 LIMIT 1
                                                 ];
        System.assert(contentDocuments.isEmpty());
    }

    @isTest
    public static void getEquipmentTestEmptyEquipment() {
        //Given
        List<Equipment__c> equipments = TestDataFactory.createEquipments(10, true);

        Test.startTest();
        List<Equipment__c> result = ManageProposalsController.getEquipment((String)equipments[0].Equipment_Category__c, null);
        Test.stopTest();

        //Then
        System.assertEquals(10, result.size());
    }

    @isTest
    public static void getEquipmentTest() {
        //Given
        List<Equipment__c> equipments = TestDataFactory.createEquipments(10, true);

        Test.startTest();
        List<Equipment__c> result = ManageProposalsController.getEquipment((String)equipments[0].Equipment_Category__c, 'Test');
        Test.stopTest();

        //Then
        System.assertEquals(10, result.size());
    }

    @isTest
    public static void getEquipmentCategoriesTest() {
        //Given
        List<Equipment__c> equipments = TestDataFactory.createEquipments(10, true);

        Test.startTest();
        List<Equipment_Category__c> result = ManageProposalsController.getEquipmentCategories();
        Test.stopTest();

        //Then
        System.assertEquals(1, result.size());
    }

    @isTest
    public static void deleteProposalTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];

        //When
        Test.startTest();
        ManageProposalsController.deleteProposal((String)proposal.Id);
        Test.stopTest();

        //Then
        List<Proposal__c> proposals = [
                                        SELECT Id 
                                        FROM Proposal__c 
                                        WHERE Id = :(Id)proposal.Id 
                                        LIMIT 1
                                        ];
        System.assert(proposals.isEmpty());
    }

    @isTest
    public static void sendEmailWithAttachmentTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];
        Contact contact = TestDataFactory.createContacts(1, false)[0];
        contact.AccountId = proposal.Opportunity__r.AccountId;
        insert contact;
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
            OpportunityId = proposal.Opportunity__c, 
            ContactId = contact.Id, 
            isPrimary = true
            );
        insert opportunityContactRole;
        String contentDocumentId = ManageProposalsController.getContentDocumentId((String)proposal.Id);

        //When
        Test.startTest();
        ManageProposalsController.sendEmailWithAttachment(contentDocumentId, (String)proposal.Id);
        Test.stopTest();

        //Then
        List<Proposal__c> proposals = [
                                        SELECT Id, Name, Status__c 
                                        FROM Proposal__c 
                                        WHERE Id = :(Id)proposal.Id 
                                        LIMIT 1
                                        ];
        String subject = '%Proposal ' + proposals[0].Name + '%';
        List<EmailMessage> emailMessages = [
                                            SELECT Id 
                                            FROM EmailMessage 
                                            WHERE Name LIKE :subject
                                            LIMIT 1
                                            ];
        System.assert(!emailMessages.isEmpty());
    }

    @isTest
    public static void createProposalWithDescriptionTest() {
        //Given
        Opportunity opportunity = TestDataFactory.createOpportunities(1, true)[0];
        Map<String, String> proposalData= new Map<String, String>();
        proposalData.put('internalMessage', 'Test Internal Message');
        proposalData.put('opportunityId', (String)opportunity.Id);
        proposalData.put('note', 'Test Note');

        //When
        Test.startTest();
        ManageProposalsController.createProposalWithDescription(proposalData);
        Test.stopTest();

        //Then
        List<Proposal__c> proposals = [
                                        SELECT Id, Internal_Message__c, Note__c 
                                        FROM Proposal__c 
                                        WHERE Opportunity__c = :(Id)opportunity.Id 
                                        LIMIT 1
                                        ];
        System.assert(proposals[0].Internal_Message__c == 'Test Internal Message');
        System.assert(proposals[0].Note__c == 'Test Note');
    }

    @isTest
    public static void getProposalTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, true)[0];

        //When
        Test.startTest();
        Proposal__c result = ManageProposalsController.getProposal((String)proposal.Id);
        Test.stopTest();

        //Then
        System.assertEquals(proposal.Id, result.Id);
    }

    @isTest
    public static void editProposalWithAttachmentTest() {
        //Given
        Proposal__c proposal = TestDataFactory.createProposals(1, false)[0];
        proposal.Note__c = 'Test Note';
        proposal.Internal_Message__c = 'Test Internal Message';
        insert proposal;
        Map<String, String> proposalData= new Map<String, String>();
        proposalData.put('internalMessage', 'New Test Internal Message');
        proposalData.put('note', 'New Test Note');
        proposalData.put('Id', (String)proposal.Id);

        //When
        Test.startTest();
        ManageProposalsController.editProposalWithAttachment(proposalData);
        Test.stopTest();

        //Then
        List<Proposal__c> proposals = [
                                        SELECT Id, Internal_Message__c, Note__c 
                                        FROM Proposal__c 
                                        WHERE Id = :(Id)proposal.Id 
                                        LIMIT 1
                                        ];
        System.assert(proposals[0].Internal_Message__c == 'New Test Internal Message');
        System.assert(proposals[0].Note__c == 'New Test Note');
    } 
}