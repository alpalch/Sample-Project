/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public with sharing class ProposalDetailBodyController {

    @AuraEnabled(cacheable=false)
    public static void createNewProposal(List<String> equipIds, String OppId){
        // Remove duplicates in equipIds
        Set<Id> equipIdsSet = new Set<Id>();
        for(String equip: equipIds){
            equipIdsSet.add(Id.valueOf(equip));
        }

        Proposal__c proposal = new Proposal__c(
            Opportunity__c = Id.valueOf(OppId)
        );
        insert proposal;

        // Pick just created proposal. It is the last one
        List<Proposal__c> proposals = [SELECT Id FROM Proposal__c ORDER BY CreatedDate DESC LIMIT 1];
        if(!proposals.isEmpty()){
            proposal = proposals[0];
        }

        // Select all equipments in equipIds to get equipment names
        Map<Id, Equipment__c> idEquipment = new Map<Id, Equipment__c>([SELECT Id, Name FROM Equipment__c WHERE Id IN :equipIdsSet]);

        List<Proposal_Equipment__c> listToInsert = new List<Proposal_Equipment__c>();
        for(Id equipId: equipIdsSet){
            Proposal_Equipment__c propEquip = new Proposal_Equipment__c(
                Name = idEquipment.get(equipId).Name + ' ' + Date.today(),
                Proposal__c = proposal.Id,
                Equipment__c = equipId
            );
            listToInsert.add(propEquip);
        }
        insert listToInsert;
    }
}