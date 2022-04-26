@istest
public with sharing class ScheduleNotificationExtensionTest {
    
    Static testmethod void TestTwoWeeks(){    
		
		integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
    	Opportunity opp = oppList[0];
    	
    	Test.startTest();
    	 
        PageReference pageRef = Page.Schedule_Email;
        pageRef.getparameters().put('recordId', opp.Id);  
        Test.setCurrentPage(pageRef);
        
        Apexpages.StandardController standardController = new Apexpages.StandardController(opp);
        ScheduleNotificationExtension scheduleNotificationExtension = new  ScheduleNotificationExtension(standardController);     
        scheduleNotificationExtension.notifyTwoWeeks();

        Test.stopTest();      
    }
    
      Static testmethod void TestOneMonth(){    
		
		integer count = 1;
        List<Account> accountList = TestDataGenerator.createAccountList(count);
        List<Contact> contactList = TestDataGenerator.createContactList(accountList);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
    	Opportunity opp = oppList[0];
    	
    	Test.startTest();
    	 
        PageReference pageRef = Page.Schedule_Email;
        pageRef.getparameters().put('recordId', opp.Id);  
        Test.setCurrentPage(pageRef);
        
        Apexpages.StandardController standardController = new Apexpages.StandardController(opp);
        ScheduleNotificationExtension scheduleNotificationExtension = new  ScheduleNotificationExtension(standardController);     
        scheduleNotificationExtension.notifyOneMonth();

        Test.stopTest();      
    }
    
}