/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public with sharing class PreviewModalControllerTest {
    
    @isTest
    public static void getContentDocumentIdSuccessTest(){
        Proposal__c prop = DataFactory.createProposal();
        insert prop;
        Id idToAssert = PreviewModalController.getContentDocumentId(prop.Id);

        System.assertEquals(false, String.isBlank(String.valueOf(idToAssert)));
    }

    @isTest
    public static void closePreviewSuccessTest(){
        Proposal__c prop = DataFactory.createProposal();
        insert prop;
        Id contentDocumentId = PreviewModalController.getContentDocumentId(prop.Id);

        List<ContentDocument> listContentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
        if(!listContentDocument.isEmpty()){
            PreviewModalController.closePreview(contentDocumentId);  
        }
        List<ContentDocument> listToAssert = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];

        System.assertEquals(0, listToAssert.size());
    }
}