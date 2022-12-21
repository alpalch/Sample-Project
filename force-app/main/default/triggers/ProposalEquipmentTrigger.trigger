trigger ProposalEquipmentTrigger on Proposal_Equipment__c (before insert) {
    if(trigger.isInsert && trigger.isBefore){
        ProposalEquipmentHandler.setEquipmentMargin(trigger.new);
    }
}