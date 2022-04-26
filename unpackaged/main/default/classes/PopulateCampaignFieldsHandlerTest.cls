/* Test Class to check the code coverage of PopulateCampaignFieldsHandler Class.
  *
  *
  * Revision History:
 *   
 *  Version         Author                                      Date                                       Description
 *  1.0                  Ajay Singh Solanki                24/07/2013                         Initial Draft
  */
  
@isTest
private class PopulateCampaignFieldsHandlerTest {
	
	//Constants
	private static final String  STATUS_OPEN_ATTEMPT_CONT  = 'Open - Attempting Contact';  
	private static final String  STATUS_OPEN_AWAIT  = 'Open - Awaiting App (App Sent)';  
	private static final String  STATUS_CONVERTED_SIGNED  = 'Converted - Signed App';  
	private static final String  APINAME_OPEN_ATTEMPT_CONT  = 'Open_Attempting_Contact__c';    //Campaign field api Name
	private static final String  APINAME_OPEN_AWAIT  = 'Open_Awaiting_App_App_Sent__c'; 			   //Campaign field api Name
	private static final String  APINAME_CONVERTED_SIGNED  = 'Converted_Signed_App__c';			   //Campaign field api Name
	
	/* The method will check  the code coverage of onInsertCampaignMemberIncreaseStatusCounts method of 
	 * PopulateCampaignFieldsHandler  class.
	 */
    static testMethod void onInsertCampaignMemberTest() {
    		 //Calling returnleadStatusList for getting list of Lead Status.
	    	 List<LeadStatus__c> leadStatusList = PopulateCampaignFieldsHandlerTest.returnLeadStatusList();
	    	 insert leadStatusList;
    		
      		  //Creating dummy records for Campaign.
      		  List<Campaign> lstCampaign = PopulateCampaignFieldsHandlerTest.returnCampaignList();
      		  insert lstCampaign;
      		  
      		  //Creating dummy records for Lead.
      		  List<Lead> lstLeads = PopulateCampaignFieldsHandlerTest.returnLeads();
      		  insert lstLeads;
      		  
      		  //Creating dummy records for CampaignMember.
      		  List<CampaignMember> lstCampaignMember = PopulateCampaignFieldsHandlerTest.returnCampaignMembers(lstLeads, lstCampaign);
      		  insert lstCampaignMember; 
      		  
      		  //Database.SaveResult[] sr =  Database.insert(lstCampaignMember);
    		  //system.assert(sr[0].isSuccess());
    }//End onInsertCampaignMemberTest method.
    
    
    /* The method will check  the code coverage of onDeleteCampaignMemberDecreaseStatusCounts method of 
	 * PopulateCampaignFieldsHandler  class.
	 */
     static testMethod void onDeleteCampaignMemberTest() {
      		  //Creating dummy records for Campaign.
      		  List<Campaign> lstCampaign = PopulateCampaignFieldsHandlerTest.returnCampaignList();
      		  insert lstCampaign;
      		  
      		  //Creating dummy records for Lead.
      		  List<Lead> lstLeads = PopulateCampaignFieldsHandlerTest.returnLeads();
      		  insert lstLeads;
      		  
      		  //Creating dummy records for CampaignMember.
      		  List<CampaignMember> lstCampaignMember = PopulateCampaignFieldsHandlerTest.returnCampaignMembers(lstLeads, lstCampaign);
      		  insert lstCampaignMember;
      		  
      		  //Deleting CampaignMember.
      		  Database.DeleteResult[] sr =  Database.delete(lstCampaignMember);
    		  system.assert(sr[0].isSuccess());
    }//End onDeleteCampaignMemberTest method.
    
    
    /* The method will check  the code coverage of onDeleteLeadUpdateCampaign method of 
	 * PopulateCampaignFieldsHandler  class.
	 */
    static testMethod void onDeleteLeadTest() {
      		  //Creating dummy records for Campaign.
      		  List<Campaign> lstCampaign = PopulateCampaignFieldsHandlerTest.returnCampaignList();
      		  insert lstCampaign;
      		  
      		  //Creating dummy records for Lead.
      		  List<Lead> lstLeads = PopulateCampaignFieldsHandlerTest.returnLeads();
      		  insert lstLeads;
      		  
      		  //Creating dummy records for CampaignMember.
      		  List<CampaignMember> lstCampaignMember = PopulateCampaignFieldsHandlerTest.returnCampaignMembers(lstLeads, lstCampaign);
      		  insert lstCampaignMember;
      		  
      		  //Deleting Leads.
      		  Database.DeleteResult[] sr =  Database.delete(lstLeads);
    		  system.assert(sr[0].isSuccess());
    }//End onDeleteLeadTest method.
    
    
    /* The method will check  the code coverage of onUpdateLeadUpdateCountOnCampaign method of 
	 * PopulateCampaignFieldsHandler  class.
	 */
    static testMethod void onUpdateLeadTest() {
      		  //Creating dummy records for Campaign.
      		  List<Campaign> lstCampaign = PopulateCampaignFieldsHandlerTest.returnCampaignList();
      		  insert lstCampaign;
      		  
      		  //Creating dummy records for Lead.
      		  List<Lead> lstLeads = PopulateCampaignFieldsHandlerTest.returnLeads();
      		  insert lstLeads;
      		  system.debug('*** lstLeads***' + lstLeads[0].Id);
      		  //Creating dummy records for CampaignMember.
      		  List<CampaignMember> lstCampaignMember = PopulateCampaignFieldsHandlerTest.returnCampaignMembers(lstLeads, lstCampaign);
      		  insert lstCampaignMember;
      		  system.debug('*** lstLeads[0].Status Before***' +  lstLeads[0].Status);
      		  system.debug('***  lstLeads[1].Status Before***' + lstLeads[1].Status);
      		  lstLeads[0].Status = STATUS_OPEN_AWAIT;
      		  lstLeads[1].Status = STATUS_CONVERTED_SIGNED;
      		  system.debug('*** lstLeads[0].Status after***' +  lstLeads[0].Status);
      		  system.debug('***  lstLeads[1].Status after***' + lstLeads[1].Status);
      		  //Update Leads.  
      		  update(lstLeads);
      		  system.debug('*** lstLeads[0].Status after update***' +  lstLeads[0].Status);
      		  system.debug('***  lstLeads[1].Status after update***' + lstLeads[1].Status);
      		  
      		  //Database.SaveResult[] sr =  Database.update(lstLeads);
    		 // system.assert(sr[0].isSuccess());
    }//End onUpdateLeadTest method.
    
    
    /* The method will return dummy records of Lead.
     */
    public static List<Lead> returnLeads(){
    	List<Lead> tempLstLead  = new List<Lead>();
    	for(Integer index = 81; index <= 86; index++){
    		tempLstLead.add(	new Lead(Company = 'Panacia'+index,
  															 LastName  = 'Test Lead' + index,
  															 Status = STATUS_OPEN_ATTEMPT_CONT,
  															 Date_Lead_Received__c  = system.now(),
  															 LeadSource  ='Internet',
  															 Industry = 'Insurance',
  															 Annual_Gross_Sales__c = 3000 + index,
  															 Rating  = 'Hot',
  														 	Phone = '12345678'+index));
    	}    
	   return tempLstLead;											
    }//End method.
    
