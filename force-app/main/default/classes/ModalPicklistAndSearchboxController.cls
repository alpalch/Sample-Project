public with sharing class ModalPicklistAndSearchboxController {
    @AuraEnabled(cacheable=true)
    
    public static List<Equipment_Category__c> getEquipmentCategories(){
        return [SELECT Id, Name FROM Equipment_Category__c];
    }
}
