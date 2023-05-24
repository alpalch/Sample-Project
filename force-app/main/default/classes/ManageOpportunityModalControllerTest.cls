/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 14-04-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public class ManageOpportunityModalControllerTest {
    @isTest
    public static void getOpportunityProductsDataTest() {
        //Given
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(1, false);
        opportunities[0].Name = 'Test Opportunity';
        insert opportunities;

        //When
        Test.startTest();
        String result = ManageOpportunityModalController.getOpportunityProductsData((String)opportunities[0].Id);
        Test.stopTest();

        //Then
        List<ClonedOpportunity> clonedOpportunities = (List<ClonedOpportunity>)JSON.deserialize(result, List<ClonedOpportunity>.class);
        System.assertEquals(1, clonedOpportunities.size());
        System.assertEquals('Test Opportunity', clonedOpportunities[0].parentOpportunityName);
    }

    @isTest
    public static void handleProductSearchTestNotBlankKey() {
        //Given
        List<OpportunityLineItem> opportunityLineItems = TestDataFactory.createOpportunityLineItems(1, false);
        opportunityLineItems[0].Description = 'Test Description';
        insert opportunityLineItems;

        //When
        Test.startTest();
        String result = ManageOpportunityModalController.handleProductSearch('Test', opportunityLineItems[0].OpportunityId);
        Test.stopTest();

        //Then
        List<OpportunityLineItem> resultLineItems = (List<OpportunityLineItem>)JSON.deserialize(result, List<OpportunityLineItem>.class);
        System.assertEquals(1, resultLineItems.size());
        System.assertEquals('Test Description', resultLineItems[0].Description);
    }

    @isTest
    public static void handleProductSearchTestBlankKey() {
        //Given
        List<OpportunityLineItem> opportunityLineItems = TestDataFactory.createOpportunityLineItems(1, false);
        opportunityLineItems[0].Description = 'Test Description';
        insert opportunityLineItems;

        //When
        Test.startTest();
        String result = ManageOpportunityModalController.handleProductSearch('', opportunityLineItems[0].OpportunityId);
        Test.stopTest();

        //Then
        List<OpportunityLineItem> resultLineItems = (List<OpportunityLineItem>)JSON.deserialize(result, List<OpportunityLineItem>.class);
        System.assertEquals(1, resultLineItems.size());
        System.assertEquals('Test Description', resultLineItems[0].Description);
    }

    @isTest
    public static void getAlreadyCreatedChildsTest() {
        //Given
        List<Opportunity> parentOpportunities = TestDataFactory.createOpportunities(1, true);
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(5, false);
        for (Opportunity opportunity : opportunities) {
            opportunity.ParentOpportunityId__c = parentOpportunities[0].Id;
        }
        insert opportunities;

        //When
        Test.startTest();
        String result = ManageOpportunityModalController.getAlreadyCreatedChilds((String)parentOpportunities[0].Id);
        Test.stopTest();

        //Then
        List<ClonedOpportunity> clonedOpportunities = (List<ClonedOpportunity>)JSON.deserialize(result, List<ClonedOpportunity>.class);
        System.assertEquals(5, clonedOpportunities.size());
    }

    @isTest
    public static void createOpportunityChildrenTest() {
        //Given
        List<Opportunity> opportunities = TestDataFactory.createOpportunities(4, true);
        opportunities[1].ParentOpportunityId__c = opportunities[0].Id;
        opportunities[2].ParentOpportunityId__c = opportunities[0].Id;
        opportunities[3].ParentOpportunityId__c = opportunities[0].Id;
        update opportunities;
        List<OpportunityLineItem> lineItems = TestDataFactory.createOpportunityLineItems(5, false);
        for(OpportunityLineItem lineItem :lineItems) {
            lineItem.OpportunityId = opportunities[1].Id;
        }
        lineItems[0].OpportunityId = opportunities[0].Id;
        lineItems[1].OpportunityId = opportunities[2].Id;
        insert lineItems;
        Map<Id, List<OpportunityLineItem>> lineItemOpportunityIds = new Map<Id, List<OpportunityLineItem>>();
        for(OpportunityLineItem lineItem :lineItems) {
            lineItemOpportunityIds.put(lineItem.OpportunityId, new List<OpportunityLineItem>{lineItem});
        }
        List<ClonedOpportunity> clonedOpportunities = new List<ClonedOpportunity>();
        for(Opportunity opportunity : opportunities) {
            if(opportunity.ParentOpportunityId__c != null) {
                ClonedOpportunity clonedOpportunity = new ClonedOpportunity();
                clonedOpportunity.parentOpportunityId = opportunity.ParentOpportunityId__c;
                clonedOpportunity.opportunityId = opportunity.Id;
                clonedOpportunity.opportunityName = opportunity.Name;
                clonedOpportunity.lineItems = lineItemOpportunityIds.get(opportunity.Id);
                clonedOpportunities.add(clonedOpportunity);
            }
        }
        clonedOpportunities.remove(1);

        ClonedOpportunity clonedOpportunity1 = new ClonedOpportunity();
        clonedOpportunity1.opportunityId = opportunities[3].Id;
        clonedOpportunity1.opportunityName = opportunities[3].Name;
        List<OpportunityLineItem> oldLineItems = lineItemOpportunityIds.get(opportunities[1].Id);
        List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
        newLineItems.add(lineItemOpportunityIds.get(opportunities[2].Id)[0]);
        clonedOpportunity1.lineItems = newLineItems;
        clonedOpportunities.add(clonedOpportunity1);

        ClonedOpportunity clonedOpportunity = new ClonedOpportunity();
        clonedOpportunity.opportunityId = null;
        clonedOpportunity.opportunityName = 'Test';
        clonedOpportunity.lineItems = lineItemOpportunityIds.get(opportunities[2].Id);
        clonedOpportunities.add(clonedOpportunity);

        //When
        Test.startTest();
        ManageOpportunityModalController.createOpportunityChildren(JSON.serialize(clonedOpportunities), opportunities[0].Id);
        Test.stopTest();

        //Then
        List<Opportunity> resultOpportunities = [SELECT Id, ParentOpportunityId__c FROM Opportunity WHERE ParentOpportunityId__c = :opportunities[0].Id];
        System.assertEquals(3, resultOpportunities.size());
    }
}