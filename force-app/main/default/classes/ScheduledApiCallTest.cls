/**
 * @description       : 
 * @author            : @ValeriyPalchenko
 * @last modified on  : 01-06-2023
 * @last modified by  : @ValeriyPalchenko
**/
@isTest
public class ScheduledApiCallTest {

    static testmethod void test() {
        Test.startTest();
     
        // Schedule the test job
        String jobId = System.schedule('testBasicScheduledApex', '0 55 * * * ?', new ScheduledApiCall());
     
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger 
                          WHERE id = :jobId];
     
        // Verify the expressions are the same
        System.assertEquals('0 55 * * * ?', ct.CronExpression);
     
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

    @isTest
    public static void makeSchedualedApiCall() {
        //Given
        Test.setMock(HttpCalloutMock.class, new ScheduledApiCalloutMock());

        //When
        Test.startTest();
        ScheduledApiCall.makeSchedualedApiCall();
        Test.stopTest();

        //Then
        List<Account> accountsToAssert = [SELECT Id
                                         FROM Account
                                         WHERE Name LIKE 'Test%'];
        System.assert(accountsToAssert.size() == 5);
        System.assert(!accountsToAssert.isEmpty());
    }
}