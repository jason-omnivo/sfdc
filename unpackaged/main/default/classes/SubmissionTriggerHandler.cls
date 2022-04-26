public with sharing class SubmissionTriggerHandler {
	
	
	public SubmissionTriggerHandler() {

	}
	
	public void onBeforeInsert() { 
		 
		if(!Trigger.isExecuting) {
			return;
		} 
		
		List<Submissions__c> newSubmissionList = (List<Submissions__c>) Trigger.new;
		for(Submissions__c submission : newSubmissionList) {
			if(submission.Bank_Status__c == 'Approved'
				&& submission.TimeApproved__c == null) {
					submission.TimeApproved__c = DateTime.now();
					submission.Time_Until_Approved__c = 0;
			}
		}
		
	}
	
	public void onBeforeUpdate() {
		
		if(!Trigger.isExecuting) {
			return;
		}
		
		List<Submissions__c> newSubmissionList = (List<Submissions__c>) Trigger.new;
		Map<Id, Submissions__c> oldSubmissionMap = (Map<Id, Submissions__c>) Trigger.oldMap;
		for(Submissions__c submission : newSubmissionList) {
			if(submission.Bank_Status__c == 'Approved'
				&& oldSubmissionMap.get(submission.Id).Bank_Status__c <> 'Approved'
				&& submission.TimeApproved__c == null) {
					DateTime now = DateTime.now();
					submission.TimeApproved__c = now;
					submission.Time_Until_Approved__c = this.getTimeUntilApproved(submission.CreatedDate, now);
			}
		}
		
	}
	public void onAfterInsert() {
        updateOpportunityStage(Trigger.new);
    }
	public void onAfterUpdate() {
		updateOpportunityStage(Trigger.new);
	}
    public void onAfterDelete() {
        updateOpportunityStage(Trigger.old);
    }
    
    private void updateOpportunityStage(List<Submissions__c> submissionList) {
        
		System.debug(submissionList[0].Opportunity__c);
		System.debug(submissionList[0].Bank_Status__c);
		List<String> oppIdList = new List<String>();
		for(Submissions__c submission : submissionList)
			oppIdList.add(submission.Opportunity__c);
		List<Opportunity> oppList = [SELECT Id, StageName, (SELECT Id, Bank_Status__c FROM Submissions__r) FROM Opportunity WHERE Id IN :oppIdList];
		boolean changeStageToUnderwritingDeclined = false;
		boolean changeStageToUnderwriting = false;
        for(Opportunity opp : oppList) {
            changeStageToUnderwritingDeclined = true;
			for(Submissions__c submission : opp.Submissions__r)
			{
				if(opp.StageName != 'Underwriting' || submission.Bank_Status__c != 'Declined')
					changeStageToUnderwritingDeclined = false;					
				if(opp.StageName == 'Underwriting - Declined' && submission.Bank_Status__c == 'Underwriting')
					changeStageToUnderwriting = true;
			}
            System.debug(changeStageToUnderwritingDeclined);
            if(changeStageToUnderwritingDeclined)
				opp.StageName = 'Underwriting - Declined';
			else if(changeStageToUnderwriting)
				opp.StageName = 'Underwriting';
		}
		System.debug(oppList[0].StageName);
		System.debug(oppList[0]);
		System.debug(oppList);
		update oppList;
    }
	
	private decimal getTimeUntilApproved(DateTime startTime, DateTime endTime) {
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
		Long diff = BusinessHours.diff(bh.Id, startTime, endTime);
		Decimal num = diff /1000.0 / 60.0 / 60.0;
		Decimal fixedNum = num.setScale(2, RoundingMode.HALF_DOWN);
		return fixedNum;
	}
    
}