@isTest
public class testSendEmailWithBoxFiles {
    
    public static testMethod void testSendEmailWithBoxFiles() {
    	
    	Opportunity opp = new Opportunity();
		opp.Name = 'test oppotunity';
		opp.StageName = 'Application In';
		opp.CloseDate = Date.today().addDays(7);
		insert opp;
		
		Funder__c funder = new Funder__c();
		funder.Name = 'test funder';
    	insert funder;
    	
    	Funder__c funder2 = new Funder__c();
    	funder2.Name = 'test funder';
		insert funder2;
		
		Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Auth_Endpoint__c = '';
        boxAuthObj.Auth_Token__c = '1234567890';
        boxAuthObj.Refresh_Token__c = '1234567890';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = '12345';
        boxAuthObj.Client_Secret__c  = '12345';
        insert boxAuthObj;
		
		Set<Id> funderIdSet = new Set<Id>{funder.Id, funder2.Id};
	    
	    List<FolderItems.Entry> entryList = new List<Folderitems.Entry>();
	    entryList.add(new FolderItems.Entry('file', '111', '0', 'test file', 'a test file', 2000000));
	    entryList.add(new FolderItems.Entry('file', '222', '0', 'test file', 'a test file', 3000000));
	    
        Test.startTest();        
        System.enqueueJob(new SendEmailWithBoxFiles(opp.Id, funderIdSet, entryList, 'test note', 1, 1));
        Test.stopTest();
        
    }
    
}