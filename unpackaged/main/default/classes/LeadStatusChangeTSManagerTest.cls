@IsTest(SeeAllData=true)
public with sharing class LeadStatusChangeTSManagerTest {
    
    static testMethod void testStatusChange(){
    	
    	Lead leadRecord = ActivityCountHandlerTest.createLeadRecord();
    	Utils.now = DateTime.now();
    	insert leadRecord;
    	leadRecord = [SELECT Id, Status_Open_Attempting_Contact_Date_Time__c FROM Lead WHERE Id = :leadRecord.Id];
    	System.assertEquals(leadRecord.Status_Open_Attempting_Contact_Date_Time__c, Utils.now);
    	
    	decimal expectedBH;
    	Utils.now = DateTime.now().addDays(1);
    	leadRecord.Status = 'Open - Awaiting App (App Sent)'; 
    	update leadRecord;
    	leadRecord = [SELECT Id, Status_Open_Attempting_Contact_Date_Time__c, Status_Open_Awaiting_App_Date_Time__c,
    	Bus_Hours_Until_App_Sent__c, Bus_Days_Until_App_Sent__c FROM Lead WHERE Id = :leadRecord.Id];
    	expectedBH = getBH(leadRecord.Status_Open_Attempting_Contact_Date_Time__c, leadRecord.Status_Open_Awaiting_App_Date_Time__c);
    	System.assertEquals(leadRecord.Status_Open_Awaiting_App_Date_Time__c, Utils.now);
    	System.assertEquals(leadRecord.Bus_Hours_Until_App_Sent__c, expectedBH);
    	System.assertEquals(leadRecord.Bus_Days_Until_App_Sent__c, round(expectedBH / 8.33));
    	
    	Utils.now = DateTime.now().addDays(3);
    	leadRecord.Status = 'Converted - Signed App';
    	update leadRecord;
    	leadRecord = [SELECT Id, Status_Open_Attempting_Contact_Date_Time__c, Status_Converted_Signed_App_Date_Time__c, Status_Open_Awaiting_App_Date_Time__c,
    	Bus_Hours_Until_Converted__c, Bus_Days_Until_Converted__c,
    	Bus_Hours_App_Sent_Until_Converted__c, Bus_Days_App_Sent_Until_Converted__c,
    	Bus_Hours_Last_Activity_To_Converted__c, Bus_Days_Last_Activity_To_Converted__c FROM Lead WHERE Id = :leadRecord.Id];
    	expectedBH = getBH(leadRecord.Status_Open_Attempting_Contact_Date_Time__c, leadRecord.Status_Converted_Signed_App_Date_Time__c);
    	System.assertEquals(leadRecord.Status_Converted_Signed_App_Date_Time__c, Utils.now);
    	System.assertEquals(leadRecord.Bus_Hours_Until_Converted__c, expectedBH);
    	System.assertEquals(leadRecord.Bus_Days_Until_Converted__c, round(expectedBH / 8.33));
    	
    	expectedBH = getBH(leadRecord.Status_Open_Awaiting_App_Date_Time__c, leadRecord.Status_Converted_Signed_App_Date_Time__c);
    	System.assertEquals(leadRecord.Bus_Hours_App_Sent_Until_Converted__c, expectedBH);
    	System.assertEquals(leadRecord.Bus_Days_App_Sent_Until_Converted__c, round(expectedBH / 8.33));
    	System.assertEquals(leadRecord.Bus_Hours_Last_Activity_To_Converted__c, null);
    	System.assertEquals(leadRecord.Bus_Days_Last_Activity_To_Converted__c, null);
    	
    	Utils.now = DateTime.now().addDays(5);
    	leadRecord.Status = 'Closed - Unqualified';
    	update leadRecord;
    	leadRecord = [SELECT Id, Status_Open_Attempting_Contact_Date_Time__c, Status_Closed_Unqualified_Date_Time__c,
    	Bus_Hours_Until_Closed__c, Bus_Days_Until_Closed__c, Bus_Hours_Last_Activity_Until_Closed__c,
    	Bus_Days_Last_Activity_Until_Closed__c FROM Lead WHERE Id = :leadRecord.Id];
    	expectedBH = getBH(leadRecord.Status_Open_Attempting_Contact_Date_Time__c, leadRecord.Status_Closed_Unqualified_Date_Time__c);
    	System.assertEquals(leadRecord.Bus_Hours_Until_Closed__c, expectedBH);
    	System.assertEquals(leadRecord.Status_Closed_Unqualified_Date_Time__c, Utils.now);
    	System.assertEquals(leadRecord.Bus_Days_Until_Closed__c, round(expectedBH / 8.33));
    	System.assertEquals(leadRecord.Bus_Hours_Last_Activity_Until_Closed__c, null);
    	System.assertEquals(leadRecord.Bus_Days_Last_Activity_Until_Closed__c, null);
    	
    }
    
	private static decimal getBH(DateTime startTime, DateTime endTime) {
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
		Long diff = BusinessHours.diff(bh.Id, startTime, endTime);
		Decimal num = diff / 1000.0 / 60.0 / 60.0;
		Decimal fixedNum = num.setScale(2, RoundingMode.HALF_DOWN);
		return fixedNum;
	}
	
	private static decimal round(decimal num) {
		return num.setScale(2, RoundingMode.HALF_DOWN);
	}
	
}