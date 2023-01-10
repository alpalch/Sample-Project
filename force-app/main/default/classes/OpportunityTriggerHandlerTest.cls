@isTest
public without sharing class OpportunityTriggerHandlerTest {
    @isTest
    public static void setPrimaryContactSuccessTest(){
        
        List<Opportunity> opps = DataFactory.oppsForOppTriggerHandler(1, 2);
        List<OpportunityContactRole> ocrs = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :opps];
        List<OpportunityContactRole> ocrsPrimary = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN :opps AND isPrimary = true];
        System.assertEquals(1, ocrs.size());
        System.assertEquals(1, ocrsPrimary.size());
    }

    @isTest
    public static void setClosedDateTodaySuccessTest(){
        List<Opportunity> listOpp = DataFactory.createMultipleOpportunity(5);
        insert listOpp;
        for(Opportunity opp :listOpp){
            opp.StageName = 'Closed Won';
        }
        update listOpp;

        List<Opportunity> listToAssert = [SELECT CloseDate FROM Opportunity WHERE Id IN :listOpp];

        Integer assertCounter = 0;
        for(Opportunity opp :listToAssert){
            if(opp.CloseDate == Date.today()){
                assertCounter++;
            }
        }
        System.assertEquals(5, assertCounter);
    }

    @isTest
    public static void setActualAmountSuccessTest(){
        Proposal_Equipment__c propEquip = DataFactory.createProposalEquipment();
        insert propEquip;
        Proposal__c prop = [SELECT Status__c, Total_Price__c, Opportunity__c FROM Proposal__c WHERE Id = :propEquip.Proposal__c][0];
        prop.Status__c = 'Accepted';
        update prop; 

        Opportunity opp = [SELECT Amount FROM Opportunity WHERE Id = :prop.Opportunity__c][0];
        System.assertEquals(prop.Total_Price__c, opp.Amount);
    }
}