/**
 * @description       : Test class for ProposalEquipmentTriggerHandler
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public class ProposalEquipmentTriggerHandlerTest {

    @isTest
    public static void mainTest() {
        //Given
        List<Proposal_Equipment__c> proposalEquipmentBeforeTrigger = TestDataFactory.dataForProposalEquipmentTriggerHandlerTest(1);

        //When
        Test.startTest();
        insert proposalEquipmentBeforeTrigger;
        Test.stopTest();

        //Then
        List<Proposal_Equipment__c> proposalEquipmentAfterTrigger = [
                                                                    SELECT Cost__c, Margin__c 
                                                                    FROM Proposal_Equipment__c 
                                                                    WHERE Id = :proposalEquipmentBeforeTrigger[0].Id
                                                                    ];

        System.assertEquals(20, proposalEquipmentAfterTrigger[0].Cost__c);
        System.assertEquals(5, proposalEquipmentAfterTrigger[0].Margin__c);
    }
}