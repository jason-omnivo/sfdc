public with sharing class IdeaFinancialSubmitApplication implements Queueable, Database.AllowsCallouts {

    String oppId { get; set; }
    IdeaFinancialBL bl { get; set; }
    IdeaFinancialSendAppCallout callout { get; set; }

    public IdeaFinancialSubmitApplication(String oppId){

        System.debug('Submit_Funder_Using_Internal_API__c Step 2.1:');
        System.debug('IdeaFinancialSubmitApplication - Queueable ctr');
        this.oppId = oppId;
        bl = new IdeaFinancialBL(oppId);
        callout = new IdeaFinancialSendAppCallout();
    }

    public void execute(QueueableContext context) {
        System.debug('Submit_Funder_Using_Internal_API__c Step 2.2:');
        System.debug('IdeaFinancialSubmitApplication - Queueable - execute');
        try{
            IdeaFinancialAPI.SendApplicationRequest request = bl.generateSendAppRequest(bl.account);
            System.debug('Submit_Funder_Using_Internal_API__c Step 2.3: Send Application');
            IdeaFinancialAPI.SendApplicationResponse response = callout.execute(request);
            String appId = bl.getApplicationId(response);
            if(String.isNotBlank(appId)){
                System.debug('Submit_Funder_Using_Internal_API__c Step 3.1: Got Application ID');
                bl.opportunity.IdeaFinancialApplicationID__c = appId;

                System.debug('Submit_Funder_Using_Internal_API__c Step 3.2: Send Files');
                // TODO: Send files Step 3

                System.debug('Submit_Funder_Using_Internal_API__c Step 3.3: Set Submission to wait for Get Offers request');
                update bl.opportunity;
                System.debug('Sub: ' + bl.ideaFinancialSubmission);
                bl.uploadFiles(oppId);
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}