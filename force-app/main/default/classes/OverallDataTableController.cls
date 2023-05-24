/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class OverallDataTableController {

    @AuraEnabled(cacheable=true)
    public static List<Proposal> getTableData(String opportunityId) {
        List<Proposal> proposalWrappers = new List<Proposal>();
        List<Opportunity> opportunities = [SELECT Id, TotalQuantity__c, TotalCost__c, TotalPrice__c, StageName
                                           FROM Opportunity
                                           WHERE Id = :(Id)opportunityId
                                           LIMIT 1];
        List<Proposal__c> proposals = [SELECT Id, Name, Status__c, isExpandedTableRow__c,
                                         (SELECT Id, Name, Quantity__c, Cost__c, Margin__c, Price__c
                                          FROM Proposal_Equipments__r
                                          ORDER BY CreatedDate DESC)
                                       FROM Proposal__c
                                       WHERE Opportunity__c = :(Id)opportunityId
                                       ORDER BY CreatedDate DESC];
        
        // If there are no proposals, return empty list
        if(proposals.isEmpty()) {
            return proposalWrappers;
        }

        for(Proposal__c proposal :proposals) {
            Proposal proposalWrapper = new Proposal();
            List<ProposalEquipment> proposalEquipments = new List<ProposalEquipment>();

            for(Proposal_Equipment__c proposalEquipment : proposal.Proposal_Equipments__r) {
                ProposalEquipment proposalEquipmentWrapper = new ProposalEquipment();
                proposalEquipmentWrapper.proposalEquipmentId = proposalEquipment.Id;
                proposalEquipmentWrapper.proposalEquipmentName = proposalEquipment.Name;
                proposalEquipmentWrapper.proposalEquipmentQuantity = proposalEquipment.Quantity__c;
                proposalEquipmentWrapper.proposalEquipmentCost = proposalEquipment.Cost__c;
                proposalEquipmentWrapper.proposalEquipmentMargin = proposalEquipment.Margin__c;
                proposalEquipmentWrapper.proposalEquipmentPrice = proposalEquipment.Price__c;
                proposalEquipments.add(proposalEquipmentWrapper);
            }

            proposalWrapper.opportunityId = opportunities[0].Id;
            proposalWrapper.opportunityStageName = opportunities[0].StageName;
            proposalWrapper.opportunityTotalQuantity = opportunities[0].TotalQuantity__c;
            proposalWrapper.opportunityTotalCost = opportunities[0].TotalCost__c;
            proposalWrapper.opportunityTotalPrice = opportunities[0].TotalPrice__c;

            proposalWrapper.proposalId = proposal.Id;
            proposalWrapper.proposalName = proposal.Name;
            proposalWrapper.proposalStatus = proposal.Status__c;
            proposalWrapper.proposalEquipments = proposalEquipments;
            proposalWrapper.proposalIsExpanded = proposal.isExpandedTableRow__c;

            proposalWrappers.add(proposalWrapper);
        }
        return proposalWrappers;
    }

    @AuraEnabled(cacheable=false)
    public static void updateIsExpandedField(String proposalData) {
        List<Proposal> proposals = (List<Proposal>)JSON.deserialize(proposalData, List<Proposal>.class);
        List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();

        for(Proposal proposal :proposals) {
            Proposal__c proposalToUpdate = new Proposal__c();
            proposalToUpdate.Id = proposal.proposalId;
            proposalToUpdate.isExpandedTableRow__c = proposal.proposalIsExpanded;
            proposalsToUpdate.add(proposalToUpdate);
        }
        update proposalsToUpdate;
    }
}