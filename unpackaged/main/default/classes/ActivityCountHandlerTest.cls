/* Test Class to check the Code Coverage of the functionalty implemented in ActivityCountHandler Class.
 * 
 *
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 21/06/2013                         Initial Draft
 */ 
 
 
@isTest
public  class ActivityCountHandlerTest {


	/* The method will check the Code coverage of functionality implemented in ActivityCountHandler class
	 *  when there are records in ExcludedSubject Custom setting.  
	 */
    static testMethod void testActivityCountHandlerExcudedSubjectPresent(){
    	//Fetching Id of 'System Administrator' Profile.
    	Id ProfileID = [ Select id from Profile where name = 'System Administrator'][0].id;
    	
    	//Fetching User record by calling  getUser method of ActivityCountHandlerTest class.
    	User userRecord = ActivityCountHandlerTest.getUser(ProfileID);
    	insert userRecord;
    	
    	//Calling createLeadRecord for getting a Lead record.
    	Lead leadRecord = ActivityCountHandlerTest.createLeadRecord();
    	insert leadRecord;
    	
    	//Calling returnExcludedSubjectsList for getting list of Excluded Subjects.
    	List<ExcludedSubjects__c> excludedSubjectsList = ActivityCountHandlerTest.returnExcludedSubjectsList();
    	insert excludedSubjectsList;
    	
    	//Calling createTaskRecord for getting a Task record.
    	List<Task> lstTaskRecords = ActivityCountHandlerTest.createTaskRecord(userRecord.Id, leadRecord.Id);
    	
    	Database.SaveResult[] sr =  Database.insert(lstTaskRecords) ;
    	system.assert(sr[0].isSuccess());
    	
    	/* Updating Task Record and Providing Status = 'Not Started' to Decrease the Activity Count on edit 
    	 *  when status is Changed to the value other than 'Completed'.
    	 */
    	lstTaskRecords[0].Status = 'Not Started';
    	Database.SaveResult sr2 =  Database.update(lstTaskRecords[0]);
    	system.assert(sr2.isSuccess());
    	// Updating Task Record and Providing Status = 'Completed' to Increase the Activity Count on edit. 
    	lstTaskRecords[0].Status = 'Completed';
    	Database.SaveResult sr3 =  Database.update(lstTaskRecords[0]);
    	system.assert(sr3.isSuccess());
    	
    	//Changing the subject to that included in excluded List to decrease the Activity Count on edit. 
    	lstTaskRecords[0].Subject = 'Subject2';
    	Database.SaveResult sr4 =  Database.update(lstTaskRecords[0]);
    	system.assert(sr4.isSuccess());
    	
    	//Changing the subject to that not included in excluded List to increase the Activity Count on edit. 
    	lstTaskRecords[0].Subject = 'Test Task';
    	Database.SaveResult sr5 =  Database.update(lstTaskRecords[0]);
    	system.assert(sr5.isSuccess());
    	
    	//Deleting Task Record to decrease the activity Count.
    	Database.DeleteResult[] sr6 =  Database.delete(lstTaskRecords);
    	system.assert(sr6[0].isSuccess());
    	
    	//Calling createEventRecord for getting a Event record.
    	Event eventRecord = ActivityCountHandlerTest.createEventRecord(userRecord.Id, leadRecord.Id);
    	Database.SaveResult sr7 =  Database.insert(eventRecord);
    	system.assert(sr7.isSuccess());
    	
    	//Changing the subject to that included in excluded List to decrease the Activity Count on edit. 
    	eventRecord.Subject = 'Subject2';
    	Database.SaveResult sr9 =  Database.update(eventRecord);
    	system.assert(sr9.isSuccess());
    	
    	//Changing the subject to that not included in excluded List to increase the Activity Count on edit. 
    	eventRecord.Subject = 'Test Event';
    	Database.SaveResult sr10 =  Database.update(eventRecord);
    	system.assert(sr10.isSuccess());
    	
    	
       //Deleting Event Record to decrease the activity Count.
    	Database.DeleteResult sr11 =  Database.delete(eventRecord);
    	system.assert(sr11.isSuccess());
    	
    	
    }//End Method.
    
    
    /* The method will check the Code coverage of functionality implemented in ActivityCountHandler class
	 *  when there is no records in ExcludedSubject Custom setting.  
	 */
    static testMethod void testActivityCountHandlerExcudedSubjectEmpty(){
    	//Fetching Id of 'System Administrator' Profile.
    	ID ProfileID = [ Select id from Profile where name = 'System Administrator'][0].id;
    	
    	//Fetching User record by calling  getUser method of ActivityCountHandlerTest class.
    	User userRecord = ActivityCountHandlerTest.getUser(ProfileID);
    	insert userRecord;
    	
    	//Calling createLeadRecord for getting a Lead record.
    	Lead leadRecord = ActivityCountHandlerTest.createLeadRecord();
    	insert leadRecord;
    	 
    	 //Fetching Custom Setting Records and deleting them.
    	List<ExcludedSubjects__c> excludedSubjectsList = [Select Name, Subject__c From ExcludedSubjects__c];
    	delete(excludedSubjectsList);
    	
    	//Calling createTaskRecord for getting a Task record.
    	List<Task> lstTaskRecords = ActivityCountHandlerTest.createTaskRecord(userRecord.Id, leadRecord.Id);
    	Database.SaveResult[] sr =  Database.insert(lstTaskRecords) ;
    	system.assert(sr[0].isSuccess());
    	
    	/* Updating Task Record and Providing Status = 'Not Started' to Decrease the Activity Count on edit 
    	 *  when status is Changed to the value other than 'Completed'.
    	 */
    	lstTaskRecords[0].Status = 'Not Started';
    	Database.SaveResult sr2 =  Database.update(lstTaskRecords[0]);
    	system.assert(sr2.isSuccess());
    	
    	// Updating Task Record and Providing Status = 'Completed' to Increase the Activity Count on edit.
    	lstTaskRecords[0].Status = 'Completed';
    	Database.SaveResult sr3 =  Database.update(lstTaskRecords[0]);
    	system.assert(sr3.isSuccess());
    	
    	//Deleting Task Record to decrease the activity Count.
    	Database.DeleteResult[] sr5 =  Database.delete(lstTaskRecords);
    	system.assert(sr5[0].isSuccess());
    	
    	//Calling createEventRecord for getting a Event record.
    	Event eventRecord = ActivityCountHandlerTest.createEventRecord(userRecord.Id, leadRecord.Id);
    	Database.SaveResult sr6 =  Database.insert(eventRecord);
    	system.assert(sr6.isSuccess());
    	
        //Deleting Event Record to decrease the activity Count.
    	Database.DeleteResult sr9 =  Database.delete(eventRecord);
    	system.assert(sr9.isSuccess());
    	
    }//End Method.
    
    
    /* The method will return temporary Record of Lead Object.
     */
    public  static Lead createLeadRecord(){
    		Lead leadRecord = new Lead(FirstName = 'Rocky',  LastName = 'Belbouy', Company = 'Rocky Industries', Status = 'Open - Attempting Contact',
    													    Industry = 'Agriculture', LeadSource = 'Resource Nation', Annual_Gross_Sales__c = 80000, Phone = '8976543427',
    													    Email = 'rocky@gmail.com',  Description = 'Testing Lead',
    													    DBA_Name__c = 'Test Name');   
    		return leadRecord;
    }//End createLeadRecord method.
    
 
    
