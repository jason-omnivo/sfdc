global class SendAbandonedFormEmailSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendAbandonedFormEmailBatch sendAbandonedFormEmailBatch = new SendAbandonedFormEmailBatch();
        Database.executeBatch(sendAbandonedFormEmailBatch, 5);
    }
}