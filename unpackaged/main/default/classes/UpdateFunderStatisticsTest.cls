@isTest
public class UpdateFunderStatisticsTest {
    
    public static String CRON_EXP = '0 0 0 18 6 ? 2020';
    public static testmethod void testSchedule() {
    	
    	integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(count);
        List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList);
        
       
        Test.startTest();

        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new UpdateFunderStatistics());
        
        Funder__c funder = [SELECT Id, Approval_Time_In_Hours__c
							FROM Funder__c
							WHERE Id =: funderList[0].Id];
									
        System.assertEquals(null,funder.Approval_Time_In_Hours__c);

        Test.stopTest();
        
        funder = [SELECT Id, Approval_Time_In_Hours__c
							FROM Funder__c
							WHERE Id =: funderList[0].Id];
							
		Submissions__c submission = [SELECT Id, Time_Until_Approved__c
									FROM Submissions__c
									WHERE Id =: submissionList[0].Id];
									
        System.assertEquals(submission.Time_Until_Approved__c, funder.Approval_Time_In_Hours__c);
		
    }
    
}