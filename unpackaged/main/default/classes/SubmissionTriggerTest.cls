@isTest
public class SubmissionTriggerTest {
    
    public static testmethod void TestBeforeInsert() {
    	
    	integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(count);
        List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList);

		Test.startTest();
		
		Submissions__c submission = [SELECT Id, Time_Until_Approved__c
					FROM Submissions__c WHERE Id =: submissionList[0].Id];
		System.assertEquals(0, submission.Time_Until_Approved__c);
    	
    	Test.stopTest();
    	
    }
    
    public static testmethod void TestBeforeUpdate() {
    	
    	integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(count);
        List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList, 'Underwriting');

		Test.startTest();

		Submissions__c submission = [SELECT Id, Time_Until_Approved__c
					FROM Submissions__c WHERE Id =: submissionList[0].Id];        
        System.assertEquals(null, submission.Time_Until_Approved__c);
        
		submission.Bank_Status__c = 'Approved';
		update submission;
		
		submission = [SELECT Id, Time_Until_Approved__c
					FROM Submissions__c WHERE Id =: submissionList[0].Id];  
		System.assertEquals(0, submission.Time_Until_Approved__c);
		
		Test.stopTest();
    	
    }
    
     public static testmethod void TestAfterInsert() {
    	
    	integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        oppList[0].StageName = 'Underwriting';
        update oppList;
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(count);
		List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList, 'Declined');
		
		Test.startTest();
		
		Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppList[0].Id];
		System.assertEquals('Underwriting - Declined', opp.StageName);
		
		Test.stopTest();
    	
    }
    
    public static testmethod void TestAfterUpdate() {
    	
    	integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        oppList[0].StageName = 'Underwriting';
        update oppList;
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(count);
		List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList, 'Underwriting');

		Test.startTest();
		
		System.assert(oppList[0].StageName != 'Underwriting - Declined');
		submissionList[0].Bank_Status__c = 'Declined';
		update submissionList;
		Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppList[0].Id];
		System.assertEquals('Underwriting - Declined', opp.StageName);

		Test.stopTest();
    	
    }
    
    public static testmethod void TestAfterDelete() {
    	
    	integer count = 2;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        oppList[0].StageName = 'Underwriting';
        update oppList;
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(2);
        List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList, 'Underwriting');

		Test.startTest();
		
		System.assert(oppList[0].StageName != 'Underwriting - Declined');
		submissionList[0].Bank_Status__c = 'Declined';
		update submissionList;
		delete submissionList[1];
		Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppList[0].Id];
		System.assertEquals('Underwriting - Declined', opp.StageName);
	
		Test.stopTest();
    	
    }
    
}