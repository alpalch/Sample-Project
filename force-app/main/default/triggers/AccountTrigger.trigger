trigger AccountTrigger on Account (before insert, after insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        AccountTriggerHandler.setShippingAddress(trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        AccountTriggerHandler.setAccountShippingState(trigger.new);
    }
}