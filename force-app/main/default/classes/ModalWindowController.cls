/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public with sharing class ModalWindowController {

    @AuraEnabled(cacheable=true)
    public static List<Equipment__c> getEquipment(String searchCategory, String searchEquipment){
        String searchKey = '%' + searchEquipment + '%';
        
        if(searchEquipment == 'undefined'){
            searchKey = '%%';
        }

        return [
            SELECT Equipment_Category__r.Name, Name, Cost__c 
            FROM Equipment__c 
            WHERE Equipment_Category__c = :Id.valueOf(searchCategory) AND Name LIKE :searchKey];
    }
}