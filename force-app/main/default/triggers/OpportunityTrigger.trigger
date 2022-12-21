trigger OpportunityTrigger on Opportunity (after insert, before update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityTriggerHandler.setPrimaryContact(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.setClosedDateToday(Trigger.new, Trigger.old);
        OpportunityTriggerHandler.setActualAmount(Trigger.new);
    }

}