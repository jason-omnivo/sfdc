@istest
public with sharing class EmailCollectionControllerTest {
	
	Static testmethod void Test(){    
		
		Lead lead = ActivityCountHandlerTest.createLeadRecord();
		lead.Email = 'test@test.com';
    	insert lead;
    	
        PageReference pageRef = Page.Email_Collection;
        pageRef.getparameters().put('recordId', lead.Id);  
        Test.setCurrentPage(pageRef);
        
        Apexpages.StandardController standardController = new Apexpages.StandardController(lead);
        EmailCollectionController emailCollectionController = new  EmailCollectionController(standardController);
        emailCollectionController.emailCollection.NewEmail__c = 'test100@test.com';      
        emailCollectionController.CreateEmailCollection();      
    }
    
	Static testmethod void TestBlankEmail(){    
		
		Lead lead = ActivityCountHandlerTest.createLeadRecord();
    	insert lead;
    	
        PageReference pageRef = Page.Email_Collection;
        pageRef.getparameters().put('recordId', lead.Id);  
        Test.setCurrentPage(pageRef);
        
        Apexpages.StandardController standardController = new Apexpages.StandardController(lead);
        EmailCollectionController emailCollectionController = new  EmailCollectionController(standardController);         
        emailCollectionController.CreateEmailCollection();      
    }
    
    Static testmethod void TestSameEmail(){    
		
		Lead lead = ActivityCountHandlerTest.createLeadRecord();
		lead.Email = 'test@test.com';
    	insert lead;
    	
        PageReference pageRef = Page.Email_Collection;
        pageRef.getparameters().put('recordId', lead.Id);  
        Test.setCurrentPage(pageRef);
        
        Apexpages.StandardController standardController = new Apexpages.StandardController(lead);
        EmailCollectionController emailCollectionController = new  EmailCollectionController(standardController);
        emailCollectionController.emailCollection.NewEmail__c = 'test@test.com';      
        emailCollectionController.CreateEmailCollection();      
    }
    
    Static testmethod void TestUncheckGiveCommission(){    
		
		Lead lead = ActivityCountHandlerTest.createLeadRecord();
		lead.Email = 'test@test.com';
    	insert lead;
    	
    	EmailCollection__c emailCollection = new EmailCollection__c();
		emailCollection.OwnerId = UserInfo.getUserId();
        emailCollection.Lead__c =lead.Id;
        emailCollection.Email_Collection_Type__c = 'New Email';
        emailCollection.OldEmail__c = 'test1@test.com';
        emailCollection.NewEmail__c = 'test2@test.com';
        insert emailCollection;
    	
    	
        PageReference pageRef = Page.Uncheck_Give_Commission;
        pageRef.getparameters().put('eci', emailCollection.Id);  
        Test.setCurrentPage(pageRef);
        
        EmailCollectionController emailCollectionController = new  EmailCollectionController();     
        emailCollectionController.uncheckGiveCommission();
        
        emailCollection = [SELECT Id, GiveCommission__c FROM EmailCollection__c WHERE Id = :emailCollection.Id];
        System.assertEquals(false, emailCollection.GiveCommission__c);
        
    }
    
    Static testmethod void TestUncheckGiveCommissionWrongParameter(){    
		
		Lead lead = ActivityCountHandlerTest.createLeadRecord();
		lead.Email = 'test@test.com';
    	insert lead;
    	
    	EmailCollection__c emailCollection = new EmailCollection__c();
		emailCollection.OwnerId = UserInfo.getUserId();
        emailCollection.Lead__c =lead.Id;
        emailCollection.Email_Collection_Type__c = 'New Email';
        emailCollection.OldEmail__c = 'test1@test.com';
        emailCollection.NewEmail__c = 'test2@test.com';
        insert emailCollection;
    	
    	
        PageReference pageRef = Page.Uncheck_Give_Commission;
        pageRef.getparameters().put('eci', emailCollection.Id);  
        Test.setCurrentPage(pageRef);
        
        EmailCollectionController emailCollectionController = new  EmailCollectionController();     
        emailCollectionController.uncheckGiveCommission();
        
        emailCollection = [SELECT Id, GiveCommission__c FROM EmailCollection__c WHERE Id = :emailCollection.Id];
        System.assertEquals(false, emailCollection.GiveCommission__c);
        
    }
    
}