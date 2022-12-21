public with sharing class ProposalDetailBodyController {
    @AuraEnabled(cacheable=true)

    public static List<Proposal__c> getProposals(String oppId){
        return [SELECT Name, Total_Price__c, Real_Margin__c, Status__c FROM Proposal__c WHERE Opportunity__c = :Id.valueOf(oppId)];
    }
}
