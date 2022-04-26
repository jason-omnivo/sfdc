public with sharing class CallCountHandler {
    
    Map<Id, Task> taskMap;
    Map<Id, Task> oldTaskMap;
    List<Lead> leadList;
    
    public CallCountHandler() {
    	taskMap = new Map<Id, Task>();
    }
    
    public void onCreateTask(List<Task> taskList) {
    	
    	for(Task task : taskList) {
    		System.debug('1');
    		if(task.CallType <> '') {
    			task.Type = 'Call';
    		}
    		System.debug('3');
    		taskMap.put(task.WhoId, task);
    		System.debug('4');
    	}
		
		System.debug('5');
    	leadList = [SELECT Id, Last_Call_Date_Time__c, Call_Count__c FROM Lead WHERE Id IN :taskMap.keySet()];
    	System.debug('6');
    	for(Lead lead : leadList) {
    		System.debug('7');
    		if(taskMap.get(lead.Id).Type == 'Call') {
    			System.debug('8');
    			lead.Call_Count__c = lead.Call_Count__c == null ? 1 : lead.Call_Count__c + 1;
	    		lead.Last_Call_Date_Time__c = DateTime.now();
	    		System.debug('date:');
	    		System.debug(lead.Last_Call_Date_Time__c);	
    		}
    	}
    	System.debug('9');
    	if(leadList.size() > 0)
    		update leadList;
    }
    
    public void onUpdateTask(List<Task> taskList, List<Task> oldTaskList) {
    	System.debug('11');
    	for(Task task : taskList) {
    		taskMap.put(task.WhoId, task);
    	}
    	System.debug('22');
    	oldTaskMap = new Map<Id, Task>();
    	for(Task task : oldTaskList) {
    		oldTaskMap.put(task.WhoId, task);
    	}
    	System.debug('taskMap');
    	System.debug(taskMap);
    	System.debug('oldTaskMap');
    	System.debug(oldTaskMap);
    	System.debug('33');
    	leadList = [SELECT Id, Last_Call_Date_Time__c, Call_Count__c FROM Lead WHERE Id IN :taskMap.keySet()];
    	System.debug('44');
    	if(oldTaskMap != null && taskMap != null) {
    		System.debug('55');
	    	for(Lead lead : leadList) {
	    		System.debug('66');
	    		Task oldTask = oldTaskMap.get(lead.Id);
	    		Task newTask = taskMap.get(lead.Id);
	    		System.debug('77');
	    		System.debug('oldTask');
		    	System.debug(oldTask);
		    	System.debug('newTask');
		    	System.debug(newTask);
	    		if(oldTask != null && newTask != null) {
	    			System.debug('88');
		    		if((oldTask.type != 'Call' && newTask.type == 'Call') ||
		    			(oldTask.WhoId != newTask.WhoId && newTask.type == 'Call')) {
		    			System.debug('99');
		    			lead.Call_Count__c = lead.Call_Count__c == null ? 1 : lead.Call_Count__c + 1;
		    			System.debug('Last_Call_Date_Time__c:');
		    			System.debug(lead.Last_Call_Date_Time__c);
		    			System.debug('newTask.CreatedDate:');
		    			System.debug(newTask.CreatedDate);
		    			if(lead.Last_Call_Date_Time__c == null || lead.Last_Call_Date_Time__c < newTask.CreatedDate) {
		    				System.debug('1010');
		    				lead.Last_Call_Date_Time__c = newTask.CreatedDate;
		    			}
		    			System.debug('1111');
		    		} else if(oldTask.type == 'Call' && newTask.type != 'Call') {
		    			
		    			lead.Call_Count__c = lead.Call_Count__c == null || lead.Call_Count__c == 0 ? 0 : lead.Call_Count__c - 1;
		
		    		}

	    		}
	    		
	    	}

    	}
    	if(leadList.size() > 0)
    		update leadList;
    	
    }
    
    public void onDeleteTask(List<Task> taskList) {
    	
    	for(Task task : taskList) {
    		taskMap.put(task.WhoId, task);
    	}
    	
    	leadList = [SELECT Id, Call_Count__c FROM Lead WHERE Id IN :taskMap.keySet()];
    	for(Lead lead : leadList) {
    		
    		if(taskMap.get(lead.Id).type == 'Call') {
    			
    			lead.Call_Count__c = lead.Call_Count__c == null || lead.Call_Count__c == 0 ? 0 : lead.Call_Count__c - 1;

    		}
    	}
    	if(leadList.size() > 0)
    		update leadList;
    	
    }
}