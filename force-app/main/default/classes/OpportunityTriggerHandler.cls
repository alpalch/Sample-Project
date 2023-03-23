/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 06-03-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class OpportunityTriggerHandler {
	
    public static void setPrimaryContact(List<Opportunity> triggerList){
        // not execute the trigger if the opportunity created by lead conversion
        if(triggerList[0].LeadId__c == null){
            List<AccountContactRelation> firstCreatedContact = [
                SELECT CreatedDate, ContactId 
                FROM AccountContactRelation 
                WHERE AccountId = :triggerList[0].AccountId 
                ORDER BY CreatedDate DESC LIMIT 1];

            OpportunityContactRole ocr = new OpportunityContactRole(
                    OpportunityId = triggerList[0].Id, 
                    ContactId = firstCreatedContact[0]?.ContactId, 
                    isPrimary = true, 
                    Role = 'Decision Maker'
                    );

            insert ocr;
        }
    }

    public static void setClosedDateToday(List<Opportunity> triggerNewList, List<Opportunity> triggerOldList){
        // Foresee that several Opportunities may be updated
        for(Opportunity newOpp: triggerNewList){
            for(Opportunity oldOpp: triggerOldList){
                if(newOpp.id == oldOpp.id && newOpp.StageName != oldOpp.StageName){
                    if(newOpp.StageName == 'Closed Won' || newOpp.StageName == 'Closed Lost'){
                        newOpp.CloseDate = Date.today();
                    }
                }
            }
        }
    }

    public static void setActualAmount(List<Opportunity> triggerNewList, List<Opportunity> triggerOldList){
        for(Opportunity oppNew: triggerNewList){
            for(Opportunity oppOld: triggerOldList){
                if(oppNew.Actual_Sum_Of_Accepted_Proposals__c != oppOld.Actual_Sum_Of_Accepted_Proposals__c){
                    // Actual_Sum_Of_Accepted_Proposals__c -> rollup sum of accepted proposals
                    oppNew.Amount = oppNew.Actual_Sum_Of_Accepted_Proposals__c;
                }
            }
        }
    }
    
}