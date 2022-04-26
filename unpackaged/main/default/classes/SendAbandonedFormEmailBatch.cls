public class SendAbandonedFormEmailBatch implements Database.Batchable<sObject> {
    public List<Lead> start(Database.BatchableContext bc) {

        Datetime startDateTime = Datetime.now().addMinutes(-5);
        Datetime endDateTime = Datetime.now().addMinutes(-11);
//        Datetime startDateTime = Datetime.now().addMinutes(0);
//        Datetime endDateTime = Datetime.now().addMinutes(-30);

        if(Test.isRunningTest()) {
            startDateTime = Datetime.now();
        }

        return [SELECT Id, Email, IsEmcForm__c, Owner.Email FROM Lead WHERE Form_Step_1__c = TRUE
                       AND Form_Step_3__c = FALSE AND Reminder_Email_Sent__c = FALSE
                       AND CreatedDate <= :startDateTime
                       AND CreatedDate >= :endDateTime];

    }
    public void execute(Database.BatchableContext bc, List<Lead> leadList) {
        SendAbandonedFormEmailManager sendAbandonedFormEmailManager = new SendAbandonedFormEmailManager();
        sendAbandonedFormEmailManager.sendEmails(leadList);
    }
    public void finish(Database.BatchableContext bc) {

    }
}