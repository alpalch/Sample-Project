/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public class ProposalEquipmentTriggerHandlerTest {
    @isTest
    public static void mainTest(){
        List<Proposal_Equipment__c> propEquipBefore = DataFactory.propEquipForProposalEquipmentHandler(1);

        insert propEquipBefore;

        List<Proposal_Equipment__c> propEquipAfter = [SELECT cost__c, margin__c FROM Proposal_Equipment__c WHERE Id = :propEquipBefore[0].Id];

        System.assertEquals(10, propEquipAfter[0].cost__c);
        System.assertEquals(10, propEquipAfter[0].margin__c);
    }
}