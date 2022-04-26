public class NotifyFundersOnUnderwriting {
    
    private static final string adminEmail = 'admin@emcfinancial.com';
    
    private Id Id {get; set;}
    public Opportunity opp {get; set;}
    private List<string> ccEmails;
    public List<string> succesedEmails {get; set;}
    public List<string> failedEmails {get; set;}
    public List<SubmissionWrapper> submissions{get;set;}
    
    public Boolean afterSending{get;set;}
    
    public NotifyFundersOnUnderwriting(Id id) {
        this.Id = id;
		opp = [SELECT Id, Name, Account.Name,
               	Owner.Email,
               (SELECT Id, Bank_Status__c,
                Created_Date__c,
                Funder_Email__c, Funder__r.Name,
                Funder_Additional_Email_1__c,
                Funder_Additional_Email_2__c,
                Funder__r.Contact_Email__c,
                Funder__r.Additional_Email_1__c,
                Funder__r.Additional_Email_2__c
                FROM Submissions__r WHERE Bank_Status__c = 'Underwriting')
                FROM Opportunity WHERE Id=:Id];
        setSubmissions();
        afterSending = false;
        succesedEmails = new List<string>();
        failedEmails = new List<string>();
        ccEmails = new List<string> {adminEmail};
        if(opp.Owner.Email != adminEmail) {
        	ccEmails.Add(opp.Owner.Email);
        }
    }
    
    public NotifyFundersOnUnderwriting(ApexPages.StandardController controller) {
        this(((Opportunity) controller.getRecord()).Id);
    }
   
    public void notifyFunders() {
        Boolean atLeastOneEmailChecked = false;
        for(submissionWrapper sw: submissions) {
            atLeastOneEmailChecked |= sw.toSend;
            if(sw.toSend) {
                Messaging.SendEmailResult result = sw.sendMail(opp.Account.Name, ccEmails);
                if (result.success) {
                    if(sw.funderName != null) {
                        succesedEmails.Add(sw.funderName);    
                    }
                } else {
                    if(sw.funderName != null) {
                        failedEmails.Add(sw.funderName);
                    }
                    System.debug('The email failed to send: ' + result.errors[0].message);
                }
            }
        }
        if(atLeastOneEmailChecked)
        	afterSending = true;
    }
    
    @TestVisible
    private void setSubmissions() {
        submissions = new List<SubmissionWrapper>();
        for(Submissions__c s:opp.Submissions__r) {
            Integer hoursFromCreation = getHoursUntilNow(s.Created_Date__c);
            List<String> contacts = getSubmissionContacts(s);
            Boolean toSend = hoursFromCreation > 0 ? true : false;
            SubmissionWrapper sw = new SubmissionWrapper(s.Funder__r.Name, hoursFromCreation, contacts, toSend);
            submissions.Add(sw);
        }
    }
    
    @TestVisible
    private List<String> getSubmissionContacts(Submissions__c s) {
        List<String> contacts = new List<string>();
        if(s.Funder_Email__c != null && !contacts.Contains(s.Funder_Email__c)) {
            contacts.Add(s.Funder_Email__c);
        }
        if(s.Funder__r.Contact_Email__c != null && !contacts.Contains(s.Funder__r.Contact_Email__c)) {
            contacts.Add(s.Funder__r.Contact_Email__c);
        }
        if(s.Funder__r.Additional_Email_1__c != null && !contacts.Contains(s.Funder__r.Additional_Email_1__c)) {
            contacts.Add(s.Funder__r.Additional_Email_1__c);
        }
        if(s.Funder__r.Additional_Email_2__c != null && !contacts.Contains(s.Funder__r.Additional_Email_2__c)) {
            contacts.Add(s.Funder__r.Additional_Email_2__c);
        }
        return contacts;
    }
    
    @TestVisible
    private Integer getHoursUntilNow(DateTime createdTime) {
        Long millisecondsUntilNow = datetime.now().getTime() - createdTime.getTime();
        Integer hoursUntilNow = Integer.valueOf(millisecondsUntilNow / 1000 / 60 / 60);
        return hoursUntilNow;
	}
    
    class SubmissionWrapper {
        
        SubmissionWrapper(String funderName, Integer hoursFromCreation, List<String> contacts, Boolean toSend) {
            this.funderName = funderName;
            this.hoursFromCreation = hoursFromCreation;
            this.contacts = contacts;
            this.toSend = toSend;
        }
        public String funderName {get;set;}
        public Integer hoursFromCreation {get;set;}
        public List<String> contacts {get;set;}
        public Boolean toSend {get;set;}
        
        @TestVisible
        private Messaging.SendEmailResult sendMail(string accountName, List<String> ccEmails) {
 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = this.contacts;
            message.subject = 'New Deal - ' + accountName;
            message.setHtmlBody(getHTMLBody());
            message.setSaveAsActivity(false);
            message.setUseSignature(true);
            message.setCcAddresses(ccEmails);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            return results[0];
        }
        
        @TestVisible
        private string getHTMLBody() {
            string body = '<html><head></head><body><table width="500" align="center" style="font-size:18px;">' + 
            '<tr valign="top"><td style="vertical-align:top;height:90;text-align:left"><img border="0" src="https://na77.salesforce.com/servlet/servlet.ImageServer?id=015G0000005rjSq&amp;oid=00DA0000000Z1Fx"></td></tr>' +
            '<div style="font-size:12pt"><font face="arial">&nbsp;</font></div>' +
            '<tr><td>Hi <span style="font-weight:bold;">' + this.funderName + '</span>,' + 
            '<br/><br/>It was been <span style="font-weight:bold;">' + this.hoursFromCreation + ' ' + (this.hoursFromCreation == 1 ? 'hour' : 'hours') + '</span> since our initial submission of this file.  Please provide a status of this submission as soon as possible.' +
            '<br/><br/>Thank you,' +
            '<br/><br/>EMC Financial</td></tr></table></body></html>';
            return body;
    	}
    }
}