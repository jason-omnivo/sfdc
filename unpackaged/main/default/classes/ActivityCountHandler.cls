/* The Handler class to update 'Activity Count' Field on Lead Object. The activity count will gets increased 
 * by 1 if any Task is created or edited and status is 'Completed'. The trigger will also decrease the 
 * activity count by 1 if any Task whose status is 'Completed' is deleted.
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 17/06/2013                         Initial Draft
 */ 

public with sharing class ActivityCountHandler{
	
	//Constants
	private static final String  TASK_STATUS_COMPLETED = 'Completed';
	
	//Variables
	private Map<String,String> mapExcludedSubjects;                               //List wil contain subjects that gets excluded from Activity Count Logic.
	
	
	//Constructor
	public ActivityCountHandler(){
		mapExcludedSubjects = new Map<String, String>();
		this.getExcludedSubjects();
	}//End ActivityCountHandler Constructor.
	
	
	
	/* The method will populate mapExcludedSubjects by fetching values from Subject field of ExcludedSubjects 
	 *  Custom Setting.
	 */
	public void getExcludedSubjects(){
		//Fetching all Subjects from ExcludedSubjects Custom Setting.
		Map<String, ExcludedSubjects__c> mapExcudedSubjects = ExcludedSubjects__c.getAll();
		 for(String subjectName : mapExcudedSubjects.keySet()){
		 	mapExcludedSubjects.put(mapExcudedSubjects.get(subjectName).Subject__c, mapExcudedSubjects.get(subjectName).Subject__c);          // Adding Subject into list. 
		 }
	}//End getExcludedSubjects method.
	
	
	/* The method will give the Updated List of Lead Records after Incrementing or Decrementing the 
	 * Activity Count of Lead.
	 */
	public List<Lead> returnUpdatedListOfLeadRecords(Map<Id, Integer> pMapLeadIdWithCountToIncrease,
																						 Map<Id, Integer> pMapLeadIdWithCountToDecrease){
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		
		if(pMapLeadIdWithCountToIncrease == null)
			pMapLeadIdWithCountToIncrease = new Map<Id, Integer> ();
			
		if(pMapLeadIdWithCountToDecrease == null)
			pMapLeadIdWithCountToDecrease = new Map<Id, Integer> ();
		
		for(Lead leadRecordToUpdate : [Select Id, 
																		Activity_Count__c
															 From Lead 
															 Where (Id IN : pMapLeadIdWithCountToIncrease.keySet())
															 OR (Id IN : pMapLeadIdWithCountToDecrease.keySet())]){
			if(pMapLeadIdWithCountToIncrease.containsKey(leadRecordToUpdate.Id)){												 	
				//Increasing the Activity Count by the count available for that Lead in mapLeadIdWithCountToIncrease.												 	
				leadRecordToUpdate.Activity_Count__c = (leadRecordToUpdate.Activity_Count__c <> null) ? 
																					(leadRecordToUpdate.Activity_Count__c + pMapLeadIdWithCountToIncrease.get(leadRecordToUpdate.Id)) : 
																					 pMapLeadIdWithCountToIncrease.get(leadRecordToUpdate.Id);
				//Adding Lead Record into the List that gets Updated.
				lstLeadRecordsToUpdate.add(leadRecordToUpdate);      
			}//End if.    
			else if(pMapLeadIdWithCountToDecrease.containsKey(leadRecordToUpdate.Id)){
				leadRecordToUpdate.Activity_Count__c =   (leadRecordToUpdate.Activity_Count__c <> null) ? 
																					   leadRecordToUpdate.Activity_Count__c - pMapLeadIdWithCountToDecrease.get(leadRecordToUpdate.Id) : 0;
				lstLeadRecordsToUpdate.add(leadRecordToUpdate);               //Adding lead record into the List that gets updated.
			}//End else if.
	    }//End for.
		
		return lstLeadRecordsToUpdate;
	}//End returnUpdatedListOfLeadRecords.
	
	
	/* The Method will increase the Activity Count associated with Lead Record by 1.
	 */
	public Map<Id, Integer> returnIncrementedLeadCount( Id pLeadId, Map<Id, Integer> pMapLeadIdWithCountToIncrease){
		if(pMapLeadIdWithCountToIncrease.containsKey(pLeadId))
			pMapLeadIdWithCountToIncrease.put(pLeadId, pMapLeadIdWithCountToIncrease.get(pLeadId) + 1);      //Increasing the count by 1.
		else
			pMapLeadIdWithCountToIncrease.put(pLeadId, 1);
			
		return pMapLeadIdWithCountToIncrease;
	}//End returnIncrementedLeadCount method.
	
	
	/* The Method will reduce the Activity Count associated with Lead Record by 1.
	 */
	public Map<Id, Integer> returnDecrementedLeadCount( Id pLeadId, Map<Id, Integer> pMapLeadIdWithCountToDecrease){
		if(pMapLeadIdWithCountToDecrease.containsKey(pLeadId))
			pMapLeadIdWithCountToDecrease.put(pLeadId, pMapLeadIdWithCountToDecrease.get(pLeadId) + 1);      //Increasing the count by 1.
		else
			pMapLeadIdWithCountToDecrease.put(pLeadId, 1);
			
		return pMapLeadIdWithCountToDecrease;
	}//End pMapLeadIdWithCountToDecrease method.
	
	
	/* The method will increase the activity count related to a Lead by 1 if any Task is created and
	 * Status is 'Completed' and Subject is not included in ExcludedSubject Custom Setting. 
	 */	
	public void onTaskInsertIncreaseActivityCount(List<Task> pListNewTasks){
		Map<Id, Task> leadWithTaskRecord = new Map<Id, Task>();
		try{
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		//Map will contain Lead Id and Number of Count that gets added to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToIncrease = new Map<Id, Integer>();
		for(Task taskRecord : pListNewTasks){
			leadWithTaskRecord.put(taskRecord.WhoId, taskRecord );
			//Checking if the mapExcludedSubjects is empty and Task Status is Completed.
			if(mapExcludedSubjects.isEmpty() && taskRecord.Status == TASK_STATUS_COMPLETED){
				mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(taskRecord.WhoId, mapLeadIdWithCountToIncrease);
			}//End if outer.
			//Checking if the Subject is not in  mapExcludedSubjects and Task Status is Completed.
			else if(taskRecord.Status == TASK_STATUS_COMPLETED && !(mapExcludedSubjects.containsKey(taskRecord.Subject))){
				mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(taskRecord.WhoId, mapLeadIdWithCountToIncrease);
			}//End else if.
		}//End for.
		
		lstLeadRecordsToUpdate = this.returnUpdatedListOfLeadRecords(mapLeadIdWithCountToIncrease, null);
	    if(!lstLeadRecordsToUpdate.isEmpty())
	    	update(lstLeadRecordsToUpdate);                       //Updating Lead records.
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       Task taskRec = leadWithTaskRecord.get(IdforError);
		       taskRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End onTaskInsertIncreaseActivityCount
	
	
	
	/* The method will update Activity Count and Increase Activity Count by 1 if any Task is updated 
	 * and Status is completed and Prior Status is not 'Completed' and Subject is not Excluded Subject 
	 *  List. The Method will also Decrease the Activity Count by 1 if any Task is edited and Status is 
	 * changed to some other value and Previous Status is 'Completed' and Prevoius Subject is not in
	 * Excluded Subject List.
	 */
	public void onEditTaskIncreaseOrDecreaseActivityCount(List<Task> pNewTaskList , List<Task> pOldTaskList){
		Map<Id, Task> leadWithTaskRecord = new Map<Id, Task>();
		try{
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		//Map will contain Lead Id and Number of Count that gets added to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToIncrease = new Map<Id, Integer>();           
		//Map will contain Lead Id and Number of Count that gets subtrated to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToDecrease = new Map<Id, Integer>();		    
		
		for(Integer index = 0; index <  pNewTaskList.size(); index++){
			leadWithTaskRecord.put(pNewTaskList[index].WhoId, pNewTaskList[index] );
			if(mapExcludedSubjects.isEmpty()){                                          //Checking if the mapExcludedSubjects is empty.
				//Checking if the Task Status is 'Completed' and earlier Task Status is not 'Completed'.
				if(pNewTaskList[index].Status == TASK_STATUS_COMPLETED && pOldTaskList[index].Status <> TASK_STATUS_COMPLETED){ 
					mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(pNewTaskList[index].WhoId, mapLeadIdWithCountToIncrease);
				}//End if.
				else if(pNewTaskList[index].Status <> TASK_STATUS_COMPLETED && pOldTaskList[index].Status == TASK_STATUS_COMPLETED){
					mapLeadIdWithCountToDecrease = this.returnDecrementedLeadCount(pNewTaskList[index].WhoId, mapLeadIdWithCountToDecrease);
				}//End else if.
			}//End if.
			else{
				/* Checking if the Task Status is 'Completed' and earlier Task Status is not 'Completed' 
				 * and Task Subject is not in Excluded Subjects List.
				 */
				if(!(mapExcludedSubjects.containsKey(pNewTaskList[index].Subject)) && pNewTaskList[index].Status == TASK_STATUS_COMPLETED 
				    && pOldTaskList[index].Status <> TASK_STATUS_COMPLETED){
				    mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(pNewTaskList[index].WhoId, mapLeadIdWithCountToIncrease);	
				}//End if.
				
				/* Checking if the Task Status is 'Completed' and Subject is changed to the value that 
				 * is not included in Excluded Subjects List.
				 */
				else if(pNewTaskList[index].Subject <> pOldTaskList[index].Subject && !(mapExcludedSubjects.containsKey(pNewTaskList[index].Subject))
						   && (mapExcludedSubjects.containsKey(pOldTaskList[index].Subject)) && pNewTaskList[index].Status == TASK_STATUS_COMPLETED){
					 mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(pNewTaskList[index].WhoId, mapLeadIdWithCountToIncrease);
				}//End else if.
				
				/* Checking if the Task Status is changed to some other value from 'Completed' and  Subject  
				 * value is not included in Excluded Subjects List.
				 */
				else if(!(mapExcludedSubjects.containsKey(pOldTaskList[index].Subject)) && pNewTaskList[index].Status <> TASK_STATUS_COMPLETED 
					       && pOldTaskList[index].Status == TASK_STATUS_COMPLETED){
					mapLeadIdWithCountToDecrease = this.returnDecrementedLeadCount(pNewTaskList[index].WhoId, mapLeadIdWithCountToDecrease);       	
				}//End else if.
				
				/* Checking if the Task's Prevoius Status is 'Completed' and Subject is changed to the value that   
				 * included in Excluded Subjects List from the Value that was not included in the  Excluded Subjects List.
				 */
				else if(!(mapExcludedSubjects.containsKey(pOldTaskList[index].Subject))  && mapExcludedSubjects.containsKey(pNewTaskList[index].Subject)
				           && pOldTaskList[index].Status == TASK_STATUS_COMPLETED){
				    mapLeadIdWithCountToDecrease = this.returnDecrementedLeadCount(pNewTaskList[index].WhoId, mapLeadIdWithCountToDecrease);       	
				}//End else if.
			}//End else.
		}//End for.
		lstLeadRecordsToUpdate = this.returnUpdatedListOfLeadRecords(mapLeadIdWithCountToIncrease, mapLeadIdWithCountToDecrease);
		if(!lstLeadRecordsToUpdate.isEmpty())
			update(lstLeadRecordsToUpdate);
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       Task taskRec = leadWithTaskRecord.get(IdforError);
		       taskRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End onEditTaskIncreaseOrDecreaseActivityCount Method.
	
	
	
	/* Method will reduce the Activity Count Field of Lead if any Task whose status is 'Completed' and 
	 * Subject is not included in ExcludedSubject List is deleted.
	 */
	public void OnTaskDeleteDecreaseActivityCount(List<Task> pListTask){
		Map<Id, Task> leadWithTaskRecord = new Map<Id, Task>();
		try{
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		//Map will contain Lead Id and Number of Count that gets subtrated to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToDecrease = new Map<Id, Integer>();		    
		for(Task taskRecord : pListTask){
			leadWithTaskRecord.put(taskRecord.WhoId, taskRecord );
			if(taskRecord.Status == TASK_STATUS_COMPLETED && !(mapExcludedSubjects.containsKey(taskRecord.Subject))){
				mapLeadIdWithCountToDecrease = this.returnDecrementedLeadCount(taskRecord.WhoId, mapLeadIdWithCountToDecrease);
			}//End if.
		}//End for.
		lstLeadRecordsToUpdate = this.returnUpdatedListOfLeadRecords(null, mapLeadIdWithCountToDecrease);
		if(!lstLeadRecordsToUpdate.isEmpty())
			update(lstLeadRecordsToUpdate);
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       Task taskRec = leadWithTaskRecord.get(IdforError);
		       taskRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End OnTaskDeleteDecreaseActivityCount method.
	
	
	
	/* The method will increase the activity count related to a Lead by 1 if any Event is created and
	 * Subject is not included in ExcludedSubject Custom Setting. 
	 */
	public void onEventInsertIncreaseActivityCount(List<Event> pListEvent){
		Map<Id, Event> leadWithEventRecord = new Map<Id, Event>();
		try{
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		//Map will contain Lead Id and Number of Count that gets added to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToIncrease = new Map<Id, Integer>();
		for(Event eventRecord : pListEvent){
			leadWithEventRecord.put(eventRecord.WhoId, eventRecord );
			//Checking if the mapExcludedSubjects is empty.
			if(mapExcludedSubjects.isEmpty()){
				mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(eventRecord.WhoId, mapLeadIdWithCountToIncrease);
			}//End if outer.
			//Checking if the Subject is not in  mapExcludedSubjects.
			else if(!(mapExcludedSubjects.containsKey(eventRecord.Subject))){
				mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(eventRecord.WhoId, mapLeadIdWithCountToIncrease);
			}//End else if.
		}//End for.
		
		lstLeadRecordsToUpdate = this.returnUpdatedListOfLeadRecords(mapLeadIdWithCountToIncrease, null);
	    if(!lstLeadRecordsToUpdate.isEmpty())
	    	update(lstLeadRecordsToUpdate);                       //Updating Lead records.
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       Event eventRec = leadWithEventRecord.get(IdforError);
		       eventRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End onEventInsertIncreaseCount.
	
	
	
	/* The method will update Activity Count and Increase Activity Count by 1 if any Event is edited 
	 * Subject is not Excluded Subject List. The Method will also Decrease the Activity Count by 1 if 
	 * any Event is edited and  Prevoius Subject is not in Excluded Subject List and new Subject is in
	 * Excluded Subject List.
	 */
	public void onEditEventIncreaseOrDecreaseActivityCount(List<Event> pNewEventList , List<Event> pOldEventList){
		Map<Id, Event> leadWithEventRecord = new Map<Id, Event>();
		try{
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		//Map will contain Lead Id and Number of Count that gets added to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToIncrease = new Map<Id, Integer>();           
		//Map will contain Lead Id and Number of Count that gets subtrated to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToDecrease = new Map<Id, Integer>();		    
		
		for(Integer index = 0; index <  pNewEventList.size(); index++){
			leadWithEventRecord.put(pNewEventList[index].WhoId, pNewEventList[index] );
			if(!mapExcludedSubjects.isEmpty()){
				/* Checking if the Subject is changed to the value that is not included in Excluded Subjects List
				 *  and Previous Subject was in Excluded Subjects List.
				 */
				if(pNewEventList[index].Subject <> pOldEventList[index].Subject && !(mapExcludedSubjects.containsKey(pNewEventList[index].Subject))
				   && (mapExcludedSubjects.containsKey(pOldEventList[index].Subject))){
				   	mapLeadIdWithCountToIncrease = this.returnIncrementedLeadCount(pNewEventList[index].WhoId, mapLeadIdWithCountToIncrease);
				}//End if.
				
				/* Checking if the Subject is changed to the value that is included in Excluded Subjects List
				 *  from the Value that was not included in the Excluded Subjects List.
				 */
				else if(!(mapExcludedSubjects.containsKey(pOldEventList[index].Subject))  && mapExcludedSubjects.containsKey(pNewEventList[index].Subject))
				   mapLeadIdWithCountToDecrease = this.returnDecrementedLeadCount(pNewEventList[index].WhoId, mapLeadIdWithCountToDecrease);
			}//End else.
		}//End for.
		lstLeadRecordsToUpdate = this.returnUpdatedListOfLeadRecords(mapLeadIdWithCountToIncrease, mapLeadIdWithCountToDecrease);
		if(!lstLeadRecordsToUpdate.isEmpty())
	    	update(lstLeadRecordsToUpdate);                      			 //Updating Lead records.
	    }catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       Event eventRec = leadWithEventRecord.get(IdforError);
		       eventRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End onEditEventIncreaseOrDecreaseActivityCount method.
	
	
	
	/* Method will reduce the Activity Count Field of Lead if any Event whose Subject is not included 
	 *  in ExcludedSubject custom Setting is deleted.
	 */
	public void OnEventDeleteDecreaseActivityCount(List<Event> pListEvent){
		Map<Id, Event> leadWithEventRecord = new Map<Id, Event>();
		try{
		// List will contain the list of Lead Records whose 'Activity Count' field gets Updated. 
		List<Lead> lstLeadRecordsToUpdate = new List<Lead>();
		//Map will contain Lead Id and Number of Count that gets subtrated to Activity Count field of that Lead.
		Map<Id, Integer> mapLeadIdWithCountToDecrease = new Map<Id, Integer>();		    
		for(Event eventRecord : pListEvent){
			leadWithEventRecord.put(eventRecord.WhoId, eventRecord );
			if(!(mapExcludedSubjects.containsKey(eventRecord.Subject))){
				 mapLeadIdWithCountToDecrease = this.returnDecrementedLeadCount(eventRecord.WhoId, mapLeadIdWithCountToDecrease);
			}//End if.
		}//End for.
		lstLeadRecordsToUpdate = this.returnUpdatedListOfLeadRecords(null, mapLeadIdWithCountToDecrease);
		if(!lstLeadRecordsToUpdate.isEmpty())
			update(lstLeadRecordsToUpdate);
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       Event eventRec = leadWithEventRecord.get(IdforError);
		       eventRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End OnTaskDeleteDecreaseActivityCount method.
	
}//End ActivityCountHandler class.