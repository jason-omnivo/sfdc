/* This class will check the code coverage of functionality implemented in LeadConversionHandler Class. 
 *
 *
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 21/06/2013                         Initial Draft
 */
 
@isTest
private class LeadConversionHandlerTest { 
	
	/* Method will check the code coverage of functionality implemented in mapFieldsToOpportunity_N_AccountMethod method
	 *  LeadConversionHandler Class.
	 */
    static testMethod void testMapFieldsToOpportunity_N_AccountMethod() {
    	
    	//Fetching Id of 'System Administrator' Profile.
    	Id ProfileID = [ Select id from Profile where name = 'System Administrator'][0].id;
    	
    	//Fetching User record by calling  getUser method of ActivityCountHandlerTest class.
    	User userRecord = ActivityCountHandlerTest.getUser(ProfileID);
    	insert userRecord;
    	
    	//Calling createCampaignRecord for getting a Campaign record.
    	Campaign campaignRecord = LeadConversionHandlerTest.createCampaignRecord(userRecord.Id);
    	insert campaignRecord;
    	
    	//Calling createLeadRecord for getting a Lead record.
    	Lead leadRecord = ActivityCountHandlerTest.createLeadRecord();
    	insert leadRecord;
    	
    	//Creating CampaignMember 
    	CampaignMember campaignMember = new CampaignMember(LeadId = leadRecord.Id, CampaignId = campaignRecord.Id);
    	insert campaignMember;
  
    	test.startTest();
    		Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(leadRecord.id);
			
			LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
			lc.setConvertedStatus(convertStatus.MasterLabel);
			
			Database.LeadConvertResult lcr = Database.convertLead(lc);
			system.assert(lcr.isSuccess());
		test.stopTest();

        // test coverage for lead trigger
        //Opportunity opp = new Opportunity(Name = 'test',
        //                                    StageName = 'Open',
        //                                    CloseDate = System.today());
        //insert opp;
        //Contact con = new Contact(LastName = 'Test');
        //insert con;

        //OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id,
        //                                                        ContactId = con.Id,
        //                                                        IsPrimary = false);
        //insert ocr;

        //leadRecord.IsConverted = true;
        //leadRecord.ConvertedOpportunityId = opp.Id;
        //leadRecord.ConvertedContactId = con.Id;

        //update leadRecord;

    }//End testMapFieldsToOpportunity_N_AccountMethod method.
    
    
    /* Method will create a dummy record of Campaign Object.
     */
    public static Campaign createCampaignRecord(Id pUserId){
    	Campaign campaignRecord = new Campaign(Name = 'Test Campaign', IsActive = true, Description = 'This is a test Campaign',
    																			  OwnerId = pUserId, Type = 'Advertisement', Status = 'Planned');
    	return campaignRecord;
    }//End createCampaignRecord method.
    
}//End LeadConversionHandlerTest class.