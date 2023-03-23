/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class ModalWindowControllerTest {
    
    @isTest
    public static void SuccessTest1(){
        Equipment__c equip = DataFactory.createEquipment();
        insert equip;
        List<Equipment__c> listToAssert = ModalWindowController.getEquipment(String.valueOf(equip.Equipment_Category__c), 'Test');
        System.assertEquals(1, listToAssert.size());
    }

    @isTest
    public static void SuccessTest2(){
        Equipment__c equip = DataFactory.createEquipment();
        insert equip;
        List<Equipment__c> listToAssert = ModalWindowController.getEquipment(String.valueOf(equip.Equipment_Category__c), 'undefined');
        System.assertEquals(1, listToAssert.size());
    }
}