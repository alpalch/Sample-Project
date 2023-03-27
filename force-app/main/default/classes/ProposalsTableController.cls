/**
 * @description       : This is a controller for ProposalsTable component
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 27-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public with sharing class ProposalsTableController {

    @AuraEnabled(cacheable=true)
    public static List<Proposal__c> getProposals(String opportunityId) {
        List<Proposal__c> proposals = [
                                      SELECT id, Name, Total_Price__c, Real_Margin__c, Status__c 
                                      FROM Proposal__c 
                                      WHERE Opportunity__c = :(Id)opportunityId
                                      ];
        return proposals;
    }

    @AuraEnabled(cacheable=false)
    public static void createProposal(List<String> equipmentIds, String opportunityId) {
        Proposal__c proposal = new Proposal__c(
            Opportunity__c = (Id)opportunityId
        );
        insert proposal;

        // Select all equipments in equipmentIds to get equipment names
        List<Equipment__c> equipments = new List<Equipment__c>([
                                                                SELECT Id, Name 
                                                                FROM Equipment__c
                                                                WHERE Id IN :(List<Id>)equipmentIds
                                                                ]);

        List<Proposal_Equipment__c> proposalEquipmentsToInsert = new List<Proposal_Equipment__c>();
        for(Equipment__c equipment: equipments) {
            Proposal_Equipment__c proposalEquipment = new Proposal_Equipment__c(
                Name = equipment.Name + ' ' + Date.today(),
                Proposal__c = proposal.Id,
                Equipment__c = equipment.Id
            );
            proposalEquipmentsToInsert.add(proposalEquipment);
        }
        insert proposalEquipmentsToInsert;
    }
}