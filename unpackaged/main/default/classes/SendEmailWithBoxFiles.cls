public class SendEmailWithBoxFiles implements Queueable, Database.AllowsCallouts {
	
	Id oppId;
	Set<Id> funderIdSet;
	String note;
	List<FolderItems.Entry> entries;
	Opportunity opp;
	EmailTemplate template;
	List<OrgWideEmailAddress> owea;
	Integer emailNumber;
	Integer totalEmails;
	Box_OAuth__c authInfo;
	public transient List<Messaging.Emailfileattachment> emailAttachmentList;
	
	public SendEmailWithBoxFiles(Id oppId, Set<Id> funderIdSet, List<FolderItems.Entry> entries, String note, Integer emailNumber, Integer totalEmails) {
		this.oppId = oppId;
		this.funderIdSet = funderIdSet;
		this.entries = entries;
		this.note = note;
		this.emailNumber = emailNumber;
		this.totalEmails = totalEmails;
		this.authInfo = BoxAuth.authInfo;
	}
	
    public void execute(QueueableContext context) {
		System.debug('SendEmailWithBoxFiles: ' + 1);
		try {
			System.debug('SendEmailWithBoxFiles: ' + 2);
	 		this.emailAttachmentList = new List<Messaging.Emailfileattachment>();
	 		System.debug('SendEmailWithBoxFiles: ' + 3);
	 		opp = [Select Id, Owner.Email, Account.Name, Owner.UserRole.DeveloperName, Owner.Admin_Email__c
					From Opportunity Where Id =:this.oppId];
	 		System.debug('SendEmailWithBoxFiles: ' + 4);
	 		template = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate WHERE Name='Funder Notification With Attachment'];   
			System.debug('SendEmailWithBoxFiles: ' + 5);

			String userRoleName = opp.Owner.UserRole.DeveloperName;

			if ( userRoleName == 'Manager_Aiden_s_Team' || userRoleName == 'Sales_Reps_Aiden_s_Team') {
				owea = [select Id from OrgWideEmailAddress where Address = 'emc2@emcfinancial.com'];
			} else {
				owea = [select Id from OrgWideEmailAddress where Address = 'admin@emcfinancial.com'];
			}

			System.debug('SendEmailWithBoxFiles: ' + 6);
			Messaging.Emailfileattachment emailAttachment = null;
			//for(String boxFileId : this.boxFileIdList) {
			System.debug('SendEmailWithBoxFiles: ' + 7);
			for(FolderItems.Entry entry : this.entries) {
				emailAttachment = createAttachmentFromLink(entry.id, entry.name);
				if(emailAttachment != null) {
					this.emailAttachmentList.add(emailAttachment);
				}
			}
			System.debug('SendEmailWithBoxFiles: ' + 8);
			List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
	 		for(Funder__C funder : [Select Id, Contact_Name__c, Contact_Email__c,
	 								Additional_Email_1__c, Additional_Email_2__c, Portal_Lender_None_API__c
									From Funder__c WHERE Id IN :this.funderIdSet]) {
	    		emailsToSend.add(createEmail(funder));            
	    	}
	    	System.debug('SendEmailWithBoxFiles: ' + 9);
	    	Messaging.sendEmail(emailsToSend);
		} catch(Exception ex) {
			System.debug(ex.getMessage());
			System.debug(ex.getStackTraceString());
		} finally {			
			//BoxAPIv2.upsertAuthInfoSync();
		}
    }
    
    private Messaging.Emailfileattachment createAttachmentFromLink(String boxFileId, String boxFileName) {

    	String endpoint = 'https://api.box.com/2.0/files/';
    	endpoint =  endpoint + boxFileId + '/content';
    	
		System.debug('image content url: ' + endpoint);
		HTTP h = new HTTP();
		HTTPRequest request = new HTTPRequest();
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		request.setHeader('Authorization', 'Bearer ' + this.authInfo.Auth_Token__c);
		HTTPResponse resp = h.send(request);
		
		Messaging.Emailfileattachment emailAttachment = new Messaging.Emailfileattachment();
		String downloadUrl = '';
		System.debug('resp.getStatusCode(): ' + resp.getStatusCode());
		
		if(resp.getStatusCode() == 302){
			downloadUrl = resp.getHeader('Location');
			System.debug('downloadUrl 1: ' + downloadUrl);
			if(downloadUrl == null || downloadUrl == '')
				downloadUrl = resp.getHeader('location');
		}
		if(downloadUrl == null || downloadUrl == '') {
			downloadUrl = endpoint;
			System.debug('downloadUrl 2: ' + downloadUrl);
		}
		
		HTTPRequest request2 = new HTTPRequest();
	    request2.setEndpoint(downloadUrl);
	    request2.setMethod('GET');
	    request2.setHeader('Authorization', 'Bearer ' + this.authInfo.Auth_Token__c);
	    emailAttachment.contentType = 'application/octet-stream';
	    emailAttachment.setFileName(boxFileName);
	    HTTPResponse resp2 = h.send(request2);
	    Blob blobObj = resp2.getBodyAsBlob();
	    System.debug('size: ' + blobObj.size());
	    emailAttachment.setBody(blobObj);		
	
		/*
		if(resp.getStatusCode() == 200){
			emailAttachment.contentType = 'application/octet-stream';
		    emailAttachment.setFileName(boxFileName);
		    emailAttachment.setBody(resp.getBodyAsBlob());
		} else {
			downloadUrl = resp.getHeader('Location');
		    HTTPRequest request2 = new HTTPRequest();
		    request2.setEndpoint(downloadUrl);
		    request2.setMethod('GET');
		    request2.setHeader('Authorization', 'Bearer ' + this.authInfo.Auth_Token__c);
		    emailAttachment.contentType = 'application/octet-stream';
		    emailAttachment.setFileName(boxFileName);
		    emailAttachment.setBody(h.send(request2).getBodyAsBlob());		
		}
		*/
			
	   
		    
		return emailAttachment;
    }
    
    private Messaging.SingleEmailMessage createEmail(funder__C funder) {
    	
            String contactName = '';
            if (funder.Contact_Name__c != null) contactName = funder.Contact_Name__c;
            else contactName = 'Funder Contact';

            String emailBody = String.valueOf(template.HTMLValue);
            emailBody = emailBody.replace('<![CDATA[', '');
            emailBody = emailBody.replace('{!CONTACT_NAME}', contactName);
            emailBody = emailBody.replace('{!ADDITIONAL_NOTES}', note);
            emailBody = emailBody.replace(']]>', '');
          
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          
            if (owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            
            String emailSubject = String.valueOf(template.Subject);
			String userRoleName = opp.Owner.UserRole.DeveloperName;
			if ( userRoleName == 'Manager_Aiden_s_Team' || userRoleName == 'Sales_Reps_Aiden_s_Team') {
				emailSubject += ' (Aiden\'s team)';
			}
            if(this.totalEmails > 1) {
            	emailSubject += ' (Email ' + this.emailNumber + ' of ' + this.totalEmails + ')';
            }
            emailSubject = emailSubject.replace('{!Account.Name}', opp.Account.Name);
            mail.setHTMLBody(emailBody);
            mail.setSubject(emailSubject);
            mail.setFileAttachments(this.emailAttachmentList);
            List<String> targets = new List<String>();

		if(!runningInASandbox()) {

			System.debug('2.2');
			if (funder.Portal_Lender_None_API__c) {
				System.debug('2.3');
				if (String.isNotBlank(opp.Owner.Admin_Email__c)) {
					System.debug('2.4');
					targets.add(opp.Owner.Admin_Email__c);
				} else {
					System.debug('2.5');
					targets.add('admin@emcfinancial.com');
				}
			} else {

				System.debug('2.6');
				if (funder.Contact_Email__c != null) {
					targets.add(funder.Contact_Email__c);
				}

				if (funder.Additional_Email_1__c != null) {
					targets.add(funder.Additional_Email_1__c);
				}

				if (funder.Additional_Email_2__c != null) {
					targets.add(funder.Additional_Email_2__c);
				}
			}
			System.debug('targets:');
			System.debug(targets);

			List<String> bccAddresses = new List<String>();
			bccAddresses.add(opp.Owner.Email);
			mail.setBccAddresses(bccAddresses);

		} else {
			targets.add(Label.DeveloperEmail);
		}

            mail.setToAddresses(targets);
            return mail;
    }
    
    private static Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}