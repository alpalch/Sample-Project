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
}