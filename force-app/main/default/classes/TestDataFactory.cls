/**
 * @description       : Class for creating test data
 * @author            : @ValeriyPalchenko
 * @group             : 
 * @last modified on  : 01-06-2023
 * @last modified by  : @ValeriyPalchenko
**/
@IsTest
public without sharing class TestDataFactory {

    public static List<Account> createVendorAccounts(Integer numberOfRecords, Boolean isInsert) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Account account = new Account(
                recordTypeId = Constants.VENDOR_RECORD_TYPE_ID,
                Payment__c = 'Wire',
                Name = 'Test '+ i,
                Phone = '12345'+ i,
                BillingStreet = 'Test Street',
                BillingCity = 'Test City',
                BillingPostalCode = '12345',
                BillingState = 'New York',
                BillingCountry = 'United States'
            );
            accounts.add(account);
        }
        if(isInsert) {
            insert accounts;
        }
        return accounts;
    }

    public static List<Account> createBuyerAccounts(Integer numberOfRecords, Boolean isInsert) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            Account account = new Account(
                recordTypeId = Constants.Buyer_RECORD_TYPE_ID,
                Payment__c = 'Wire',
                Name = 'Test '+ i,
                Phone = '12345'+ i,
                ShippingStreet = 'Test Street',
                ShippingCity = 'Test City',
                ShippingPostalCode = '12345',
                ShippingState = 'New York',
                ShippingCountry = 'United States'
            );
            accounts.add(account);
        }
        if(isInsert) {
            insert accounts;
        }
        return accounts;
    }

    public static List<Equipment_Category__c> createEquipmentCategories(Integer numberOfRecords, Boolean isInsert) {
        List<Equipment_Category__c> categoriesToReturn = new List<Equipment_Category__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            Equipment_Category__c equipmentCategory = new Equipment_Category__c();
            equipmentCategory.Name = 'Test ' + i;
            equipmentCategory.Margin__c = 5;
            categoriesToReturn.add(equipmentCategory);
        }
        if(isInsert) {
            insert categoriesToReturn;
        }
        return categoriesToReturn;
    }

    public static List<Equipment__c> createEquipments(Integer numberOfRecords, Boolean isInsert) {
        List<Account> accounts = createVendorAccounts(1, true);
        List<Equipment_Category__c> equipmentCategories = createEquipmentCategories(1, true);
        List<Equipment__c> equipmentsToReturn = new List<Equipment__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            Equipment__c equipment = new Equipment__c(
                Account__c = accounts[0].Id,
                Equipment_Category__c = equipmentCategories[0].Id,
                Name = 'Test',
                Description__c = 'Test',
                Cost__c = 10
            );
            equipmentsToReturn.add(equipment);
        }
        if(isInsert) {
            insert equipmentsToReturn;
        }
        return equipmentsToReturn;
    }

    public static List<Opportunity> createOpportunities(Integer numberOfRecords, Boolean isInsert) {
        List<Account> accounts = createBuyerAccounts(1, true);
        List<Opportunity> opportunitiesToReturn = new List<Opportunity>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            Opportunity opportunity = new Opportunity(
                Name = 'testOpp ' + i,
                StageName = 'Preparing Proposal',
                CloseDate = Date.today() + 14,
                AccountId = accounts[0].Id,
                LeadId__c = '123456789012345678'
            );
            opportunitiesToReturn.add(opportunity);
        }
        if(isInsert) {
            insert opportunitiesToReturn;
        }
        return opportunitiesToReturn;
    }

    public static List<Opportunity> dataForOpportunityTriggerHandlerTest(Integer numberOfRecords, Integer contactNumber) {
        List<Account> accounts = createBuyerAccounts(numberOfRecords, true);
        List<Opportunity> opportunitiesToReturn = new List<Opportunity>();
        List<Contact> contacts = new List<Contact>();

        for(Account account :accounts) {
            Opportunity opportunity = new Opportunity(
                name = 'testOpp',
                StageName = 'Preparing Proposal',
                CloseDate = Date.today() + 14,
                AccountId = account.Id
            );
            opportunitiesToReturn.add(opportunity);
            for(Integer i = 0; i < contactNumber; i++) {
                Contact contact = new Contact(
                    LastName = 'Test'+ i,
                    Email = 'test'+ i +'@gmail.com',
                    AccountId = account.id
                );
                contacts.add(contact);
            }
        }
        insert contacts;
        insert opportunitiesToReturn;

        return opportunitiesToReturn;      
    }

    public static List<Proposal_Equipment__c> dataForProposalEquipmentTriggerHandlerTest (Integer proposalEquipmentNumber) {

        List<Equipment__c> equipments = createEquipments(1, true);
        List<Opportunity> opportunities = createOpportunities(1, true);
        Proposal__c proposal= new Proposal__c(Opportunity__c = opportunities[0].Id);
        insert proposal;
        List<Proposal_Equipment__c> proposalEquipmentsToReturn = new List<Proposal_Equipment__c>();

        for (Integer i = 0; i < proposalEquipmentNumber; i++) {
            Proposal_Equipment__c proposalEquipment = new Proposal_Equipment__c(
                proposal__c = proposal.Id,
                Equipment__c = equipments[0].Id,
                name = 'Test',
                Quantity__c = 2,
                cost__c = 0,
                margin__c = 0
            );
            proposalEquipmentsToReturn.add(proposalEquipment);
        }
        return proposalEquipmentsToReturn;
    }

    public static Proposal__c createProposal() {
        List<Opportunity> opportunities = createOpportunities(1, true);
        Proposal__c proposalToReturn = new Proposal__c(
            Opportunity__c = opportunities[0].Id,
            Status__c = 'Draft'
        );
        return proposalToReturn;
    }

    public static List<Proposal__c> createProposals(Integer numberOfRecors, Boolean isInsert) {
        List<Opportunity> opportunities = createOpportunities(1, true);
        List<Proposal__c> proposalsToReturn = new List<Proposal__c>();

        for(Integer i = 0; i < numberOfRecors; i++) {
            Proposal__c proposal = new Proposal__c(
                Status__c = 'Draft',
                Opportunity__c = opportunities[0].Id,
                isExpandedTableRow__c = false
            );
            proposalsToReturn.add(proposal);
        }
        if(isInsert) {
            insert proposalsToReturn;
        }
        return proposalsToReturn;
    }

    public static List<Proposal_Equipment__c> createProposalEquipments(Integer numberOfRecords, Boolean isInsert) {
        List<Proposal__c> proposals = createProposals(1, true);
        List<Equipment__c> equipments = createEquipments(1, true);
        List<Proposal_Equipment__c> proposalEquipmentsToReturn = new List<Proposal_Equipment__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            Proposal_Equipment__c proposalEquipment = new Proposal_Equipment__c(
                Proposal__c = proposals[0].Id,
                Equipment__c = equipments[0].Id
            );
            proposalEquipmentsToReturn.add(proposalEquipment);
        }
        if(isInsert) {
            insert proposalEquipmentsToReturn;
        }
        return proposalEquipmentsToReturn;
    }

    public static List<Contact> createContacts(Integer numberOfRecords, Boolean isInsert) {
        List<Account> accounts = createBuyerAccounts(1, true);
        List<Contact> contactsToReturn = new List<Contact>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            Contact contact = new Contact(
                LastName = 'Doe',
                Email = 'test@test.com',
                AccountId = accounts[0].Id
            );
            contactsToReturn.add(contact);
        }
        if(isInsert) {
            insert contactsToReturn;
        }
        return contactsToReturn;
    }

    public static List<OpportunityContactRole> createOpportunitiesContactRoles(Integer numberOfRecords, Boolean isInsert) {
        List<Opportunity> opportunities = createOpportunities(1, true);
        List<Contact> contacts = createContacts(1, true);
        List<OpportunityContactRole> opportunitiesContactRolesToReturn = new List<OpportunityContactRole>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            OpportunityContactRole opportunityContactRole = new OpportunityContactRole(
                OpportunityId = opportunities[0].Id,
                ContactId = contacts[0].Id,
                IsPrimary = true
            );
            opportunitiesContactRolesToReturn.add(opportunityContactRole);
        }
        if(isInsert) {
            insert opportunitiesContactRolesToReturn;
        }
        return opportunitiesContactRolesToReturn;
    }

    public static Pricebook2 createPricebook() {
        Pricebook2 pricebook = new Pricebook2(
            Name = 'Standard Price Book',
            isActive = true
        );
        insert pricebook;
        return pricebook;
    }

    public static List<Product2> createProducts() {
        List<Product2> productsToReturn = new List<Product2>();
        Pricebook2 pricebook = createPricebook();

        for(Integer i = 0; i < 5; i++) {
            Product2 product = new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'Test Product Code ' + i,
                Description = 'Test Product Description ' + i,
                IsActive = true
            );
            productsToReturn.add(product);
        }
        insert productsToReturn;
        return productsToReturn;
    }

    public static List<PricebookEntry> createPricebookEntries() {
        List<Product2> products = createProducts();
        List<PricebookEntry> standardPricebookEntries = new List<PricebookEntry>();
        List<PricebookEntry> pricebookEntriesToReturn = new List<PricebookEntry>();
        Pricebook2 pricebook = createPricebook();

        for(Integer i = 0; i < 5; i++) {
            PricebookEntry standardPricebookEntry = new PricebookEntry(
                Product2Id = products[i].Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                UnitPrice = 100,
                IsActive = true
            );
            standardPricebookEntries.add(standardPricebookEntry);
        }
        insert standardPricebookEntries;

        for(Integer i = 0; i < 5; i++) {
            PricebookEntry pricebookEntry = new PricebookEntry(
                Product2Id = products[i].Id,
                Pricebook2Id = pricebook.Id,
                UnitPrice = 100,
                IsActive = true
            );
            pricebookEntriesToReturn.add(pricebookEntry);
        }
        insert pricebookEntriesToReturn;
        return pricebookEntriesToReturn;
    }

    public static List<OpportunityLineItem> createOpportunityLineItems(Integer numberOfRecords, Boolean isInsert) {
        List<Opportunity> opportunities = createOpportunities(1, true);
        List<PricebookEntry> pricebookEntries = createPricebookEntries();
        List<OpportunityLineItem> opportunityLineItemsToReturn = new List<OpportunityLineItem>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            OpportunityLineItem opportunityLineItem = new OpportunityLineItem(
                OpportunityId = opportunities[0].Id,
                PricebookEntryId = pricebookEntries[i].Id,
                Quantity = 1,
                TotalPrice = 100
            );
            opportunityLineItemsToReturn.add(opportunityLineItem);
        }
        if(isInsert) {
            insert opportunityLineItemsToReturn;
        }
        return opportunityLineItemsToReturn;
    }
}