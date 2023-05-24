/**
 * @description       : This is a trigger for Account object.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
trigger AccountTrigger on Account (before insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        AccountTriggerHandler.setShippingAddress(trigger.new);
    }
}