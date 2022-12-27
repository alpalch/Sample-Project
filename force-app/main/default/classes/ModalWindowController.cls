public with sharing class ModalWindowController {
    @AuraEnabled(cacheable=true)
    public static List<Equipment__c> getEquipment(String searchCategory, String searchEquipment){
        String key = '%' + searchEquipment + '%';
        if(searchEquipment == 'undefined'){
            key = '%%';
        }
        return [
            SELECT Equipment_Category__r.Name, Name, Cost__c 
            FROM Equipment__c 
            WHERE Equipment_Category__c = :Id.valueOf(searchCategory) AND Name LIKE :key];
    }
}
