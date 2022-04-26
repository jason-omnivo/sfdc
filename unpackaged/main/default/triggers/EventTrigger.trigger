/* The Trigger to update 'Activity Count' Field on Lead Object. The activity count will gets increased 
 * by 1 if any Event is created or edited and Subject is not included in ExcludedSubject Custom Setting.
 * Triggger will also decrease the'Activity Count' of Lead Object if the Event is deleted and Subject
 * is not included in ExcludedSubject Custom Setting.
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 18/06/2013                         Initial Draft
 */ 


trigger EventTrigger on Event (before delete, before insert, before update) {
	
	ActivityCountHandler activityCountHandler = new ActivityCountHandler();
	
	if(trigger.isBefore && trigger.isInsert){
		/* Calling onEventInsertIncreaseActivityCount method of ActivityCountHandler to increase the Activity 
		 * Count if the Event  is created and Subject is not included in ExcludedSubject Custom Setting.
		 */
		activityCountHandler.onEventInsertIncreaseActivityCount(trigger.new);
	}//End if.
	
	if(trigger.isBefore && trigger.isUpdate){
		/* Calling onEditEventIncreaseOrDecreaseActivityCount method of ActivityCountHandler to increase the
		 *  Activity Count if the Event is edited and Subject is not included in ExcludedSubject Custom Setting
		 *  and also decrease the Activity Count if the Event is edited and Subject is changed to the value present 
		 *  in ExcludedSubject Custom Setting.
		 */
		 activityCountHandler.onEditEventIncreaseOrDecreaseActivityCount(trigger.new, trigger.old);
	}//End if.
	
	if(trigger.isBefore && trigger.isDelete){
		/* Calling OnEventDeleteDecreaseActivityCount method of ActivityCountHandler to decrease the Activity
		 *  Count if the Task is deleted and Subject is not included in ExcludedSubject Custom Setting.
		 */
		activityCountHandler.OnEventDeleteDecreaseActivityCount(trigger.old);
	}//End if.
	
}//End EventTrigger.