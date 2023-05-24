/**
 * @description       : Wrapper class
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ClonedOpportunity {
    @AuraEnabled public Id parentOpportunityId;
    @AuraEnabled public String parentOpportunityName;
    @AuraEnabled public String parentOpportunityStage;
    @AuraEnabled public Date parentOpportunityCloseDate;
    @AuraEnabled public Decimal parentOpportunityAmount;
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public String opportunityName;
    @AuraEnabled public List<OpportunityLineItem> lineItems;
}