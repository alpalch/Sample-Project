/**
 * @description       : This is a controller for ProposalAsPdf VisualForce page.
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 29-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ProposalAsPdfController {

    public String proposalId;
    public Proposal__c proposal = new Proposal__c();
    public OpportunityContactRole oppContactRole = new OpportunityContactRole();
    public String accountName {get; set;}
    public String contactName {get; set;}
    public String contactEmail {get; set;}

    public ProposalAsPdfController() {
        this.proposalId = ApexPages.CurrentPage().getparameters().get('proposalId');
        this.oppContactRole = getOpportunityContactRole();
        this.accountName = getAccountName();
        this.contactName = getContactName();
        this.contactEmail = getContactEmail();
    }

    public void assignProposal() {
        List<Proposal__c> proposals = [
                                       SELECT Id, Name, Opportunity__c, Total_Price__c 
                                       FROM Proposal__c 
                                       WHERE Id = :(Id)this.proposalId
                                       ];
        this.proposal = proposals[0];
    }

    public OpportunityContactRole getOpportunityContactRole() {
        this.assignProposal();
        List<OpportunityContactRole> oppContactRoles = [
                                                        SELECT Id, Contact.Name, Contact.Email 
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId = :proposal.Opportunity__c AND IsPrimary = true
                                                        LIMIT 1
                                                        ];
        return oppContactRoles[0];
    }
    
    public Proposal__c getProposal() {
        this.assignProposal();
        return proposal;
    }

    public String getAccountName() {
        this.assignProposal();
        List<Opportunity> opportunities = [
                                          SELECT Account.Name
                                          FROM Opportunity
                                          WHERE Id = :proposal.Opportunity__c
                                          LIMIT 1
                                          ];
        return opportunities[0].Account.Name;
    }

    public String getContactName() {
        String contactName = this.oppContactRole.Contact.Name;
        return contactName;
    }

    public String getContactEmail() {
        String contactEmail = this.oppContactRole.Contact.Email;
        return contactEmail;
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
}