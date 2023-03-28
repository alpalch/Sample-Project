/**
 * @description       : This is a class for generating Proposal__c as PDF and saving it as ContentDocumentLink
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 28-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public with sharing class GenerateProposal {

    public static Proposal__c proposalForView = new Proposal__c();

    public static Id getContentDocumentId(String proposalId) {
        List<Proposal__c> proposals = [
                                      SELECT Id, Opportunity__c, LastAccessDateTime__c 
                                      FROM Proposal__c 
                                      WHERE Id = :(Id)proposalId
                                      ];
        proposalForView = proposals[0];

        // Updating LastAccessDateTime to pick this exact Proposal__c in ProposalAsPdfController
        proposalForView.LastAccessDateTime__c = Datetime.now();
        update proposalForView;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink = createContentDocumentLink(proposalId);
        return contentDocumentLink.ContentDocumentId;
    }

    public static ContentDocumentLink createContentDocumentLink(String proposalId) {
        Account account = getProposalAccount();
        Blob body;
        PageReference pageRef = new PageReference('/apex/ProposalAsPdf');
        pageRef.getParameters().put('proposalId', proposalId );
        if(Test.isRunningTest()) { 
            body = blob.valueOf('Unit.Test');
          } else {
            body = pageRef.getContentAsPDF();
          }

        ContentVersion contentVersion = new contentVersion(
            Title = account.Name + ' proposal ' + Date.today(),
            PathOnClient = account.Name + ' proposal.pdf',
            VersionData = body
        );
        insert contentVersion;

        Id contentVersionId = contentVersion.Id;
        ContentDocument contentDocument = [
                                          SELECT Id 
                                          FROM ContentDocument 
                                          WHERE LatestPublishedVersionId = :contentVersionId
                                          ];
         //ShareType: V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        ContentDocumentLink contentDocumentLink = new contentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = proposalForView.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
        return contentDocumentLink;
    }

    

    public static Account getProposalAccount() {
        List<Opportunity> opportunities = [
                                          SELECT AccountId 
                                          FROM Opportunity 
                                          WHERE Id = :proposalForView.Opportunity__c
                                          ];
        List<Account> accounts = [
                                 SELECT Name 
                                 FROM Account 
                                 WHERE Id = :opportunities[0].AccountId
                                 ];
        return accounts[0];
    }
}