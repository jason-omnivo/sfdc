/**
 @Test Class: ContentVersionTriggerTest
 **/
trigger ContentVersionTrigger on ContentVersion (after insert, after update) {
  ContentVersionTriggerHandler contentVersionTriggerHandler = new ContentVersionTriggerHandler();
  if (Trigger.isAfter && Trigger.isInsert) {
    contentVersionTriggerHandler.handleIsAfterInsert(Trigger.newMap);
  }
}