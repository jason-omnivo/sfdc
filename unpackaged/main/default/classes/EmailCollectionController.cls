public with sharing class EmailCollectionController {
	
	private Lead lead;
	public EmailCollection__c emailCollection {get;set;}
	
	public EmailCollectionController(){}
	
	public EmailCollectionController(ApexPages.StandardController stdController) {
	    this.lead = (Lead)stdController.getRecord();
	    emailCollection = new EmailCollection__c();
        emailCollection.OwnerId = UserInfo.getUserId();
	}
	
    public PageReference CreateEmailCollection() {
        if(this.lead.Email == emailCollection.NewEmail__c) {
            ApexPages.Message msg =
                new ApexPages.Message(ApexPages.Severity.Error, Label.Emails_Are_Equals);
            ApexPages.addMessage(msg);
            return null;
        }
         if(emailCollection.NewEmail__c == null || emailCollection.NewEmail__c == '') {
            ApexPages.Message msg =
                new ApexPages.Message(ApexPages.Severity.Error, Label.New_Email_Field_Is_Required);
            ApexPages.addMessage(msg);
            return null;
        }
        try {
            emailCollection.Lead__c = this.lead.Id;
            //emailCollection.Email_Collection_Type__c;
            emailCollection.OldEmail__c = this.lead.Email;
            insert emailCollection;
            lead.Email = emailCollection.NewEmail__c;
            update this.lead;
            return new PageReference('javascript:window.close()');
        } catch(Exception ex) {
            return null;
        }
    }
    
    public PageReference uncheckGiveCommission() {
    	string emailCollectionId = apexpages.currentpage().getparameters().get('eci');
    	if(emailCollectionId == null || emailCollectionId == '') {
    		 ApexPages.Message msg =
                new ApexPages.Message(ApexPages.Severity.Error, 'An error occurred when trying to update the Email Collection Record.');
            ApexPages.addMessage(msg);
    		return null;
    	}
    	EmailCollection__c emailCollection = [SELECT Id FROM EmailCollection__c WHERE Id = :emailCollectionId];
    	emailCollection.GiveCommission__c = false;
    	update emailCollection;
        return new PageReference('javascript:window.close()');
    }
    
}