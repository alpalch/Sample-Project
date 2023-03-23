/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public with sharing class GenerateProposal {
    public static Proposal__c proposalForView = new Proposal__c();

    public static Id makeContentVersion(String proposalId){
        Account account = getProposalAccount();
        Blob body;
        PageReference pageRef = new PageReference('/apex/RenderProposalAsPdf');
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
        return contentVersion.Id;
    }

    public static ContentDocumentLink createContentDocumentLink(String proposalId){
        Id contentVersionId = makeContentVersion(proposalId);
        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :contentVersionId];
         //ShareType: V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        ContentDocumentLink contentDocumentLink = new contentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = proposalForView.Id,
            ShareType = 'V'
        );
        insert contentDocumentLink;
        return contentDocumentLink;
    }

    public static Id getContentDocumentId(String proposalId){
        proposalForView = [SELECT Id, Opportunity__c, LastAccessDateTime__c FROM Proposal__c WHERE Id = :Id.valueOf(proposalId)][0];

        // Updating LastAccessDateTime to pick this exact Proposal__c in RenderProposalAsPdfController
        proposalForView.LastAccessDateTime__c = Datetime.now();
        update proposalForView;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl = createContentDocumentLink(proposalId);
        return cdl.ContentDocumentId;
    }

    public static Account getProposalAccount(){
        List<Opportunity> listOpp = [SELECT AccountId FROM Opportunity WHERE Id = :proposalForView.Opportunity__c];
        return [SELECT Name FROM Account WHERE Id = :listOpp[0].AccountId][0];
    }
}