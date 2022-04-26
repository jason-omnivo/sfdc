global class UpdateFunderStatistics implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        Map<string, decimal> funderAprrovalTimeMap = new Map<string, decimal>();
    	for(AggregateResult ar : [SELECT Funder__c,
    								AVG(Time_Until_Approved__c) AverageApprovalTime
									FROM Submissions__c
									WHERE Time_Until_Approved__c <> null
									GROUP BY Funder__c]) {
			funderAprrovalTimeMap.put((string)ar.get('Funder__c'), (decimal)ar.get('AverageApprovalTime'));
		}
		
		Map<string, Integer> approvedSubmissionMap = new Map<string, Integer>(); 
		for(AggregateResult ar : [SELECT Funder__c, COUNT(Id) NumberOfSubmissions FROM Submissions__c
									WHERE Bank_Status__c = 'Approved'
									OR Bank_Status__c = 'Signed'
									OR Bank_Status__c = 'Funded'
									GROUP BY Funder__c]) {
			approvedSubmissionMap.put((string)ar.get('Funder__c'), (integer)ar.get('NumberOfSubmissions'));
		}
		
		map<string, integer> fundedSubmissionMap = new map<string, integer>(); 
		for(AggregateResult ar : [SELECT Funder__c, COUNT(Id) NumberOfSubmissions
								FROM Submissions__c
								WHERE Bank_Status__c = 'Funded'
								GROUP BY Funder__c]) {
			fundedSubmissionMap.put((string)ar.get('Funder__c'), (integer)ar.get('NumberOfSubmissions'));
		}
		
		Map<string, decimal> pctFromApprovedToFundedMap = new Map<string, decimal>();
		for(string funderId : approvedSubmissionMap.keySet()) {
			integer numberOfApprovedSubmissions = approvedSubmissionMap.get(funderId);
			integer numberOfFundedSubmissions =  fundedSubmissionMap.containsKey(funderId) ? fundedSubmissionMap.get(funderId) : 0;
			pctFromApprovedToFundedMap.put(funderId, 100 * (numberOfFundedSubmissions / (decimal) numberOfApprovedSubmissions));
		}
		
		List<Funder__c> funderList = [SELECT Id FROM Funder__c];
        for(Funder__c funder : funderList) {
        	if(funderAprrovalTimeMap.containsKey(funder.Id))
        		funder.Approval_Time_In_Hours__c = funderAprrovalTimeMap.get(funder.Id);
    		if(pctFromApprovedToFundedMap.containsKey(funder.Id))
        		funder.PCT_From_Approved_To_Funded__c = pctFromApprovedToFundedMap.get(funder.Id);
        }
        update funderList;
    }
   
}