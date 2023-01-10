trigger ProposalEquipmentTrigger on Proposal_Equipment__c (before insert) {
    if(trigger.isInsert && trigger.isBefore){
        ProposalEquipmentTriggerHandler.setEquipmentMargin(trigger.new);
    }
}