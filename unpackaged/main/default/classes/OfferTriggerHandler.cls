public with sharing class OfferTriggerHandler {

    public void handleAfterUpdate(Map<Id, Offer__c> oldOfferMap, List<Offer__c> newOfferList){

        System.debug('OfferTriggerHandler.handleAfterUpdate called');
        IdeaFinancialAPISettings__c settings = IdeaFinancialAPISettings__c.getOrgDefaults();
        for(Offer__c offer : newOfferList){
            Offer__c oldOffer = oldOfferMap.get(offer.Id);
            if(offer.Funder__c == settings.Idea_Funder_Id__c
                    && offer.Status__c == 'Accepted'
                    && oldOffer.Status__c != 'Accepted'){
                System.debug('Idea Financial offer accepted');
                System.enqueueJob(new IdeaFinancialAcceptOffer(offer.Opportunity__c, offer.Id));
            }
        }
    }
}