@isTest
public with sharing class ModalPicklistAndSearchBoxControllerTest {

    @isTest
    public static void MainTest(){
        List<Equipment_Category__c> listEQ = DataFactory.createMultipleEquipmentCategory(5);
        insert listEQ;
        List<Equipment_Category__c> listEQ1 = ModalPicklistAndSearchboxController.getEquipmentCategories();
        System.assertEquals(true, listEQ.size() == listEQ1.size());
        System.assertEquals(5, listEQ1.size());
    }
}
