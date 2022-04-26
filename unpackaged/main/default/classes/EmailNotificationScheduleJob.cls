global class EmailNotificationScheduleJob implements Schedulable {
    
   global void execute(SchedulableContext SC) {
       
       List<Scheduled_Notification__c> snList =
           [SELECT Id, Notification_Date__c, Opportunity__c, Notification_Sent__c
           FROM Scheduled_Notification__c WHERE Notification_Date__c <= : Date.today() AND Notification_Sent__c = False];
       List<Id> oppIdList = new List<Id>();
       
       for(Scheduled_Notification__c sn : snList) {
           oppIdList.add(sn.Opportunity__c);
       }
       
       Map<Id, Opportunity> idToOppMap=
           new Map<Id, Opportunity>([SELECT Id, Owner.Email, Cell_Phone__c, Email__c,
                                     First_Name__c, Last_Name__c, Account.Name
                                     FROM Opportunity WHERE Id IN : oppIdList]);
       String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
       String accountName;
       String fullName;
       String cellPhone;
       String email;
       String opportunityUrl;
       
        OrgWideEmailAddress[] owea = null;
        if(!runningInASandbox()) {
			owea = [select Id from OrgWideEmailAddress where Address = 'admin@emcfinancial.com'];
		} else {
			owea = [select Id from OrgWideEmailAddress where Address = 'yariv.ivry@gmail.com'];
		}
		
        EmailTemplate template = [SELECT Id, Body, Subject, HTMLValue
                                  FROM EmailTemplate WHERE Name='Opportunity Email Notification'];
		for(Scheduled_Notification__c sn : snList){
            
            List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
            Opportunity opp = idToOppMap.get(sn.Opportunity__c);
            
            accountName = opp.Account.Name;
            fullName = (opp.First_Name__c != null ? opp.First_Name__c : '') + ' ' + (opp.Last_Name__c != null ? opp.Last_Name__c : '');
            cellPhone = opp.Cell_Phone__c != null ? opp.Cell_Phone__c : '';
            email = opp.Email__c != null ? opp.Email__c : '';
            opportunityUrl = baseUrl + '/' + opp.Id;

            String emailBody = String.valueOf(template.HTMLValue);
            emailBody = emailBody.replace('<![CDATA[', '');
            emailBody = emailBody.replace('{!ACCOUNT}', accountName);
            emailBody = emailBody.replace('{!FULL_NAME}', fullName);
            emailBody = emailBody.replace('{!CELL_PHONE}', cellPhone);
            emailBody = emailBody.replace('{!EMAIL}', email);
            emailBody = emailBody.replace('{!OPPORTUNITY_URL}', opportunityUrl);
            emailBody = emailBody.replace(']]>', '');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            if (owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            
            System.debug(emailBody);
            String emailSubject = String.valueOf(template.Subject);
            emailSubject = emailSubject.replace('{!ACCOUNT}', accountName);
            emailSubject = emailSubject.replace('{!CELL_PHONE}', cellPhone);
            System.debug(emailSubject);
            mail.setHTMLBody(emailBody);
            mail.setSubject(emailSubject);
            
            System.debug(opp.Owner.Email);
            List<String> targets = new List<String>();
            if(!runningInASandbox()) {
                if(opp.Owner.Email != null){
                    targets.add(opp.Owner.Email);
                }
            } else {
                targets.add(Label.DeveloperEmail);	
            }
            
            mail.setToAddresses(targets);
            emailsToSend.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            for(Messaging.SendEmailResult result : results) {
              	Messaging.SendEmailError[] errorList = result.getErrors();
                if(errorList != null && errorList.size() > 0) {
                    System.debug(errorList[0].getMessage());
                }  else {
                    sn.Notification_Sent__c = true;
                    update sn;
                }
            }
            
		}

   }
   
   public Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
	    
}