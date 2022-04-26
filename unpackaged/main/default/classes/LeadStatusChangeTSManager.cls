public with sharing class LeadStatusChangeTSManager {
    
    
    static string STATUS_OPEN_ATTEMPTING_CONTACT = 'Open - Attempting Contact';
    static string STATUS_OPEN_AWAITING_APP = 'Open - Awaiting App (App Sent)';
    static string STATUS_CONVERTED_SIGNED_APP = 'Converted - Signed App';
    static string STATUS_CONVERTED_VERBAL_APP = 'Converted - Verbal App';
    static string STATUS_Closed_Cant_Reach = 'Closed - Can\'t Reach';
    static string STATUS_Closed_Not_Interested_Yet = 'Closed - Not Interested Yet';
    static string STATUS_Closed_Unqualified = 'Closed - Unqualified';
    static string STATUS_Closed_Bad_Lead = 'Closed - Bad Lead';
    

    public map<string, string> statusToTimeStampMap;
    public LeadStatusChangeTSManager() {
    	statusToTimeStampMap = new Map<string, string>();
    	statusToTimeStampMap.put(STATUS_OPEN_ATTEMPTING_CONTACT, 'Status_Open_Attempting_Contact_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_OPEN_AWAITING_APP, 'Status_Open_Awaiting_App_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_CONVERTED_SIGNED_APP, 'Status_Converted_Signed_App_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_CONVERTED_VERBAL_APP, 'Status_Converted_Verbal_App_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_Closed_Cant_Reach, 'Status_Closed_Can_t_Reach_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_Closed_Not_Interested_Yet, 'Status_Closed_Not_Interested_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_Closed_Unqualified, 'Status_Closed_Unqualified_Date_Time__c');
    	statusToTimeStampMap.put(STATUS_Closed_Bad_Lead, 'Status_Closed_Bad_Lead_Date_Time__c');
    }
    
    public void onUpdateOrInsert(List<Lead> leadList, List<Lead> oldLeadList) {
    	
		string leadStatus = '';
		string oldLeadStatus = '';
		string fieldToUpdate = '';
		DateTime startDateTime;
    	for(Integer i = 0; i < leadList.size(); i++) {
    		leadStatus = leadList[i].Status;
    		oldLeadStatus = oldLeadList == null ? null : oldLeadList[i].Status;
    		startDateTime =
            leadList[i].Status_Open_Attempting_Contact_Date_Time__c != null ?
            leadList[i].Status_Open_Attempting_Contact_Date_Time__c : leadList[i].CreatedDate;
            startDateTime = startDateTime != null ? startDateTime : DateTime.now();
    		if(leadStatus != null) {
	    		if(oldLeadStatus == null || leadStatus != oldLeadStatus) {	    	
	    			if(statusToTimeStampMap.containsKey(leadStatus)) {
	    				fieldToUpdate = statusToTimeStampMap.get(leadStatus);
	    				leadList[i].put(fieldToUpdate, Utils.now());
	    			}
	    			System.debug(leadList[i].CreatedDate);
		    		if(leadStatus == STATUS_OPEN_AWAITING_APP) {
						leadList[i].Bus_Hours_Until_App_Sent__c = 
						getBH(startDateTime , leadList[i].Status_Open_Awaiting_App_Date_Time__c);					
					}
		    		if(leadStatus == STATUS_CONVERTED_SIGNED_APP ||
		    			leadStatus == STATUS_CONVERTED_VERBAL_APP) {
		    			string convertedDateTimeField = statusToTimeStampMap.get(leadStatus);
						leadList[i].Bus_Hours_Until_Converted__c =
						getBH(startDateTime , (DateTime)leadList[i].get(convertedDateTimeField));
						System.debug('11');
						if(leadList[i].Status_Open_Awaiting_App_Date_Time__c != null) {
							leadList[i].Bus_Hours_App_Sent_Until_Converted__c = 
							getBH(leadList[i].Status_Open_Awaiting_App_Date_Time__c,
							(DateTime)leadList[i].get(convertedDateTimeField));						
						}
						System.debug('12');
						if(leadList[i].LastActivityDate != null) {
							leadList[i].Bus_Hours_Last_Activity_To_Converted__c = 
							getBH(leadList[i].LastActivityDate,
							(DateTime)leadList[i].get(convertedDateTimeField));						
						}
						
						
					}	
					System.debug('13');
					if(leadStatus == STATUS_Closed_Cant_Reach ||
		    			leadStatus == STATUS_Closed_Not_Interested_Yet ||
		    			leadStatus == STATUS_Closed_Unqualified || 
		    			leadStatus == STATUS_Closed_Bad_Lead) {
		    				
		    			string closedDateTimeField = statusToTimeStampMap.get(leadStatus);
						leadList[i].Bus_Hours_Until_Closed__c =
						getBH(startDateTime , (DateTime)leadList[i].get(closedDateTimeField));
						System.debug('14');
						if(leadList[i].LastActivityDate != null) {
							leadList[i].Bus_Hours_Last_Activity_Until_Closed__c = 
							getBH(leadList[i].LastActivityDate,
							(DateTime)leadList[i].get(closedDateTimeField));						
						}
						
					}
					
	    		}	
    		}
    	}    	
    }
    
	private decimal getBH(DateTime startTime, DateTime endTime) {
		Long diff = BusinessHours.diff(Utils.Bh.Id, startTime, endTime);
		Decimal num = diff / 1000.0 / 60.0 / 60.0;
		Decimal fixedNum = num.setScale(2, RoundingMode.HALF_DOWN);
		return fixedNum;
	}
    
    
}