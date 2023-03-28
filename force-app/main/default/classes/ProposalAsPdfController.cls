/**
 * @description       : This is a controller for ProposalAsPdf VisualForce page.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 28-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ProposalAsPdfController {

    public String proposalId;
    public Proposal__c proposal = new Proposal__c();

    public ProposalAsPdfController() {
        this.proposalId = ApexPages.CurrentPage().getparameters().get('proposalId');
    }

    public void assignProposal() {
        List<Proposal__c> proposals = [
                                       SELECT Id, Name, Opportunity__c, Total_Price__c 
                                       FROM Proposal__c 
                                       WHERE Id = :(Id)this.proposalId
                                       ];
        this.proposal = proposals[0];
    }
    
    public Proposal__c getProposal() {
        this.assignProposal();
        return proposal;
    }

    public List<Map<String, String>> getProposalEquipment() {
        List<Proposal_Equipment__c> proposalEquipments = [
                                                          SELECT Equipment__r.Name , Quantity__c, Price__c 
                                                          FROM Proposal_Equipment__c 
                                                          WHERE Proposal__c = :(Id)proposalId
                                                          ];
        List<Map<String, String>> equipmentsToDisplay = new List<Map<String,String>>();
        for(Proposal_Equipment__c propEquipment :proposalEquipments) {
            Map<String, String> proposalEquipmentsByRow = new Map<String, String> {
                'equipmentName' => propEquipment.Equipment__r.Name,
                'Quantity' => String.valueOf(propEquipment.Quantity__c),
                'Price' => String.valueOf(propEquipment.Price__c),
                'totalPrice' => String.valueOf(propEquipment.Price__c * propEquipment.Quantity__c)
            };
            equipmentsToDisplay.add(proposalEquipmentsByRow);
        }
        return equipmentsToDisplay;
    }

    public Account getProposalAccount() {
        this.assignProposal();
        List<Opportunity> opportunities = [
                                          SELECT AccountId 
                                          FROM Opportunity 
                                          WHERE Id = :proposal.Opportunity__c
                                          ];
        List<Account> accounts = [
                                 SELECT Name 
                                 FROM Account 
                                 WHERE Id = :opportunities[0].AccountId 
                                 LIMIT 1
                                 ];
        return accounts[0];
    }

    public Contact getProposalContact() {
        this.assignProposal();
        List<OpportunityContactRole> oppContactRoles = [
                                                        SELECT Id, ContactId 
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId = :proposal.Opportunity__c AND IsPrimary = true
                                                        ];
        List<Contact> contacts = [
                                  SELECT Name, Email 
                                  FROM Contact 
                                  WHERE Id = :oppContactRoles[0].ContactId
                                  LIMIT 1
                                  ];
        return contacts[0];
    }
}