/**
 * @description       : This is a trigger for Account object.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 28-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger AccountTrigger on Account (before insert, after insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        AccountTriggerHandler.setShippingAddress(trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        AccountTriggerHandler.setAccountShippingState(trigger.new);
    }
}