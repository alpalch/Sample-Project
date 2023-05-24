/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 26-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ContactTriggerHandler {
    
    public static void afterUpdate(List<Contact> oldContacts, List<Contact> newContacts) {
        cancelMembership(oldContacts, newContacts);
    }

    private static void cancelMembership(List<Contact> oldContacts, List<Contact> newContacts) {
        for(Contact oldContact :oldContacts) {
            for(Contact newContact :newContacts) {
                if(oldContact.Status__c != newContact.Status__c && newContact.Status__c == 'Inactive') {
                    sendEmailNotification(newContact.Id);
                }
            }
        }
    }

    @future(callout=true)
    private static void sendEmailNotification(Id contactId) {
        List<Contact> contacts = [SELECT Id, Name, Email
                                  FROM Contact
                                  WHERE Id = :contactId];
        Contact contact = contacts[0];
        
        // Send Email
        String letterRecipientEmail = contact.Email;
        String letterSubject = 'Your membership has been expired';
        String letterBody = 'Your membership has been expired. Thank you for your membership.';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(letterSubject);
        email.setPlainTextBody(letterBody);
        email.setToAddresses(new String[] { letterRecipientEmail });
        email.setReplyTo('alpalch@gmail.com');

        try{
            deleteMembershipCertificateInDropbox(contactId);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        catch(CustomException e) {
            logError(contactId, e.getMessage(), e.getStackTraceString());
        }
    }

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
        if(response.getStatusCode() != 200) {
            throw new CustomException('Dropbox API error: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());
        }
    }

    private static void logError(Id recordId, String errorBody, String stackTrace) {
        Error__c error = new Error__c();
        if(errorBody.contains('Dropbox API error:')) { //dropbox api error
            error.Status__c = errorBody.substring(23, errorBody.indexOf('{') - 1);
            error.StatusCode__c = errorBody.substring(19, 22);
            error.ErrorType__c = 'Dropbox API error';
            error.ErrorBody__c = errorBody.substring(errorBody.indexOf('{'));
        } 
        else { //other errors
            error.ErrorType__c = errorBody.substring(0, errorBody.indexOf(':'));
            error.ErrorBody__c = errorBody.substring(errorBody.indexOf(':') + 2);
        }
        error.recordId__c = recordId;
        error.StackTrace__c = stackTrace;
        
        insert error;
    }
}