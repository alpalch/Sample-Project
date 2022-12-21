public without sharing class DataFactory {

    public static List<Opportunity> oppsForOppTriggerHandler(Integer oppCount, Integer conCount) {
        List<Account> accList = new List<Account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> conList = new List<Contact>();

        for(Integer i = 0; i < oppCount; i++){
            Account acc = new Account(
                recordTypeId = Constants.BUYER_RECORD_TYPE_ID,
                Payment__c = 'Wire',
                name = 'test '+ i,
                Phone = '12345'+ i,
                ShippingStreet = 'Test Street',
                ShippingCity = 'Test City',
                ShippingPostalCode = '12345',
                ShippingState = 'New York',
                ShippingCountry = 'United States'
                );
            accList.add(acc);
        }
        insert accList;

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
        Equipment_Category__c equipCategory = new Equipment_Category__c(
            name = 'Test Category', 
            margin__c = 10);
        insert equipCategory;

        Account accVendor = new Account(
            recordTypeId = Constants.VENDOR_RECORD_TYPE_ID,
            Payment__c = 'Wire',
            name = 'Test Account',
            Phone = '12345',
            ShippingStreet = 'Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '12345',
            ShippingState = 'New York',
            ShippingCountry = 'United States'
            );
        insert accVendor;

        Account accBuyer = new Account(
            recordTypeId = Constants.BUYER_RECORD_TYPE_ID,
            Payment__c = 'Wire',
            name = 'Test Account',
            Phone = '12345',
            ShippingStreet = 'Test Street',
            ShippingCity = 'Test City',
            ShippingPostalCode = '12345',
            ShippingState = 'New York',
            ShippingCountry = 'United States'
            );
        insert accBuyer;

        Equipment__c equip = new Equipment__c(
            Account__c = accVendor.id,
            Name = 'Test Equipment',
            Equipment_Category__c = equipCategory.Id,
            Cost__c = 100,
            Description__c = 'Some Desc'
        );
        insert equip;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = accBuyer.Id,
            LeadId__c = '012710000001111111',
            CloseDate = Date.today() + 5,
            StageName = 'Appointment Scheduled'
        );
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
}