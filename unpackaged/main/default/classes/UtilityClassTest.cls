@isTest
public class UtilityClassTest {
    @isTest
    public static void test1(){
        UtilityClass.sendErrorMail('Box Setting Missing', 'First Connect With Box','User Unable to upload Files', 'Information');  
        
    }
    @isTest
    public static void test2(){
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = Date.today();
        opp.AccountId = acc.Id;
        insert opp;
    }
}