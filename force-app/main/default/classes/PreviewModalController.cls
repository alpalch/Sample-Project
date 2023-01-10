public with sharing class PreviewModalController {
    @AuraEnabled(cacheable=false)
    public static Id getContentDocumentId(String proposalId){
        Id pdfDocumentId = SaveDocument.getContentDocumentId(proposalId);
        return pdfDocumentId;
    }

    @AuraEnabled(cacheable=false)
    public static void closePreview(String contentDocumentId){
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :Id.ValueOf(contentDocumentId)][0];
        delete contentDocument;
    }

    @AuraEnabled(cacheable=true)
    public static void sendEmailWithAttachment(String contentDocumentId, String proposalId){
        // Select recipient's email address
        Proposal__c proposal = [SELECT Name, Opportunity__c FROM Proposal__c WHERE Id = :Id.ValueOf(proposalId)][0];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :proposal.Opportunity__c][0];
        OpportunityContactRole ocr = [
            SELECT ContactId FROM OpportunityContactRole 
            WHERE OpportunityId = :opp.Id AND IsPrimary = true][0];
        Contact recipient = [SELECT Email, Salutation, FirstName, LastName FROM Contact WHERE Id = :ocr.ContactId][0];

        // Select ContentVesion
        ContentDocument contentDocument = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentDocumentId][0];
        ContentVersion contentVersion = [SELECT Title, VersionData FROM ContentVersion WHERE id = :contentDocument.LatestPublishedVersionId][0];

        String letterRecipientEmail = recipient.Email;
        String subject = 'Proposal ' + proposal.Name + ' for ' + recipient.Salutation + ' ' + recipient.FirstName + ' ' + recipient.LastName;
        String textBody = 'Thank you for choosing our service. Please, look at proposal in attachment';

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(contentVersion.Title);
        efa.setContentType('application/pdf');
        efa.setBody(contentVersion.VersionData);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setPlainTextBody(textBody);
        email.setToAddresses(new String[] {letterRecipientEmail});
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}
