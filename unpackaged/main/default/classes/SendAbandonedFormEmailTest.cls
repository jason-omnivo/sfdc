@IsTest
private class SendAbandonedFormEmailTest {

    static Integer numberOfLeads = 5;
    @TestSetup
    static void setup() {

        List<Lead> leadList = TestDataGenerator.createLead(numberOfLeads);

        for(Lead lead : leadList) {
            lead.Form_Step_1__c = true;
        }
        update leadList;

    }

    @IsTest
    static void test() {

        List<Lead> leadList = [SELECT Id, Email, IsEmcForm__c, Form_Step_1__c, Owner.Email FROM Lead];
        SendAbandonedFormEmailManager sendAbandonedFormEmailManager = new SendAbandonedFormEmailManager();
        sendAbandonedFormEmailManager.sendEmails(leadList);
        System.assertEquals(numberOfLeads, [SELECT COUNT() FROM Lead WHERE Reminder_Email_Sent__c = TRUE]);
    }

    @IsTest
    static void testBatch() {

        Test.startTest();
        SendAbandonedFormEmailBatch batch = new SendAbandonedFormEmailBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

    }

    @IsTest
    static void testSchedule() {

        test.startTest();
        SendAbandonedFormEmailSchedule schedule = new SendAbandonedFormEmailSchedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Send Abandoned Form Email Schedule', sch, schedule);
        test.stopTest();

    }

}