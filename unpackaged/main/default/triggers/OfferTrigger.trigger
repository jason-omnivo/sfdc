trigger OfferTrigger on Offer__c (after update) {

    System.debug('OfferTrigger');
    OfferTriggerHandler handler = new OfferTriggerHandler();

    if(Trigger.isAfter && Trigger.isUpdate) {
        System.debug('OfferTrigger after update');
        handler.handleAfterUpdate(Trigger.oldMap, Trigger.new);
    }
}