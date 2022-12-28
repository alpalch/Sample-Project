public with sharing class ProposalDatatableController {
    @AuraEnabled(cacheable=true)

    public static List<Proposal__c> getProposals(String oppId){
        return [SELECT id, Name, Total_Price__c, Real_Margin__c, Status__c FROM Proposal__c WHERE Opportunity__c = :Id.valueOf(oppId)];
    }
}
