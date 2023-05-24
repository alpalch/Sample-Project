/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : @ValeriyPalchenko
**/
public without sharing class ManageOpportunityModalController {
    
    @AuraEnabled(cacheable=true)
    public static String getOpportunityProductsData(String parentOpportunityId) {
        List<Opportunity> parentOpportunities = [SELECT Id, Name, StageName, Amount, CloseDate, Pricebook2Id, 
                                                    (SELECT Id, OpportunityId, Name, UnitPrice, Quantity, Product2Id, Description
                                                     FROM OpportunityLineItems)
                                                 FROM Opportunity
                                                 WHERE Id = :(Id)parentOpportunityId
                                                 LIMIT 1];

        List<ClonedOpportunity> clonedOpportunities = new List<ClonedOpportunity>();
        
        for(Opportunity opportunity :parentOpportunities) {
            ClonedOpportunity clonedOpportunity = new ClonedOpportunity();
            clonedOpportunity.parentOpportunityId = parentOpportunities[0].Id;
            clonedOpportunity.parentOpportunityName = parentOpportunities[0].Name;
            clonedOpportunity.parentOpportunityStage = parentOpportunities[0].StageName;
            clonedOpportunity.parentOpportunityAmount = parentOpportunities[0].Amount;
            clonedOpportunity.parentOpportunityCloseDate = parentOpportunities[0].CloseDate;
            clonedOpportunity.opportunityId = parentOpportunities[0].Id;
            clonedOpportunity.opportunityName = parentOpportunities[0].Name;
            clonedOpportunity.lineItems = parentOpportunities[0].OpportunityLineItems ;
            clonedOpportunities.add(clonedOpportunity);
        }
        return JSON.serialize(clonedOpportunities);
    }

    @AuraEnabled(cacheable=true)
    public static String handleProductSearch(String searchKey, String opportunityId) {
        List<OpportunityLineItem> products = new List<OpportunityLineItem>();

        if(String.isBlank(searchKey)) {
            products = [SELECT Id, OpportunityId, Name, UnitPrice, Quantity, Product2Id, Description
                        FROM OpportunityLineItem
                        WHERE OpportunityId = :(Id)opportunityId];
        } else {
            searchKey = '%' + searchKey + '%';
            products = [SELECT Id, OpportunityId, Name, UnitPrice, Quantity, Product2Id, Description
                        FROM OpportunityLineItem
                        WHERE OpportunityId = :(Id)opportunityId AND Description LIKE :searchKey];
        }
        return JSON.serialize(products);
    }

    private static void deleteOpportunities(List<ClonedOpportunity> clonedOpportunities, List<Opportunity> existedOpportunities, String parentOpportunityId) {
        Set<Id> clonedOpportunityKeySet = new Set<Id>();
        List<Opportunity> opportunitiesToDelete = new List<Opportunity>();
        List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();

        for(ClonedOpportunity clonedOpportunity :clonedOpportunities) {
            clonedOpportunityKeySet.add(clonedOpportunity.opportunityId);
        }
        
        for(Opportunity opportunity :existedOpportunities) {
            if(!clonedOpportunityKeySet.contains(opportunity.Id)) {
                opportunitiesToDelete.add(opportunity);
                for(OpportunityLineItem lineItem :opportunity.OpportunityLineItems) {
                    OpportunityLineItem newLineItem = lineItem.clone();
                    newLineItem.OpportunityId = (Id)parentOpportunityId;
                    newLineItems.add(newLineItem);
                }
            }
        }
        insert newLineItems;
        delete opportunitiesToDelete;
    }

    private static void createOpportunities(List<ClonedOpportunity> clonedOpportunities, Set<Id> existedOpportunityIds, Opportunity parentOpportunity) {
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lineItemsToDelete = new List<OpportunityLineItem>();

        // create opportunities that were updated on the front-end
        for(ClonedOpportunity clonedOpportunity :clonedOpportunities) {
            if(!existedOpportunityIds.contains(clonedOpportunity.opportunityId)) {
                Opportunity newOpportunity = parentOpportunity.clone();
                newOpportunity.ParentOpportunityId__c = parentOpportunity.Id;
                newOpportunity.Name = clonedOpportunity.opportunityName;
                opportunitiesToInsert.add(newOpportunity);
            }
        }
        insert opportunitiesToInsert;

        //assign line items to the new opportunities
        for(ClonedOpportunity clonedOpportunity :clonedOpportunities) {
            for(Opportunity opportunity :opportunitiesToInsert) {
                if(opportunity.Name == clonedOpportunity.opportunityName) {
                    for(OpportunityLineItem lineItem :clonedOpportunity.lineItems) {
                        OpportunityLineItem newLineItem = lineItem.clone();
                        newLineItem.OpportunityId = opportunity.Id;
                        newLineItems.add(newLineItem);
                        lineItemsToDelete.add(lineItem);
                    }
                }
            }
        }
        insert newLineItems;

        if(!lineItemsToDelete.isEmpty()) {
            delete lineItemsToDelete;
        }
    }

    private static void updateOpportunities(List<ClonedOpportunity> clonedOpportunities, Map<Id, Opportunity> existedOpportunityIds, Opportunity parentOpportunity) {
        List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> lineItemsToDelete = new List<OpportunityLineItem>();

        for(ClonedOpportunity clonedOpportunity :clonedOpportunities) {
            if(existedOpportunityIds.keySet().contains(clonedOpportunity.opportunityId)) {
                Opportunity opportunity = existedOpportunityIds.get(clonedOpportunity.opportunityId);
                Set<Id> clonedLineItemIds = new Set<Id>(); // Line items that were NOT updated on the front-end
                if(clonedOpportunity.lineItems?.size() != null) {
                    for(OpportunityLineItem clonedLineItem :clonedOpportunity.lineItems) {
                        if(String.isBlank(clonedLineItem.OpportunityId)) { //New line items have no OpportunityId
                            OpportunityLineItem newLineItem = clonedLineItem.clone();
                            newLineItem.OpportunityId = opportunity.Id;
                            newLineItems.add(newLineItem);
                            lineItemsToDelete.add(clonedLineItem);
                        } else {
                            clonedLineItemIds.add(clonedLineItem.Id); 
                        }
                    }
                }

                for(OpportunityLineItem lineItem :opportunity.OpportunityLineItems) { // Line items that were deleted from this Opportunity on the front-end
                    if(!clonedLineItemIds.contains(lineItem.Id)) {
                        OpportunityLineItem newLineItem = lineItem.clone();
                        newLineItem.OpportunityId = parentOpportunity.Id;
                        newLineItems.add(newLineItem);
                        lineItemsToDelete.add(lineItem);
                    }
                }
            }
        }
        insert newLineItems;
        delete lineItemsToDelete;
    }

    @AuraEnabled(cacheable=false)
    public static void createOpportunityChildren(String opportunitiesData, String parentOpportunityId) {
        List<ClonedOpportunity> clonedOpportunities = (List<ClonedOpportunity>)JSON.deserialize(opportunitiesData, List<ClonedOpportunity>.class);

        List<Opportunity> parentOpportunities = [SELECT Id, AccountId, Name, StageName, Amount, CloseDate, Pricebook2Id
                                                   FROM Opportunity
                                                   WHERE Id = :(Id)parentOpportunityId
                                                   LIMIT 1];

        Map<Id, Opportunity> existedOpportunityIds = new Map<Id, Opportunity>([SELECT Id, ParentOpportunityId__c, 
                                                        (SELECT Id, OpportunityId, Name, UnitPrice, Quantity, Product2Id, PricebookEntryId, Description
                                                         FROM OpportunityLineItems)
                                                    FROM Opportunity
                                                    WHERE ParentOpportunityId__c = :parentOpportunities[0].Id]);
        
        // create Opportunities with Line Items that were created on the front-end
        createOpportunities(clonedOpportunities, existedOpportunityIds.keySet(), parentOpportunities[0]);
        
        // update opportunities that were updated on the front-end
        updateOpportunities(clonedOpportunities, existedOpportunityIds, parentOpportunities[0]);

        // delete opportunities that were deleted on the front-end
        deleteOpportunities(clonedOpportunities, existedOpportunityIds.values(), parentOpportunityId);
    }

    @AuraEnabled(cacheable=true)
    public static String getAlreadyCreatedChilds(String parentOpportunityId) {
        List<ClonedOpportunity> clonedOpportunities = new List<ClonedOpportunity>();
        
        List<Opportunity> opportunities = [SELECT Id, Name,
                                                (SELECT Id, OpportunityId, Name, UnitPrice, Quantity, Product2Id, PricebookEntryId, Description
                                                 FROM OpportunityLineItems)
                                           FROM Opportunity
                                           WHERE ParentOpportunityId__c = :(Id)parentOpportunityId];
        
        for(Opportunity opportunity :opportunities) {
            ClonedOpportunity clonedOpportunity = new ClonedOpportunity();
            clonedOpportunity.opportunityId = opportunity.Id;
            clonedOpportunity.parentOpportunityId = (Id)parentOpportunityId;
            clonedOpportunity.opportunityName = opportunity.Name;
            clonedOpportunity.lineItems = opportunity.OpportunityLineItems;
            clonedOpportunities.add(clonedOpportunity);
        }
        return JSON.serialize(clonedOpportunities);
    }
}