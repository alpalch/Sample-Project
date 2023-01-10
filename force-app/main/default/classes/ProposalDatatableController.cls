public with sharing class ProposalDatatableController {

    @AuraEnabled(cacheable=true)
    public static List<Proposal__c> getProposals(String oppId){
        return [SELECT id, Name, Total_Price__c, Real_Margin__c, Status__c FROM Proposal__c WHERE Opportunity__c = :Id.valueOf(oppId)];
    }

    @AuraEnabled(cacheable=false)
    public static void deleteProposal(String proposalId){
        Proposal__c proposal = [SELECT Id FROM Proposal__c WHERE Id = :Id.valueOf(proposalId)][0];
        delete proposal;
    }
}
