/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 27-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ManageProposalsController {
    @AuraEnabled(cacheable=false)
    // cacheable=false to avoid DML exception
    public static Id getContentDocumentId(String proposalId) {
        Id contentDocumentId = GenerateProposal.getContentDocumentId(proposalId);
        return contentDocumentId;
    }

    @AuraEnabled(cacheable=false)
    // cacheable=false to avoid DML exception
    public static void deleteProposalDocument(String contentDocumentId) {
        List<ContentDocument> contentDocuments = [
                                                 SELECT Id 
                                                 FROM ContentDocument 
                                                 WHERE Id = :(Id)contentDocumentId 
                                                 LIMIT 1
                                                 ];
        delete contentDocuments[0];
    }

    @AuraEnabled(cacheable=true)
    public static void sendEmailWithAttachment(String contentDocumentId, String proposalId) {
        // Select recipient's email address
        List<Proposal__c> proposals = [
                                      SELECT Name, Opportunity__c 
                                      FROM Proposal__c 
                                      WHERE Id = :(Id)proposalId 
                                      LIMIT 1
                                      ];
        List<Opportunity> opprtunities = [
                                         SELECT Id 
                                         FROM Opportunity 
                                         WHERE Id = :proposals[0].Opportunity__c 
                                         LIMIT 1
                                         ];
        List<OpportunityContactRole> oppContactRoles = [
                                                       SELECT ContactId FROM OpportunityContactRole 
                                                       WHERE OpportunityId = :opprtunities[0].Id AND IsPrimary = true
                                                       LIMIT 1
                                                       ];
        List<Contact> recipients = [
                                   SELECT Email, Salutation, FirstName, LastName 
                                   FROM Contact WHERE Id = :oppContactRoles[0].ContactId
                                   ];

        // Select ContentVesion
        List<ContentDocument> contentDocuments = [
                                                 SELECT LatestPublishedVersionId 
                                                 FROM ContentDocument WHERE Id = :(Id)contentDocumentId
                                                 ];
        List<ContentVersion> contentVersions = [
                                               SELECT Title, VersionData 
                                               FROM ContentVersion 
                                               WHERE id = :contentDocuments[0].LatestPublishedVersionId
                                               ];

        String letterRecipientEmail = recipients[0].Email;
        String subject = 'Proposal ' + proposals[0].Name + ' for ' + recipients[0].Salutation + ' ' + recipients[0].FirstName + ' ' + recipients[0].LastName;
        String textBody = 'Thank you for choosing our service. Please, look at proposal in attachment';

        Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
        emailFileAttachment.setFileName(contentVersions[0].Title);
        emailFileAttachment.setContentType('application/pdf');
        emailFileAttachment.setBody(contentVersions[0].VersionData);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setPlainTextBody(textBody);
        email.setToAddresses(new String[] { letterRecipientEmail });
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { emailFileAttachment });

        Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }

    @AuraEnabled(cacheable=true)
    public static List<Equipment__c> getEquipment(String searchCategory, String searchEquipment) {
        String searchKey = '%' + searchEquipment + '%';        
        if(searchEquipment == null){
            searchKey = '%%';
        }

        List<Equipment__c> equipments = [SELECT Equipment_Category__r.Name, Name, Cost__c 
                                         FROM Equipment__c 
                                         WHERE Equipment_Category__c = :Id.valueOf(searchCategory) AND Name LIKE :searchKey
                                         ORDER BY Name ASC
                                        ];

        return equipments;
    }

    @AuraEnabled(cacheable=true)
    public static List<Equipment_Category__c> getEquipmentCategories() {
        List<Equipment_Category__c> categories= [
                                                SELECT Id, Name 
                                                FROM Equipment_Category__c
                                                ];
        return categories;
    }

    @AuraEnabled(cacheable=false)
    public static void deleteProposal(String proposalId) {
        List<Proposal__c> proposals = [
                                      SELECT Id 
                                      FROM Proposal__c 
                                      WHERE Id = :(Id)proposalId 
                                      LIMIT 1
                                      ];
        delete proposals[0];
    }
}