public without sharing class ProposalEquipmentTriggerHandler {

    public static void setEquipmentMargin(List<Proposal_Equipment__c> triggerList) {
        Map<Id, Proposal_Equipment__c> mapEquipIdProposalEquip = new Map<Id, Proposal_Equipment__c>();

        for(Proposal_Equipment__c propEq :triggerList){
            mapEquipIdProposalEquip.put(propeq.Equipment__c, propEq);
        }

        List <Equipment__c> listEquip = [SELECT cost__c, Equipment_Category__r.margin__c FROM Equipment__c WHERE Id IN :mapEquipIdProposalEquip.keySet()];
        
        for(Equipment__c equip :listEquip){
            Proposal_Equipment__c propEquip = mapEquipIdProposalEquip.get(equip.Id);
            propEquip.cost__c = equip.cost__c;
            propEquip.margin__c = equip.Equipment_Category__r.margin__c;
        }
    }
}
