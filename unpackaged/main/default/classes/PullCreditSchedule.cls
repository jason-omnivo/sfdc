public with sharing class PullCreditSchedule implements Schedulable {

    public void execute(SchedulableContext SC) {

        List<String> opportunityIdList = new List<String>();
        for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Pull_Credit_Report__c = TRUE]) {
            opportunityIdList.add(opp.Id);
        }

        if (!opportunityIdList.isEmpty()) {
            PullCreditDataQueueable asyncUploader = new PullCreditDataQueueable(opportunityIdList);
            System.enqueueJob(asyncUploader);
        }

    }

}