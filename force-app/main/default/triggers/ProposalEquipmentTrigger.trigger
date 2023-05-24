/**
 * @description       : This is trigger for Proposal_Equipment__c object.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger ProposalEquipmentTrigger on Proposal_Equipment__c (before insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        ProposalEquipmentTriggerHandler.setEquipmentMargin(Trigger.new);
    }
}