    /* The method will return temporary Record of Task Object.
     */
    private static List<Task> createTaskRecord(Id pUserId, Id pLeadId){
    	List<Task> lstTaskRecords = new List<Task>();
    	for(Integer index = 1; index <=4; index ++){
    		lstTaskRecords.add(new Task(Subject = 'Test Task' + index, Status = 'Completed', OwnerId = pUserId, Priority = 'Normal', WhoId =  pLeadId, Type = 'Call'));
    	}
    	return lstTaskRecords;
    }//End createTaskRecord method.
    
    
    /* The method will return temporary Record of Event Object.
     */
    private static Event createEventRecord(Id pUserId, Id pLeadId){
    	Event eventRecord = new Event(Subject = 'Test Event', WhoId = pLeadId, OwnerId = pUserId, StartDateTime = system.now() - 1 , EndDateTime = system.now());
    	return eventRecord;
    }//End createEventRecord method.
    
    
    /* Method will create dummy record of User.
     */
    public static User getUser(Id pProfileId){
    	User tempUser = new User( email='test-user@email.com',   
    												  profileid = pProfileId,
					                                  UserName='test-user1111@email.com', 
					                                  alias='tuser1', CommunityNickName='tuser1', 
					                                  TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', 
					                                  EmailEncodingKey='ISO-8859-1', 
					                                  LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User');
       return tempUser;
    }//End getUser method.
    
    
    /* Method will create List of dummy ExcludedSubjects Custom setting records.
     */
    public static List<ExcludedSubjects__c> returnExcludedSubjectsList(){
    	List<ExcludedSubjects__c> tempExcludedSubjectsList = new List<ExcludedSubjects__c>();
    	for(Integer index = 1; index <= 4 ; index ++){
    		tempExcludedSubjectsList.add(new ExcludedSubjects__c(Name = 'Subject' + index, Subject__c = 'Subject' + index));
    	}//End for.
    	return tempExcludedSubjectsList;
    }//End returnExcludedSubjectsList Method.
    
    
}//End ActivityCountHandlerTest.