/**
 * @description       : This is trigger for Opportunity object
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 28-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger OpportunityTrigger on Opportunity (after insert, before update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityTriggerHandler.setPrimaryContact(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.updateChangedFields(Trigger.new, Trigger.old);
    }

}