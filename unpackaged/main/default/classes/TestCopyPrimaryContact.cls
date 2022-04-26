@isTest

private class TestCopyPrimaryContact {
  static testMethod void test() {
    Account a = new account(Name='Fake Account', DBA_Name__c='Fluffy Flap', Legal_Name__c='Fluffy Flap');
    insert a;
    Contact c = new Contact(AccountId=a.id,LastName='Daikoku');
    insert c;
    Opportunity o = new Opportunity(AccountId=a.id,Name='Test Opp',CloseDate=System.today(),StageName='Application In');
    insert o;
    OpportunityContactRole ocr = new OpportunityContactRole(opportunityid=o.id,contactid=c.id,IsPrimary=true,Role='Business Owner');
    insert ocr;
    Test.startTest();
    update o;
    Test.stopTest();
    o = [select id,Primary_Contact__c from opportunity where id = :o.id];
    
  }
}