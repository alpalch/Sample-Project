/**
 * @description       : This class is used to store Proposal Equipment data
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
public class Proposal {
    @AuraEnabled public Id proposalId;
    @AuraEnabled public Id opportunityId;
    @AuraEnabled public String opportunityStageName;
    @AuraEnabled public String proposalName;
    @AuraEnabled public String proposalStatus;
    @AuraEnabled public Boolean proposalIsExpanded;
    @AuraEnabled public List<ProposalEquipment> proposalEquipments;
    @AuraEnabled public Decimal opportunityTotalQuantity;
    @AuraEnabled public Decimal opportunityTotalCost;
    @AuraEnabled public Decimal opportunityTotalPrice;
    @AuraEnabled public Decimal opportunityMargin;
}
