/* The Trigger to update 'Activity Count' Field on Lead Object. The activity count will gets increased 
 * by 1 if any Task is created or edited and status is 'Completed' and Subject is not in ExcludedSubjects 
 * Custom Setting. The trigger will also decrease the activity count by 1 if any Task whose status is 'Completed' 
 * and Subject is not in ExcludedSubjects Custom Setting is deleted. The trigger will also increase the activity Count if Task is
 * edited and Status is changed to 'Completed' and Subject is not in ExcludedSubjects Custom Setting or Decrease the
 * activity Count if Task is edited and status is changes from 'Completed'.
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 17/06/2013                         Initial Draft
 */ 


trigger TaskTrigger on Task (before delete, before insert, before update) {
	
	ActivityCountHandler activityCountHandler = new ActivityCountHandler();
	
	if(trigger.isBefore && trigger.isInsert){
		/* Calling onTaskInsertIncreaseActivityCount method of ActivityCountHandler to increase the Activity 
		 * Count if the Task is created and Status is Completed and Subject is not included in ExcludedSubject
		 * Custom Setting.
		 */
		activityCountHandler.onTaskInsertIncreaseActivityCount(trigger.new);
		new CallCountHandler().onCreateTask(trigger.new);
	}//End if.
	 
	if(trigger.isBefore && trigger.isUpdate){
		/* Calling onEditTaskIncreaseOrDecreaseActivityCount method of ActivityCountHandler to increase the
		 *  Activity Count if the Task is edited and Status is Completed and Subject is not included in ExcludedSubject
		 * Custom Setting and also decrease the Activity Count if the Task is edited and Status changed from Completed
		 * to other Value or Subject is changed to the value present in ExcludedSubject Custom Setting.
		 */
		activityCountHandler.onEditTaskIncreaseOrDecreaseActivityCount(trigger.new, trigger.old);
		new CallCountHandler().onUpdateTask(trigger.new, trigger.old);
	}//End if.
	
	if(trigger.isBefore && trigger.isDelete){
		/* Calling OnTaskDeleteDecreaseActivityCount method of ActivityCountHandler to decrease the
		 *  Activity Count if the Task is deleted and Status is Completed and Subject is not included in ExcludedSubject
		 * Custom Setting.
		 */
		activityCountHandler.OnTaskDeleteDecreaseActivityCount(trigger.old);
		new CallCountHandler().onDeleteTask(trigger.old);
	}//End if.
	

}//End TaskTrigger.