public without sharing class TestDataFactory {

    // Method for the future
    // public static List<Account> createMultipleVendorAccounts(Integer accNumber){
    //     List<Account> accList = new List<Account>();
    //     for(Integer i = 0; i < accNumber; i++){
    //         Account acc = new Account(
    //             recordTypeId = Constants.VENDOR_RECORD_TYPE_ID,
    //             Payment__c = 'Wire',
    //             Name = 'test '+ i,
    //             Phone = '12345'+ i,
    //             BillingStreet = 'Test Street',
    //             BillingCity = 'Test City',
    //             BillingPostalCode = '12345',
    //             BillingState = 'New York',
    //             BillingCountry = 'United States'
    //             );
    //         accList.add(acc);
    //     }
    //     return accList;
    // }

    public static Account createVendorAccount(){
        
        Account acc = new Account(
            recordTypeId = Constants.VENDOR_RECORD_TYPE_ID,
            Payment__c = 'Wire',
            Name = 'test ',
            Phone = '12345',
            BillingStreet = 'Test Street',
            BillingCity = 'Test City',
            BillingPostalCode = '12345',
            BillingState = 'New York',
            BillingCountry = 'United States'
            );
        return acc;
    }

    public static Account createBuyerAccount(){
        
        Account acc = new Account(
            recordTypeId = Constants.BUYER_RECORD_TYPE_ID,
            Payment__c = 'Wire',
            Name = 'test ',
            Phone = '12345',
            ShippingStreet = 'Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States',
            ShippingState = 'New York'
            );
        return acc;
    }

    public static List<Account> createMultipleBuyerAccounts(Integer accNumber){
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < accNumber; i++){
            Account acc = new Account(
                recordTypeId = Constants.Buyer_RECORD_TYPE_ID,
                Payment__c = 'Wire',
                Name = 'test '+ i,
                Phone = '12345'+ i,
                ShippingStreet = 'Test Street',
                ShippingCity = 'Test City',
                ShippingPostalCode = '12345',
                ShippingState = 'New York',
                ShippingCountry = 'United States'
                );
            accList.add(acc);
        }
        return accList;
    }

    public static List<Equipment_Category__c> createMultipleEquipmentCategory(Integer catNumber){
        List<Equipment_Category__c> listToReturn = new List<Equipment_Category__c>();
        for(Integer i = 0; i < catNumber; i++){
            Equipment_Category__c ec = new Equipment_Category__c();
            ec.Name = 'Test ' + i;
            ec.Margin__c = 5;
            listToReturn.add(ec);
        }
        return listToReturn;
    }

    public static Equipment_Category__c createEquipmentCategory(){
            Equipment_Category__c ec = new Equipment_Category__c();
            ec.Name = 'Test';
            ec.Margin__c = 10; 
        return ec;
    }

    public static Equipment__c createEquipment(){
        Account acc = createVendorAccount();
        insert acc;
        Equipment_Category__c eq = createEquipmentCategory();
        insert eq;
        Equipment__c equip = new Equipment__c(
            Account__c = acc.Id,
            Equipment_Category__c = eq.Id,
            Name = 'Test',
            Description__c = 'Test',
            Cost__c = 10
        );
        return equip;
    }

    public static List<Equipment__c> createMultipleEquipment(Integer equipNumber){
        Account acc = createVendorAccount();
        insert acc;
        Equipment_Category__c eq = createEquipmentCategory();
        insert eq;
        List<Equipment__c> listToReturn = new List<Equipment__c>();
        for(Integer i = 0; i < equipNumber; i++){
            Equipment__c equip = new Equipment__c(
                Account__c = acc.Id,
                Equipment_Category__c = eq.Id,
                Name = 'Test',
                Description__c = 'Test',
                Cost__c = 10
            );
            listToReturn.add(equip);
        }
        return listToReturn;
    }

    public static List<Opportunity> createMultipleOpportunity(Integer oppNumber){
        Account acc = createBuyerAccount();
        insert acc;
        List<Opportunity> listToReturn = new List<Opportunity>();
        for(Integer i = 0; i < oppNumber; i++){
            Opportunity opp = new Opportunity(
                Name = 'testOpp ' + i,
                StageName = 'Preparing Proposal',
                CloseDate = Date.today() + 14,
                AccountId = acc.Id,
                LeadId__c = '123456789012345678'
            );
            listToReturn.add(opp);
        }
        return listToReturn;
    }

    public static Opportunity createOpportunity(){
        Account acc = createBuyerAccount();
        insert acc;
        Opportunity oppToReturn = new Opportunity(
            Name = 'testOpp ',
            StageName = 'Preparing Proposal',
            CloseDate = Date.today() + 14,
            AccountId = acc.Id,
            LeadId__c = '123456789012345678'
            );
        return oppToReturn;
    }

    public static List<Opportunity> oppsForOppTriggerHandler(Integer oppCount, Integer conCount) {
        List<Account> accList = createMultipleBuyerAccounts(oppCount);
        insert accList;
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> conList = new List<Contact>();

        for(Account acc :accList){
            Opportunity opp = new Opportunity(
                name = 'testOpp',
                StageName = 'Preparing Proposal',
                CloseDate = Date.today() + 14,
                AccountId = acc.Id
            );
            oppList.add(opp);
            for(Integer i = 0; i < conCount; i++){
                Contact con = new Contact(
                    LastName = 'Test'+ i,
                    Email = 'test'+ i +'@gmail.com',
                    AccountId = acc.ID
                );
                conList.add(con);
            }
        }
        insert conList;
        insert oppList;

        return oppList;      
    }

    public static List<Proposal_Equipment__c> propEquipForProposalEquipmentHandler (Integer propEquipCount){

        Equipment__c equip = createEquipment();
        insert equip;

        Opportunity opp = createOpportunity();
        insert opp;

        Proposal__c prop= new Proposal__c(Opportunity__c = opp.Id);
        insert prop;

        List<Proposal_Equipment__c> listToInsert = new List<Proposal_Equipment__c>();
        for (Integer i = 0; i < propEquipCount; i++){
            Proposal_Equipment__c propEquip = new Proposal_Equipment__c(
                proposal__c = prop.Id,
                Equipment__c = equip.Id,
                name = 'Test',
                Quantity__c = 2,
                cost__c = 0,
                margin__c = 0
            );
            listToInsert.add(propEquip);
        }
        return listToInsert;
    }

    public static Proposal__c createProposal(){
        Opportunity opp = createOpportunity();
        insert opp;
        Proposal__c propToReturn = new Proposal__c(
            Opportunity__c = opp.Id,
            Status__c = 'Draft'
        );
        return propToReturn;
    }

    public static List<Proposal__c> createMultipleProposal(Integer proposalNumber){
        Opportunity opp = createOpportunity();
        insert opp;
        List<Proposal__c> listToReturn = new List<Proposal__c>();
        for(Integer i = 0; i < proposalNumber; i++){
            Proposal__c prop = new Proposal__c(
                Status__c = 'Draft',
                Opportunity__c = opp.Id
            );
            listToReturn.add(prop);
        }
        return listToReturn;
    }

    public static Proposal_Equipment__c createProposalEquipment(){
        Proposal__c prop = createProposal();
        insert prop;
        Equipment__c equip = createEquipment();
        insert equip;
        Proposal_Equipment__c eqToReturn = new Proposal_Equipment__c(
            Name = 'Test',
            Proposal__c = prop.Id,
            Equipment__c = equip.Id
        );
        return eqToReturn;
    }

    public static Contact createContact(){
        Account acc = createBuyerAccount();
        insert acc;

        Contact contactToReturn = new Contact(
            LastName = 'Doe',
            Email = 'test@test.com',
            AccountId = acc.Id
        );
        return contactToReturn;
    }

    public static OpportunityContactRole createOCR(){
        Opportunity opp = createOpportunity();
        insert opp;
        Contact con = createContact();
        insert con;

        OpportunityContactRole ocrToReturn = new OpportunityContactRole(
            OpportunityId = opp.Id,
            ContactId = con.Id,
            IsPrimary = true
        );

        return ocrToReturn;
    }
}