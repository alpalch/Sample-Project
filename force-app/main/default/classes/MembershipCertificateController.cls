/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class MembershipCertificateController {

    @AuraEnabled
    public static String createMembership(String contactId) {
        String returnString = '';

        try {
            saveSertificateInDropbox((Id)contactId);
            sendEmailWithAttachment((Id)contactId);
            returnString = 'Success';
        } catch(CustomException e) {
            logError(contactId, e.getMessage(), e.getStackTraceString()); // log the error
            deleteMembershipCertificateInDropbox((Id)contactId); // delete certificate in Dropbox
            returnString = 'Error';
        }
        return returnString;
    }

    @AuraEnabled
    public static Id createCertificate(String contactId) {
        List<Contact> contacts = [SELECT Id, Name, Email
                                  FROM Contact
                                  WHERE Id = :(Id)contactId];
        Contact contact = contacts[0];

        Blob body;
        PageReference pageRef = new PageReference('/apex/MembershipCertificate');
        pageRef.getParameters().put('Id', contact.Id);

        if(Test.isRunningTest()) {
            body = Blob.valueOf('Unit.Test');
        } else {
            body = pageRef.getContentAsPDF();
        }

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Membership Certificate: ' + contact.Name,
            PathOnClient = 'Membership Certificate: ' + contact.Name + '.pdf',
            VersionData = body
        );
        insert contentVersion;

        Id contentVersionId = contentVersion.Id;
        ContentDocument contentDocument = [SELECT Id
                                           FROM ContentDocument
                                           WHERE LatestPublishedVersionId = :contentVersionId];

        //ShareType: V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = contact.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
        return contentDocumentLink.contentDocumentId;  
    }

    private static void sendEmailWithAttachment(String contactId) {
        Id contentDocumentId = createCertificate((Id)contactId);

        List<Contact> contacts = [SELECT Id, Name, Email
                                  FROM Contact
                                  WHERE Id = :(Id)contactId];
        Contact contact = contacts[0];

        // Select Content Version
        List<ContentDocument> contentDocuments = [SELECT LatestPublishedVersionId
                                                 FROM ContentDocument
                                                 WHERE Id = :(Id)ContentDocumentId];

        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData
                                                FROM ContentVersion
                                                WHERE Id = :contentDocuments[0].LatestPublishedVersionId];
        
        // Send Email
        String letterRecipientEmail = contact.Email;
        String letterSubject = 'Your membership successfuly created';
        String letterBody = 'Your membership successfuly created. See details in the attachment.';

        Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();
        emailFileAttachment.setFileName(contentVersions[0].Title);
        emailFileAttachment.setContentType('application/pdf');
        emailFileAttachment.setBody(contentVersions[0].VersionData);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(letterSubject);
        email.setPlainTextBody(letterBody);
        email.setToAddresses(new String[] { letterRecipientEmail });
        email.setReplyTo('alpalch@gmail.com');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { emailFileAttachment });

        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch(EmailException e) {
            throw new CustomException('Email error: ' + e.getMessage());
        } 
    }

    private static void saveSertificateInDropbox(Id contactId) {
        List<Contact> contacts = [SELECT Id, Name, Email, Account.Name
                                  FROM Contact
                                  WHERE Id = :contactId];
        Contact contact = contacts[0];

        String contentVersionTitle = 'Membership Certificate: ' + contact.Name;
        List<ContentVersion> contentVersions = [SELECT Id, Title, VersionData
                                                FROM ContentVersion
                                                WHERE Title = :contentVersionTitle]; 

        if(contentVersions.isEmpty()) { //avoid duplicate api error
            Blob requestBody;
            PageReference pageRef = new PageReference('/apex/MembershipCertificate');
            pageRef.getParameters().put('Id', contact.Id);
            if(Test.isRunningTest()) {
                requestBody = Blob.valueOf('Unit.Test');
            } else {
                requestBody = pageRef.getContentAsPDF();
            }
            String dropboxAPIArg = '{"path": "/' + contact.Account.Name + ' ' +contact.Name + '/' + 'Membership Certificate: ' + contact.Name + '.pdf", "mode": "add", "autorename": false, "mute": false, "strict_conflict": false}';

            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:ContentDropboxApi/2/files/upload');
            request.setHeader('Content-Type', 'application/octet-stream');
            request.setHeader('Dropbox-API-Arg', dropboxAPIArg);
            request.setMethod('POST');
            request.setBodyAsBlob(requestBody);

            Http http = new Http();
            HttpResponse response = http.send(request);
            if(response.getStatusCode() != 200) {
                throw new CustomException('Dropbox API error: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
            }
        }   
    }

    @future(callout=true)
    private static void logError(Id recordId, String errorBody, String stackTrace) {
        Error__c error = new Error__c();
        
        if(errorBody.contains('Dropbox API error:')) { //dropbox api error
            error.Status__c = errorBody.substring(23, errorBody.indexOf('{') - 1);
            error.StatusCode__c = errorBody.substring(19, 22);
            error.ErrorType__c = 'Dropbox API error';
            error.ErrorBody__c = errorBody.substring(errorBody.indexOf('{'));
        } else { //other errors
            error.ErrorType__c = errorBody.substring(0, errorBody.indexOf(':'));
            error.ErrorBody__c = errorBody.substring(errorBody.indexOf(':') + 2);
        }
        error.recordId__c = recordId;
        error.StackTrace__c = stackTrace;
        
        insert error;
    }

    @future(callout=true)
    private static void deleteMembershipCertificateInDropbox(Id contactId) {
        List<Contact> contacts = [SELECT Id, Name, Email, Account.Name
                                  FROM Contact
                                  WHERE Id = :contactId];
        Contact contact = contacts[0];

        String data = '{"path": "/' + contact.Account.Name + ' ' +contact.Name + '/' + 'Membership Certificate: ' + contact.Name + '.pdf" }';
                                                
        HttpRequest request = new HttpRequest();                                     
        request.setEndpoint('callout:ApiDropboxApi/2/files/delete_v2');                                                                                
        request.setHeader('Content-Type', 'application/json');                                      
        request.setMethod('POST');
        request.setBody(data);
                                                
        Http http = new Http();
        HttpResponse response = http.send(request);
    }
}