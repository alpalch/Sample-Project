/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ProposalEquipmentTriggerHandler {

    public static void setEquipmentMargin(List<Proposal_Equipment__c> triggerList) {
        Map<Id, Proposal_Equipment__c> equipIdProposalEquipment = new Map<Id, Proposal_Equipment__c>();

        for(Proposal_Equipment__c propEq :triggerList){
            equipIdProposalEquipment.put(propeq.Equipment__c, propEq);
        }

        List <Equipment__c> listEquip = [SELECT cost__c, Equipment_Category__r.margin__c FROM Equipment__c WHERE Id IN :equipIdProposalEquipment.keySet()];
        
        for(Equipment__c equip :listEquip){
            Proposal_Equipment__c propEquip = equipIdProposalEquipment.get(equip.Id);
            propEquip.cost__c = equip.cost__c;
            propEquip.margin__c = equip.Equipment_Category__r.margin__c;
        }
    }
}