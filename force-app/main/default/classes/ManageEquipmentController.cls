/**
 * @description       : This is a controller to manage equipments.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ManageEquipmentController {

    @AuraEnabled(cacheable=true)
    public static List<Equipment_Category__c> getEquipmentCategories() {
        List<Equipment_Category__c> categories = [SELECT Id, Name FROM Equipment_Category__c];
        return categories;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProposalEquipment> getEquipments(String category, String equipmentName) {
        String query = 'SELECT Id, Name, Equipment_Category__r.Name, Cost__c, Description__c, Account__r.Name FROM Equipment__c ';
        String searchKey = equipmentName == null ? '%%' : '%' + equipmentName + '%';
        if(category != null) {
            String whereClause = 'WHERE Equipment_Category__c = \'' + category + '\' AND Name LIKE :searchKey';
            query += whereClause;
        }
        else {
            String whereClause = 'WHERE Name LIKE :searchKey';
            query += whereClause;
        }
        
        List<ProposalEquipment> equipmentWrappers = new List<ProposalEquipment>();

        List<Equipment__c> equipments = Database.query(query);

        for(Equipment__c equipment : equipments) {
            ProposalEquipment equipmentWrapper = new ProposalEquipment();
            equipmentWrapper.equipmentId = equipment.Id;
            equipmentWrapper.equipmentName = equipment.Name;
            equipmentWrapper.equipmentDescription = equipment.Description__c;
            equipmentWrapper.equipmentCost = equipment.Cost__c;
            equipmentWrapper.equipmentCategoryName = equipment.Equipment_Category__r.Name;
            equipmentWrapper.vendorName = equipment.Account__r.Name;
            equipmentWrappers.add(equipmentWrapper);
        }
        return equipmentWrappers;
    }

    @AuraEnabled(cacheable=true)
    public static ProposalEquipment getEquipmentDetails(String equipmentId) {
        List<ProposalEquipment> equipmentWrappers = new List<ProposalEquipment>();
        List<Equipment__c> equipments = [SELECT Name, Description__c, Equipment_Category__r.Name
                                         FROM Equipment__c
                                         WHERE Id = :(Id)equipmentId
                                         LIMIT 1];
        for(Equipment__c equipment : equipments) {
            ProposalEquipment equipmentWrapper = new ProposalEquipment();
            equipmentWrapper.equipmentName = equipment.Name;
            equipmentWrapper.equipmentDescription = equipment.Description__c;
            equipmentWrapper.equipmentCategoryName = equipment.Equipment_Category__r.Name;
            equipmentWrappers.add(equipmentWrapper);
        }
        return equipmentWrappers[0];
    }

    @AuraEnabled(cacheable=false)
    public static void createProposalEquipment(String proposalEquipmentData, String proposalId) {
        ProposalEquipment proposalEquipment = (ProposalEquipment)JSON.deserialize(proposalEquipmentData, ProposalEquipment.class);

        Proposal_Equipment__c proposalEquipmentRecord = new Proposal_Equipment__c();
        proposalEquipmentRecord.Proposal__c = (Id)proposalId;
        proposalEquipmentRecord.Equipment__c = (Id)proposalEquipment.equipmentId;
        proposalEquipmentRecord.Quantity__c = proposalEquipment.proposalEquipmentQuantity;
        proposalEquipmentRecord.Name = proposalEquipment.equipmentName + ' ' + Date.Today();

        insert proposalEquipmentRecord;
    }

    @AuraEnabled(cacheable=false)
    public static void deleteProposalEquipment(String proposalEquipmentId) {
        List<Proposal_Equipment__c> proposalEquipmentRecords = [SELECT Id 
                                                                FROM Proposal_Equipment__c 
                                                                WHERE Id = :(Id)proposalEquipmentId
                                                                LIMIT 1];
        delete proposalEquipmentRecords;
    }

    @AuraEnabled(cacheable=true)
    public static String getEquipmentsForProposal(String proposalId) {
        List<ProposalEquipment> equipmentsToReturn = new List<ProposalEquipment>();
        List<Proposal_Equipment__c> proposalEquipments = [SELECT Id, Name, Equipment__r.Name, Quantity__c, Cost__c, Price__c, Margin__c
                                                          FROM Proposal_Equipment__c
                                                          WHERE Proposal__c = :(Id)proposalId];
        for(Proposal_Equipment__c equipment :proposalEquipments) {
            ProposalEquipment proposalEquipment = new ProposalEquipment();
            
            proposalEquipment.proposalEquipmentId = equipment.Id;
            proposalEquipment.proposalEquipmentName = equipment.Name;
            proposalEquipment.equipmentName = equipment.Equipment__r.Name;
            proposalEquipment.proposalEquipmentQuantity = equipment.Quantity__c;
            proposalEquipment.proposalEquipmentCost = equipment.Cost__c;
            proposalEquipment.proposalEquipmentPrice = equipment.Price__c;
            proposalEquipment.proposalEquipmentMargin = equipment.Margin__c;

            equipmentsToReturn.add(proposalEquipment);
        }
        return JSON.serialize(equipmentsToReturn);
    }

    @AuraEnabled(cacheable=false)
    public static void updateProposalEquipments(String jsonData) {
        List<ProposalEquipment> updateData = (List<ProposalEquipment>)JSON.deserialize(jsonData, List<ProposalEquipment>.class);

        List<Id> proposalEquipmentIds = new List<Id>();
        for(ProposalEquipment proposalEquipment :updateData) {
            proposalEquipmentIds.add((Id)proposalEquipment.proposalEquipmentId);
        }
        Map<Id, Proposal_Equipment__c> proposalEquipments = new Map<Id, Proposal_Equipment__c>([SELECT Id, Name, Quantity__c, Cost__c, Margin__c
                                                                                                FROM Proposal_Equipment__c
                                                                                                WHERE Id IN :proposalEquipmentIds]);

        List<Proposal_Equipment__c> proposalEquipmentsToUpdate = new List<Proposal_Equipment__c>();
        for(ProposalEquipment proposalEquipment :updateData) {
            Proposal_Equipment__c proposalEquipmentRecord = new Proposal_Equipment__c();

            proposalEquipmentRecord.Id = (Id)proposalEquipment.proposalEquipmentId;

            proposalEquipmentRecord.Name = String.isBlank(proposalEquipment.proposalEquipmentName) ? 
                                           proposalEquipments.get((Id)proposalEquipment.proposalEquipmentId).Name : 
                                           proposalEquipment.proposalEquipmentName;
            
            proposalEquipmentRecord.Quantity__c = proposalEquipment.proposalEquipmentQuantity == null ? 
                                                  proposalEquipments.get((Id)proposalEquipment.proposalEquipmentId).Quantity__c : 
                                                  proposalEquipment.proposalEquipmentQuantity;

            proposalEquipmentRecord.Cost__c = proposalEquipment.proposalEquipmentCost == null ? 
                                              proposalEquipments.get((Id)proposalEquipment.proposalEquipmentId).Cost__c : 
                                              proposalEquipment.proposalEquipmentCost;

            proposalEquipmentRecord.Margin__c = proposalEquipment.proposalEquipmentMargin == null ? 
                                                proposalEquipments.get((Id)proposalEquipment.proposalEquipmentId).Margin__c : 
                                                proposalEquipment.proposalEquipmentMargin * 100;


            proposalEquipmentsToUpdate.add(proposalEquipmentRecord);
        }
        update proposalEquipmentsToUpdate;
    }

    @AuraEnabled(cacheable=false)
    public static void massMarginUpdate(String proposalEquipmentData) {
        List<ProposalEquipment> proposalEquipments = (List<ProposalEquipment>)JSON.deserialize(proposalEquipmentData, List<ProposalEquipment>.class);
        List<Proposal_Equipment__c> proposalEquipmentToUpdate = new List<Proposal_Equipment__c>();

        for(ProposalEquipment proposalEquipment :proposalEquipments) {
            Proposal_Equipment__c proposalEquipmentRecord = new Proposal_Equipment__c();

            proposalEquipmentRecord.Id = (Id)proposalEquipment.proposalEquipmentId;
            proposalEquipmentRecord.Margin__c = proposalEquipment.proposalEquipmentMargin;

            proposalEquipmentToUpdate.add(proposalEquipmentRecord);
        }
        update proposalEquipmentToUpdate;
    }
}