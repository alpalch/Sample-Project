public with sharing class ProposalDetailBodyController {

    @AuraEnabled(cacheable=false)
    public static void createNewProposal(List<String> equipIds, String OppId){
        // Remove duplicates in equipIds
        Set<String> setOfEquipIds = new Set<String>();
        for(String equip: equipIds){
            setOfEquipIds.add(Id.valueOf(equip));
        }

        Proposal__c proposal = new Proposal__c(
            Opportunity__c = Id.valueOf(OppId)
        );
        insert proposal;

        // Pick just created proposal. It the last one
        List<Proposal__c> proposals = [SELECT Id FROM Proposal__c ORDER BY CreatedDate DESC LIMIT 1];
        if(!proposals.isEmpty()){
            proposal = proposals[0];
        }

        // Select all equipments in setOfEquipIds to get equipment names
        List<Equipment__c> equips = [SELECT Id, Name FROM Equipment__c WHERE Id IN :setOfEquipIds];
        Map<Id, Equipment__c> equipsMap = new Map<Id, Equipment__c>();
        for(Equipment__c equip :equips){
            equipsMap.put(equip.Id, equip);
        }

        List<Proposal_Equipment__c> listToInsert = new List<Proposal_Equipment__c>();
        for(String equipId: setOfEquipIds){
            Proposal_Equipment__c propEquip = new Proposal_Equipment__c(
                Name = equipsMap.get(equipId).Name + ' ' + Date.today(),
                Proposal__c = proposal.Id,
                Equipment__c = equipId
            );
            listToInsert.add(propEquip);
        }
        insert listToInsert;
    }
}
