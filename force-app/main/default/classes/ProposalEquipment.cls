/**
 * @description       : This class is used to store Proposal Equipment data
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 04-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
public class ProposalEquipment {
    @AuraEnabled public String proposalEquipmentId;
    @AuraEnabled public String proposalEquipmentName;
    @AuraEnabled public String equipmentId;
    @AuraEnabled public String equipmentName;
    @AuraEnabled public String equipmentDescription;
    @AuraEnabled public String vendorName;
    @AuraEnabled public String equipmentCategoryName;
    @AuraEnabled public Decimal proposalEquipmentQuantity;
    @AuraEnabled public Decimal proposalEquipmentCost;
    @AuraEnabled public Decimal proposalEquipmentPrice;
    @AuraEnabled public Decimal proposalEquipmentMargin;
    @AuraEnabled public Decimal equipmentCost;
}