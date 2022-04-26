@isTest
public class NotifyFundersOnUnderwritingTest {
    
    static Funder__c f;
    static Account act;
    static Opportunity opp;
	static Submissions__c s;    
	static NotifyFundersOnUnderwriting n;
    
    static void setData() {
         f = new Funder__c(name = 'Funder Test');
        f.Contact_Email__c = 'test@test.com';
        f.Additional_Email_1__c = 'test1@test.com';
        f.Additional_Email_2__c = 'test2@test.com';
        insert f;
        
        act = new Account();
        act.Name = 'Account test';
        
        opp = new Opportunity();
        opp.Name = 'Test name';
        opp.AccountId = act.Id;
        opp.StageName = 'Stage name test';
        opp.CloseDate = Date.Today();
        insert opp;
        
        s = new Submissions__c();
        s.Funder_Email__c = 'test@test.com';
        s.Funder__c = f.Id;
   	    s.Funder_Additional_Email_1__c = 'test1@test.com';
        s.Funder_Additional_Email_2__c = 'test2@test.com';
        s.Bank_Status__c = 'Underwriting';
        s.Opportunity__c = opp.Id;
        insert s;
		
        n = new NotifyFundersOnUnderwriting(opp.Id);
    }
    
    @isTest
    static void testNotifyFunder() {
        if(opp == null)
            setData();
        
        n.notifyFunders();
    }
    
    @isTest
    static void testGetHTMLBody() {
        if(opp == null)
            setData();
        
        string bodyTest = '<html><head></head><body><table width="500" align="center" style="font-size:18px;">' + 
            '<tr valign="top"><td style="vertical-align:top;height:90;text-align:left"><img border="0" src="https://na77.salesforce.com/servlet/servlet.ImageServer?id=015G0000005rjSq&amp;oid=00DA0000000Z1Fx"></td></tr>' +
            '<div style="font-size:12pt"><font face="arial">&nbsp;</font></div>' +
            '<tr><td>Hi <span style="font-weight:bold;">' + f.name + '</span>,' + 
            '<br/><br/>It was been <span style="font-weight:bold;">' + '0' + ' ' + (0 == 1 ? 'hour' : 'hours') + '</span> since our initial submission of this file.  Please provide a status of this submission as soon as possible.' +
            '<br/><br/>Thank you,' +
            '<br/><br/>EMC Financial</td></tr></table></body></html>';
        
        string body = n.submissions[0].getHTMLBody();
        System.assertEquals(bodyTest, body);
    }
    
    @isTest
    static void testTetHoursUntilNow() {
        if(opp == null)
            setData();
        
        Integer hours = 4;
        DateTime arbitraryDate = DateTime.Now().addHours(-hours);
        Integer hoursUntilNow = n.getHoursUntilNow(arbitraryDate);
        System.assertEquals(hours, hoursUntilNow);
    }
        
    @isTest
    static void testSendMail() {
        if(opp == null)
            setData();
        Messaging.SendEmailResult result = n.submissions[0].sendMail(act.name, new List<string>());
        System.assert(result.isSuccess());
    }
}