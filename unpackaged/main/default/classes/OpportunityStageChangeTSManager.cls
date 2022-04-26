public with sharing class OpportunityStageChangeTSManager {
    
    static string STAGE_APPLICATION_IN = 'Application In';
    static string STAGE_APPLICATION_MISSING_INFO = 'Application Missing Info';
    static string STAGE_READY_TO_SUBMIT = 'Ready to Submit';
    static string STAGE_APPROVED = 'Approved';
    static string STAGE_FUNDED = 'Funded';
    static string STAGE_SIGNED = 'Signed';
    static string STAGE_UNDERWRITING = 'Underwriting';
    
    static string FIELD_APPLICATION_IN = 'Application_In_Date_Time__c';
    static string FIELD_APPLICATION_MISSING_INFO = 'Application_Missing_Info_Date_Time__c';
    static string FIELD_READY_TO_SUBMIT = 'Ready_To_Submit_Date_Time__c';
    static string FIELD_APPROVED = 'Approved_Date_Time__c';
    static string FIELD_FUNDED = 'Funded_Date_Time__c';
    static string FIELD_SIGNED = 'Signed_Date_Time__c';
    static string FIELD_UNDERWRITING = 'Underwriting_Date_Time__c';
    
    static string FIELD_TIME_FROM_APP_IN_TO_APP_MISSING_INFO = 'Time_From_App_In_To_App_Missing_Info__c';
    static string FIELD_TIME_FROM_APP_IN_TO_APP_READY_TO_SUBMIT = 'Time_From_App_In_To_App_Ready_To_Submit__c';
    static string FIELD_TIME_FROM_APPROVED_TO_SIGNED = 'Time_From_Approved_To_Signed__c';
    static string FIELD_TIME_FROM_SIGNED_TO_FUNDED = 'Time_From_Signed_to_Funded__c';
    static string FIELD_TIME_FROM_UNDERWRITING_TO_APPROVED = 'Time_From_Underwriting_To_Approved__c';
    static string FIELD_TIME_FROM_APP_IN_TO_FUNDED = 'Time_From_App_In_To_Funded__c';
    
    Map<String, String> statusToTSFieldMap;
    Map<String, List<CalculationAction>> calculationActionMap;
    public OpportunityStageChangeTSManager() {
    	
    	statusToTSFieldMap = new Map<String, String>();
    	statusToTSFieldMap.put(STAGE_APPLICATION_IN, FIELD_APPLICATION_IN);
    	statusToTSFieldMap.put(STAGE_APPLICATION_MISSING_INFO, FIELD_APPLICATION_MISSING_INFO);
    	statusToTSFieldMap.put(STAGE_READY_TO_SUBMIT, FIELD_READY_TO_SUBMIT);
    	statusToTSFieldMap.put(STAGE_APPROVED, FIELD_APPROVED);
    	statusToTSFieldMap.put(STAGE_FUNDED, FIELD_FUNDED);
    	statusToTSFieldMap.put(STAGE_SIGNED, FIELD_SIGNED);
    	statusToTSFieldMap.put(STAGE_UNDERWRITING, FIELD_UNDERWRITING);
    	
    	calculationActionMap = new  Map<String, List<CalculationAction>>();
    	addCalculationAction(STAGE_APPLICATION_MISSING_INFO, FIELD_APPLICATION_IN, FIELD_TIME_FROM_APP_IN_TO_APP_MISSING_INFO);
    	addCalculationAction(STAGE_READY_TO_SUBMIT, FIELD_APPLICATION_IN, FIELD_TIME_FROM_APP_IN_TO_APP_READY_TO_SUBMIT);
		addCalculationAction(STAGE_SIGNED, FIELD_APPROVED, FIELD_TIME_FROM_APPROVED_TO_SIGNED);
		addCalculationAction(STAGE_FUNDED, FIELD_SIGNED, FIELD_TIME_FROM_SIGNED_TO_FUNDED);
		addCalculationAction(STAGE_APPROVED, FIELD_UNDERWRITING, FIELD_TIME_FROM_UNDERWRITING_TO_APPROVED);
		addCalculationAction(STAGE_FUNDED, FIELD_APPLICATION_IN, FIELD_TIME_FROM_APP_IN_TO_FUNDED);
    	
    }
    
    public void onAfterInsert(Map<Id, Opportunity> oppMap) {
    	List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity WHERE id In :oppMap.keySet()];
    	setTimeStamp(oppList, NULL);
		update oppList;
    }
    
    public void onBeforeUpdate(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap) {
    	setTimeStamp(oppList, oldOppMap);
    }
    
    public void setTimeStamp(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap) {
    	for(Opportunity opp : oppList) {
    		DateTime now = Utils.now();
    		System.debug(Utils.now());
    		if(statusToTSFieldMap.containsKey(opp.StageName) &&
				(oldOppMap == NULL || opp.StageName != oldOppMap.get(opp.Id).StageName)) {
    			opp.put(statusToTSFieldMap.get(opp.StageName), now);
    		}
    		if(calculationActionMap.containsKey(opp.StageName) &&
				(oldOppMap == NULL || opp.StageName != oldOppMap.get(opp.Id).StageName)) {
				List<CalculationAction> calculationActionList = calculationActionMap.get(opp.StageName);
				for(CalculationAction action : calculationActionList) {
					Object startTimeObj = opp.get(action.startTimeField);
					if(startTimeObj != null) {
						DateTime startTime = DateTime.valueOf(startTimeObj);
						decimal bh = Utils.calculateBH(startTime, now);
						bh = bh >= 0 ? bh : 0;
						opp.put(action.fieldToUpdate,bh);
					}
				}
    		}
    	}
    }
    
    private void addCalculationAction(String stageName, String startTimeField, String fieldToUpdate) {
    	CalculationAction action = new CalculationAction(fieldToUpdate, startTimeField);
    	if(!calculationActionMap.containsKey(stageName)) {
    		calculationActionMap.put(stageName, new List<CalculationAction>());
    	}
    	calculationActionMap.get(stageName).add(action);
    }
    
	public class CalculationAction {
	   	
	   	public CalculationAction(String fieldToUpdate, String startTimeField) {
	   		this.fieldToUpdate = fieldToUpdate;
	   		this.startTimeField = startTimeField;
	   	}
	   	
	   	public String fieldToUpdate {get; set;}
	   	public String startTimeField {get; set;}
	   	
	}
}