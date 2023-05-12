/**
 * @description       : Handler for OpportunityTrigger
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 14-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class OpportunityTriggerHandler {
	
    public static void setPrimaryContact(List<Opportunity> opportunities) {
        // not execute the trigger if the opportunity created by lead conversion
        if(opportunities[0].LeadId__c == null) {
            List<AccountContactRelation> firstAccountContactRelations = [
                                                                         SELECT CreatedDate, ContactId 
                                                                         FROM AccountContactRelation 
                                                                         WHERE AccountId = :opportunities[0].AccountId 
                                                                         ORDER BY CreatedDate DESC LIMIT 1
                                                                         ];

            if(!firstAccountContactRelations.isEmpty()) {
                OpportunityContactRole ocr = new OpportunityContactRole (
                    OpportunityId = opportunities[0].Id, 
                    ContactId = firstAccountContactRelations[0].ContactId, 
                    isPrimary = true, 
                    Role = 'Decision Maker'
                    );
                    insert ocr;
            }
        }
    }

    public static void setClosedDateToday(Opportunity newOpportunity, Opportunity oldOpportunity) {
        if(newOpportunity.StageName != oldOpportunity.StageName) {
            if(newOpportunity.StageName == 'Closed Won' || newOpportunity.StageName == 'Closed Lost') {
                newOpportunity.CloseDate = Date.today();
            }
        }     
    }

    public static void setActualAmount(Opportunity newOpportunity, Opportunity oldOpportunity) {
        if(newOpportunity.Actual_Sum_Of_Accepted_Proposals__c != oldOpportunity.Actual_Sum_Of_Accepted_Proposals__c) {
            // Actual_Sum_Of_Accepted_Proposals__c -> rollup sum of accepted proposals
            newOpportunity.Amount = newOpportunity.Actual_Sum_Of_Accepted_Proposals__c;
        }
    }

    // Method iterates through two lists of Opportunity objects (newRecords and oldRecords)
    // and calls the helper methods for each Opportunity object in both lists.
    public static void updateChangedFields(List<Opportunity> newRecords, List<Opportunity> oldRecords) {
        for(Opportunity newOpportunity :newRecords) {
            for(Opportunity oldOpportunity: oldRecords) {
                if(newOpportunity.id == oldOpportunity.id) {
                    setActualAmount(newOpportunity, oldOpportunity);
                    setClosedDateToday(newOpportunity, oldOpportunity);
                }
            }
        }
    }
}