public without sharing class CreditDataPullManager {

    private List<Opportunity> oldOpportunityList;
    private Map<Id, Opportunity> newOpportunityMap;

    private List<Opportunity> oppList2Update;

    public CreditDataPullManager(List<Opportunity> oldOpportunityList,
            Map<Id, Opportunity> newOpportunityMap) {
        this.oldOpportunityList = oldOpportunityList;
        this.newOpportunityMap = newOpportunityMap;
        this.oppList2Update = new List<Opportunity>();
    }

    public void uploadCreditData() {
        try {

            Log.add('Check If Run Upload Credit Data');
            List<Id> opportunityIdList = new List<Id>();

            Log.add('oldOpportunityList: ' + oldOpportunityList);
            Log.add('newOpportunityMap: ' + newOpportunityMap);
            for (Opportunity opportunity : oldOpportunityList) {
                if (isCreditDataNeedToBeUploaded(opportunity, newOpportunityMap.get(opportunity.Id))) {
                    opportunityIdList.add(opportunity.Id);
                    Opportunity opp2Update = new Opportunity();
                    opp2Update.Id = opportunity.Id;
                    opp2Update.Pull_Credit_Report__c = true;
                    oppList2Update.add(opp2Update);
                }
            }
            Log.add('opportunityIdList: ' + opportunityIdList);

            update oppList2Update;

//            if (!opportunityIdList.isEmpty()) {
//                PullCreditDataQueueable asyncUploader = new PullCreditDataQueueable(opportunityIdList);
//                System.enqueueJob(asyncUploader);
//            }

        } catch(Exception ex) {
            Log.add(ex);
        } finally {
            Log.insertLog();
        }
    }

    private Boolean isCreditDataNeedToBeUploaded(Opportunity oldOpportunity,
            Opportunity newOpportunity) {
        return oldOpportunity.Form_Step_4_Application_Sent__c == false &&
                newOpportunity.Form_Step_4_Application_Sent__c == true;
    }


}