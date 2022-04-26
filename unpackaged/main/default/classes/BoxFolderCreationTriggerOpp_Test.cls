@isTest
public class BoxFolderCreationTriggerOpp_Test {
    
    static testMethod void insertNewOpportunity() {

		Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
		boxAuthObj.Auth_Endpoint__c = '';
		boxAuthObj.Auth_Token__c = '1234567890';
		boxAuthObj.Refresh_Token__c = '1234567890';
		boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
		boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
		boxAuthObj.Client_Id__c = '12345';
		boxAuthObj.Client_Secret__c  = '12345';
		insert boxAuthObj;

       	Account a = new Account();
		a.Name='Test Account';
        a.DBA_Name__c='DBA Name';
 		insert a;

		Opportunity opp=new Opportunity();
		opp.Name='Test Oppty';
		Opp.StageName='Prospecting';
		opp.CloseDate=system.today();
		opp.Accountid=a.id;
		insert opp;

    }

}