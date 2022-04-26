/**
 @Test Class: ContentVersionTriggerTest
 **/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after update) {

    ContentDocumentTriggerHandler contentDocumentTriggerHandler = new ContentDocumentTriggerHandler();
    if(Trigger.isAfter && Trigger.isInsert) {
        contentDocumentTriggerHandler.handleIsAfterInsert(Trigger.newMap);
    }
    
}