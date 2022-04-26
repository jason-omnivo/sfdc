@IsTest
public class OpportunityStageChangeTSManagerTest {
    
    static testmethod void test() {
    	
		Utils.now = DateTime.now();
		DateTime prevTime = null;
		
		integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        List<Funder__c> funderList = TestDataGenerator.createFunderlist(count);
        List<Submissions__c> submissionList = TestDataGenerator.createSubmissionList(oppList, funderList);

        Test.startTest();
        
        Opportunity opp = [SELECT Id, Application_In_Date_Time__c FROM Opportunity WHERE Id =: oppList[0].Id];
        System.assertEquals(opp.Application_In_Date_Time__c, Utils.now);
		
		prevTime = Utils.now;
		Utils.now = DateTime.now().addDays(1);
		opp.StageName = 'Application Missing Info';
		opp.Other_Missing_Application_Information__c = 'Test';
		update opp;
        opp = [SELECT Id, Application_Missing_Info_Date_Time__c, Time_From_App_In_To_App_Missing_Info__c
						FROM Opportunity WHERE Id =: opp.Id];
		System.assertEquals(opp.Application_Missing_Info_Date_Time__c, Utils.now);
		System.assertEquals(opp.Time_From_App_In_To_App_Missing_Info__c, Utils.calculateBH(prevTime, Utils.now));
		
		
		Utils.now = DateTime.now().addDays(2);
		opp.StageName = 'Ready to Submit';
		update opp;
        opp = [SELECT Id, Application_In_Date_Time__c, Ready_To_Submit_Date_Time__c,
        				Time_From_App_In_To_App_Ready_To_Submit__c FROM Opportunity WHERE Id =: opp.Id];
		System.assertEquals(opp.Ready_To_Submit_Date_Time__c, Utils.now);
		System.assertEquals(opp.Time_From_App_In_To_App_Ready_To_Submit__c,
								Utils.calculateBH(opp.Application_In_Date_Time__c, Utils.now));
		
		Test.stopTest();
        
    } 
    
}