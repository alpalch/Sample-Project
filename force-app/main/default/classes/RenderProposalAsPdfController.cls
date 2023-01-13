public class RenderProposalAsPdfController {

    public String currentProposalId;
    public Proposal__c proposal = new Proposal__c();

    public RenderProposalAsPdfController() {
        this.currentProposalId = ApexPages.CurrentPage().getparameters().get('proposalId');
    }

    public void assignProposal(){
        this.proposal = [SELECT Id, Name, Opportunity__c, Total_Price__c FROM Proposal__c WHERE Id = :Id.valueOf(this.currentProposalId)][0];
    }
    
    public Proposal__c getProposal(){
        this.assignProposal();
        return proposal;
    }

    public List<Map<String, String>> getProposalEquipment(){
        List<Proposal_Equipment__c> listPE = [SELECT Equipment__r.Name , Quantity__c, Price__c FROM Proposal_Equipment__c WHERE Proposal__c = :Id.valueOf(currentProposalId)];
        List<Map<String, String>> returnList = new List<Map<String,String>>();
        for(Proposal_Equipment__c pe :listPE){
            Map<String, String> mapPE = new Map<String, String>{
                'equipmentName' => pe.Equipment__r.Name,
                'Quantity' => String.valueOf(pe.Quantity__c),
                'Price' => String.valueOf(pe.Price__c),
                'totalPrice' => String.valueOf(pe.Price__c * pe.Quantity__c)
            };
            returnList.add(mapPE);
        }
        return returnList;
    }

    public Account getProposalAccount(){
        this.assignProposal();
        List<Opportunity> listOpp = [SELECT AccountId FROM Opportunity WHERE Id = :proposal.Opportunity__c];
        return [SELECT Name FROM Account WHERE Id = :listOpp[0].AccountId][0];
    }

    public Contact getProposalContact(){
        this.assignProposal();
        List<OpportunityContactRole> listOCR = [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId = :proposal.Opportunity__c AND IsPrimary = true];
        return [SELECT Name, Email FROM Contact WHERE Id = :listOCR[0].ContactId][0];
    }
}
