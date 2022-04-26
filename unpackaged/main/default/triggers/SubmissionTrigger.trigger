trigger SubmissionTrigger on Submissions__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    SubmissionTriggerHandler submissionTriggerHandler = new SubmissionTriggerHandler();
    if(Trigger.isInsert && Trigger.isBefore) {
    	submissionTriggerHandler.onBeforeInsert();
    } else if(Trigger.isUpdate && Trigger.isBefore) {
    	submissionTriggerHandler.onBeforeUpdate();
    } else if(Trigger.isInsert && Trigger.isAfter) {
    	submissionTriggerHandler.onAfterInsert();
    } else if(Trigger.isUpdate && Trigger.isAfter) {
    	submissionTriggerHandler.onAfterUpdate();
    } else if(Trigger.isDelete && Trigger.isAfter) {
    	submissionTriggerHandler.onAfterDelete();
    }
    
}