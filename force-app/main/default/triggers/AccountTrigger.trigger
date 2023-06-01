/**
 * @description       : This is a trigger for Account object.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 29-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger AccountTrigger on Account (before insert, before update, after delete) {

    if(Trigger.isBefore) {
        if(Trigger.isInsert || Trigger.isUpdate){
            AccountTriggerHandler.setShippingAddress(Trigger.new);
        }
    }

    if(Trigger.isAfter) {
        if(Trigger.isDelete) {
            AccountTriggerHandler.makeMergedJson(Trigger.old);
        }
    }
}