public with sharing class SendAbandonedFormEmailManager {

    EmailTemplate abandonedFormEmailTemplate;
    OrgWideEmailAddress lendfullyAppsEmailAddress;

    public SendAbandonedFormEmailManager() {
        for (EmailTemplate emailTemplate : [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Abandoned_Form_Email']) {
            abandonedFormEmailTemplate = emailTemplate;
        }
        for (OrgWideEmailAddress address : [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'apps@lendfully.com']) {
            lendfullyAppsEmailAddress = address;
        }
        Boolean isRunningSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isRunningSandbox){
            lendfullyAppsEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'emc2@emcfinancial.com'];
        }
    }

    public void sendEmails(List<Lead> leadList) {

        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for (Lead lead : leadList) {

            System.debug('lead');
            System.debug(lead);
            System.debug(lead.IsEmcForm__c);
            System.debug(lead.Email);

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String> { lead.Email };
            if(!lead.IsEmcForm__c){
                message.setOrgWideEmailAddressId(lendfullyAppsEmailAddress.Id);
            }
            message.replyTo = lead.Owner.Email;
            message.targetObjectId = lead.Id;
            message.templateId = abandonedFormEmailTemplate.Id;
            messageList.add(message);

        }
        List<Messaging.SendEmailResult> resultList = Messaging.sendEmail(messageList);

        System.debug(resultList);

        Integer index = 0;
        String errorMessage = '';
        List<String> errorMessageList = null;
        for (Messaging.SendEmailResult result : resultList) {
            if (result.success) {
                System.debug('Email Sent');
                leadList.get(index).Reminder_Email_Sent__c = true;
            } else {
                System.debug('Email Sent Failed');
                errorMessage = 'Send email failed\r\n';
                errorMessageList = new List<String>();
                for (Messaging.SendEmailError error : result.errors) {
                    errorMessageList.add(error.message);
                }
                errorMessage += String.join(errorMessageList, ', ');
                leadList.get(index).Reminder_Email_Error_Message__c = errorMessage;
            }
            index++;
        }
        update leadList;

    }
}