/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger ProposalEquipmentTrigger on Proposal_Equipment__c (before insert) {
    if(trigger.isInsert && trigger.isBefore) {
        ProposalEquipmentTriggerHandler.setEquipmentMargin(Trigger.new);
    }
}