    /* Method will return List of Dummy Campaign records. 
     */
    public static List<Campaign> returnCampaignList(){
    	List<Campaign> lstCampaigns = new List<Campaign>();
    	for(Integer index = 71; index < 76; index++){
    		lstCampaigns.add(new Campaign(Name = 'Test Camp Record' + index, 
    															  IsActive = true , 
    															  ActualCost = 2000+index, 
    															  Expected_Apps_Funded__c = 10 + index,
    															   Expected_Leads_Apps__c = 20 + index));
    	}//End for.
    	
    	/*lstCampaigns.add(new Campaign(Name = 'Test Campaign record', 
															  IsActive = false , 
															  ActualCost = 2000, 
															  Expected_Apps_Funded__c = 10,
															  Expected_Leads_Apps__c = 20 ));*/
    	return lstCampaigns;
    }//End returnCampaignList method.
    
    /* The method will return dummy records of Campaign Members.
     */
	public static List<CampaignMember> returnCampaignMembers(List<Lead> lstLead, List<Campaign> lstCampaign ){
		List<CampaignMember> tempLstCampaignMember  = new List<CampaignMember>();
		system.debug('####ListCampaign####' + lstCampaign);
		for(Integer index = 0; index < 4; index++){
			tempLstCampaignMember.add( new CampaignMember(Status = 'Sent',
														 												CampaignId  = lstCampaign[index].Id,
														 												LeadId = lstLead[index].Id));	
		}
		//tempLstCampaignMember[0].LeadId  = lstLead[1].Id;
		//tempLstCampaignMember[1].CampaignId = lstCampaign[3].Id;
		//tempLstCampaignMember[2].CampaignId = lstCampaign[3].Id;
		return tempLstCampaignMember;
	}//End method.
    
    
    
    /* Method will create List of dummy LeadStatus__c Custom setting records.
     */
    public static List<LeadStatus__c> returnLeadStatusList(){
    	List<LeadStatus__c> tempLeadStatusList = new List<LeadStatus__c>();
    
    		tempLeadStatusList.add(new LeadStatus__c(Name = STATUS_OPEN_ATTEMPT_CONT, Campaign_Count_Lead_Status__c = APINAME_OPEN_ATTEMPT_CONT ));
    		tempLeadStatusList.add(new LeadStatus__c(Name = STATUS_OPEN_AWAIT, Campaign_Count_Lead_Status__c = APINAME_OPEN_AWAIT));
    		tempLeadStatusList.add(new LeadStatus__c(Name = STATUS_CONVERTED_SIGNED, Campaign_Count_Lead_Status__c = APINAME_CONVERTED_SIGNED ));
    	return tempLeadStatusList;
    }//End returnLeadStatusList Method.
    
}//End PopulateCampaignFieldsHandlerTest class.