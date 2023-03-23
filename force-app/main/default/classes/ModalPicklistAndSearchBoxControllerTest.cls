/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class ModalPicklistAndSearchBoxControllerTest {

    @isTest
    public static void MainTest(){
        List<Equipment_Category__c> verificationData = DataFactory.createMultipleEquipmentCategory(5);
        insert verificationData;
        
        List<Equipment_Category__c> equipmentCategories = ModalPicklistAndSearchboxController.getEquipmentCategories();

        System.assertEquals(true, verificationData.size() == equipmentCategories.size());
        System.assertEquals(5, equipmentCategories.size());
    }
}