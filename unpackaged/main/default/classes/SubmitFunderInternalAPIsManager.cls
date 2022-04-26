public with sharing class SubmitFunderInternalAPIsManager {

    public void executeSubmitToFundersCallouts(List<Submissions__c> submissionList){

        System.debug('Submit_Funder_Using_Internal_API__c Step 1.3: execute called');

        for(Submissions__c submission : submissionList) {
            if(submission.Funder__r.Name == 'Idea Financial'){
                System.debug('Submit_Funder_Using_Internal_API__c Step 1.4: Idea Financial found');
                System.enqueueJob(new IdeaFinancialSubmitApplication(submission.Opportunity__c));
            }
        }
    }
}