global without sharing class Constants {
    global static final String BUYER_RECORD_TYPE_NAME = 'Buyer';
    global static final String VENDOR_RECORD_TYPE_NAME = 'Vendor';
    global static final Id BUYER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(BUYER_RECORD_TYPE_NAME).getRecordTypeId();
    global static final Id VENDOR_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(VENDOR_RECORD_TYPE_NAME).getRecordTypeId();
}