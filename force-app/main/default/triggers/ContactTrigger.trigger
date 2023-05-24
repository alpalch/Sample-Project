/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger ContactTrigger on Contact (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        ContactTriggerHandler.afterUpdate(Trigger.old, Trigger.new);
    }
}