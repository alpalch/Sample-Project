/**
 * @description       : Handler for ProposalEquipmentTrigger
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 23-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ProposalEquipmentTriggerHandler {

    public static void setEquipmentMargin(List<Proposal_Equipment__c> proposalEquipments) {
        Map<Id, Proposal_Equipment__c> proposalEquipmentByEquipId = new Map<Id, Proposal_Equipment__c>();

        for(Proposal_Equipment__c proposalEquipment :proposalEquipments){
            proposalEquipmentByEquipId.put(proposalEquipment.Equipment__c, proposalEquipment);
        }

        List <Equipment__c> equipments = [SELECT cost__c, Equipment_Category__r.margin__c 
                                          FROM Equipment__c 
                                          WHERE Id IN :proposalEquipmentByEquipId.keySet()];
        
        for(Equipment__c equipment :equipments){
            Proposal_Equipment__c proposalEquipment = proposalEquipmentByEquipId.get(equipment.Id);
            proposalEquipment.Cost__c = equipment.Cost__c;
            proposalEquipment.Margin__c = equipment.Equipment_Category__r.Margin__c;
        }
    }
}