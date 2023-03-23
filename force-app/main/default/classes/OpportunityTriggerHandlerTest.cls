/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 23-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public without sharing class OpportunityTriggerHandlerTest {

    @isTest
    public static void setPrimaryContactSuccessTest(){
        // Given
        List<Opportunity> opportunities = TestDataFactory.oppsForOppTriggerHandler(1, 2);
        
        // When
        Test.startTest();
        List<OpportunityContactRole> ocrs = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :opportunities];
        List<OpportunityContactRole> ocrsPrimary = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :opportunities AND isPrimary = true];
        Test.stopTest();

        // Then
        System.assertEquals(1, ocrs.size());
        System.assertEquals(1, ocrsPrimary.size());
    }

    @isTest
    public static void setClosedDateTodaySuccessTest(){
        // Given
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(5, true);

        // When
        Test.startTest();
        for(Opportunity opportunity :opportunities){
            opportunity.StageName = 'Closed Won';
        }
        update opportunities;
        Test.stopTest();

        // Then
        List<Opportunity> opportunitiesToAssert = [SELECT CloseDate FROM Opportunity WHERE Id IN :opportunities];
        Integer assertCounter = 0;
        for(Opportunity opportunity :opportunitiesToAssert){
            if(opportunity.CloseDate == Date.today()){
                assertCounter++;
            }
        }
        System.assertEquals(5, assertCounter);
    }

    @isTest
    public static void setActualAmountSuccessTest(){
        // Given
        List<Proposal_Equipment__c> proposalEquipments = TestDataFactory.createProposalEquipments(1, true);

        // When
        Test.startTest();
        List<Proposal__c> proposals = [SELECT Status__c, Total_Price__c, Opportunity__c FROM Proposal__c WHERE Id = :proposalEquipments[0].Proposal__c];
        proposals[0].Status__c = 'Accepted';
        update proposals; 
        Test.stopTest();

        // Then
        List<Opportunity> opportunities = [SELECT Amount FROM Opportunity WHERE Id = :proposals[0].Opportunity__c];
        System.assertEquals(proposals[0].Total_Price__c, opportunities[0].Amount);
    }
}