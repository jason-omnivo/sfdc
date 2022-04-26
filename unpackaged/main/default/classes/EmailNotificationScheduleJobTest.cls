@istest
public with sharing class EmailNotificationScheduleJobTest {
    
	public static String CRON_EXP = '0 0 0 18 6 ? 2020';
    public static testMethod void testSchedule() {
       
        integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
    	Opportunity opp = oppList[0];
    	opp.Email__c = 'test@test.co.il';
    	update opp;

    	Scheduled_Notification__c sn = new Scheduled_Notification__c();
    	sn.Opportunity__c = opp.Id;
        sn.Notification_Date__c = Date.today();
        insert sn;
    	
        Test.startTest();

        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new EmailNotificationScheduleJob());
        
        Test.stopTest();       
		
    }
    
}