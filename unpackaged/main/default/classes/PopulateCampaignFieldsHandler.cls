/* The Handler class to update Fields on Campaign record based on the Status of the Lead records related to  
 * that Campaign.
 *
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 16/07/2013                         Initial Draft
 */ 



public without sharing class PopulateCampaignFieldsHandler {
	
	//Constants
    private static final String  COUNT_INCREASE = 'Increase';
    private static final String  COUNT_DECREASE = 'Decrease';
    
    
    //Properties 
    private Map<String, String> mapLeadStatusWithCampaignField ;       //Map will contain Lead Status and api name of Campaign Field which maintain it's count.
    private String campaignfieldApiName = '';											//Variable will contain Api name of Campaign field that maintains count related to Lead Status.
	private Integer countOfStatus = 0; 														//Variable will count of Leads present in corresponding Lead Status.
	public static Boolean isExecuted = false;
    
    //Constructor
	public PopulateCampaignFieldsHandler(){
		mapLeadStatusWithCampaignField = new Map<String, String>();
		this.getLeadStatus();
	}//End Constructor.
    
    
    
    /* The method will populate mapLeadStatusWithCampaignField by fetching values from Campaign_Count_Lead_Status__c 
	 *  field of LeadStatus Custom Setting.
	 */
	public void getLeadStatus(){
		//Fetching all Status from LeadStatus__c Custom Setting.
		Map<String, LeadStatus__c > mapLeadStatus = LeadStatus__c.getAll();
		
		 for(String statusName : mapLeadStatus.keySet()){
		 	mapLeadStatusWithCampaignField.put(statusName.trim(), mapLeadStatus.get(statusName).Campaign_Count_Lead_Status__c.trim());          // Adding Status into list. 
		 }//End for.
	}//End getLeadStatus method.
    
    	
    	
	/* The method will increse the Status count fields on Campaign record whenever a new Lead is created 
	 *	and related to a Campaign.
	 */
	public void onInsertCampaignMemberIncreaseStatusCounts(List<CampaignMember> pLstNewCampaignMembers){
		Map<Id, CampaignMember> leadWithCampaignMemberRecord = new Map<Id, CampaignMember>();
		try{
		//Map will contain the Campaign Id and Campaign record that gets updated.
		Map<Id, Campaign> mapCampaignsToUpdate = new Map<Id, Campaign> (); 
		
		//List will contain Lead Records whose Custom campaign field gets updated.
		List<Lead> lstLeadsToUpdate = new List<Lead>();
		
		//Map will contain the Lead Id and set of all the Campaign Ids related to that Lead.
		Map<Id, Set<Id>> mapLeadalongWithCampaignIds = new Map<Id, Set<Id>>();
		
		//Map will contain Lead id alongwith Id of Latest Campaigns.
		Map<Id, Id> mapLeadNCampaignIds = new Map<Id, Id>();
		
		//Set will contain Id's of Campaigns whose Status count fieldss gets updated. 
		Set<Id> setIdOfCampaigns = new Set<Id>();
		
		for(CampaignMember campMember : pLstNewCampaignMembers){
			if(campMember.LeadId <> null){
				leadWithCampaignMemberRecord.put(campMember.LeadId, campMember);
				setIdOfCampaigns.add(campMember.CampaignId);
				//Putting Lead Id and it's latest related Campaign Id.
				mapLeadNCampaignIds.put(campMember.LeadId, campMember.CampaignId);
				//Checking if the mapLeadalongWithCampaignIds contains Lead Id or not.
				if(mapLeadalongWithCampaignIds.containsKey(campMember.LeadId))
					mapLeadalongWithCampaignIds.get(campMember.LeadId).add(campMember.CampaignId);
				else
			        mapLeadalongWithCampaignIds.put(campMember.LeadId, new Set<Id>{campMember.CampaignId});
			}//End if.
		}//End for.
		Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign> ([Select Id, 
																													          Name, 
																													   	      Lead_Source__c,
																													   	      Open_Attempting_Contact__c,
																													   	      Open_Awaiting_App_App_Sent__c,
																													   	      Converted_Signed_App__c,
																													   	      Converted_Verbal_App__c,
																													   	      Closed_Bad_Lead__c,
																													   	      Closed_Can_t_Reach__c,
																													   	      Closed_Not_Interested_Yet__c,
																													   	      Closed_Unqualified__c
																										          From Campaign 
																											      Where Id IN : setIdOfCampaigns 
																											      AND IsActive = true]);
		Map<Id, Lead> mapLeads = new Map<Id, Lead>([Select Id,
																									Status,
																									LeadSource
																					    From Lead
																					    Where Id IN : mapLeadalongWithCampaignIds.keySet()]);
	    
		for(Id idLead : mapLeadalongWithCampaignIds.keySet()){
			for(Id idCampaign :  mapLeadalongWithCampaignIds.get(idLead)){
				if(mapCampaigns.containsKey(idCampaign)){
					if(mapCampaignsToUpdate.containsKey(idCampaign))
						mapCampaignsToUpdate.put(idCampaign, 
																		this.compareUpdateCampaignStatus(mapLeads.get(idLead).Status, mapCampaignsToUpdate.get(idCampaign),
																																	 COUNT_INCREASE));
					else
						mapCampaignsToUpdate.put(idCampaign,
																		this.compareUpdateCampaignStatus(mapLeads.get(idLead).Status, mapCampaigns.get(idCampaign),
																																	 COUNT_INCREASE));
				}//End if.
			}//End for Inner. 
		}//End for.
		
		//Iterating mapLeadNCampaignIds to populate Lead Source and Campaign field of Lead with Latest Campaign values.
		for(Id idLead : mapLeadNCampaignIds.keySet()){
			if(mapCampaigns.get(mapLeadNCampaignIds.get(idLead)) <> null)
				lstLeadsToUpdate.add(new Lead(Id = idLead, 
																  	  Campaign__c = mapLeadNCampaignIds.get(idLead),
																      LeadSource  = mapCampaigns.get(mapLeadNCampaignIds.get(idLead)).Lead_Source__c));
		}//End 
		
		if(lstLeadsToUpdate.size() > 0)
			update(lstLeadsToUpdate);
		
		if(!mapCampaignsToUpdate.isEmpty())
			update(mapCampaignsToUpdate.values());
			
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       CampaignMember CampMemberRec = leadWithCampaignMemberRecord.get(IdforError);
		       CampMemberRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
	}//End increaseStatusCounts method.



	/* The method will update the Lead Status Count Fields on Campaign based on the Status of Lead and
	 *  will return updated campaign Record.  
	 */
	public Campaign compareUpdateCampaignStatus(String pLeadStatus, Campaign pCampaignRecord, String pOperation){
		if(!mapLeadStatusWithCampaignField.isEmpty() && mapLeadStatusWithCampaignField.containsKey(pLeadStatus.trim())){
			campaignfieldApiName = mapLeadStatusWithCampaignField.get(pLeadStatus);
			
			countOfStatus = Integer.valueOf(pCampaignRecord.get(campaignfieldApiName));
			
			countOfStatus =   (pOperation == COUNT_INCREASE) ? 
										   ((countOfStatus == null) ? 
										   	  1 : Integer.valueOf(pCampaignRecord.get(campaignfieldApiName)) + 1) :
									       ((countOfStatus == null || countOfStatus == 0) ?
									       	  0 : Integer.valueOf(pCampaignRecord.get(campaignfieldApiName)) - 1);
			
			pCampaignRecord.put(campaignfieldApiName, countOfStatus );
		}//End if 
		return pCampaignRecord;		
	}//End compareUpdateCampaignStatus  method.



	/* The method will reduce the Count of Status fields of Campaign whenever a CampaignMember is deleted.
	 */
	public void onDeleteCampaignMemberDecreaseStatusCounts(List<CampaignMember> pLstCampaignMembers){
		Map<Id, CampaignMember> leadWithCampaignMemberRecord = new Map<Id, CampaignMember>();
		try{
		//List will contain Lead Records whose Custom campaign and LeadSource field gets updated.
		List<Lead> lstLeadsToUpdate = new List<Lead>();
		
		//Set will contain Id of  Campaigns which gets updated.
		Set<Id> setIdOfCampaignsToUpdate  = new Set<Id>();
		
		//Set will contain Id of  Leads which gets updated.
		Set<Id> setIdOfLeadsToUpdate  = new Set<Id>();
		Map<Id, Campaign> mapCampaignsToUpdate = new Map<Id, Campaign> ();
		
		for(CampaignMember campMember : pLstCampaignMembers){
			if(campMember.LeadId <> null){
				leadWithCampaignMemberRecord.put(campMember.LeadId , campMember);
				setIdOfCampaignsToUpdate.add(campMember.CampaignId);
				setIdOfLeadsToUpdate.add(campMember.LeadId);
			}//End if.
		}//End for.
		
		Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign> ([Select Id, 
																													          Name, 
																													   	      Lead_Source__c,
																													   	      Open_Attempting_Contact__c,
																													   	      Open_Awaiting_App_App_Sent__c,
																													   	      Converted_Signed_App__c,
																													   	      Converted_Verbal_App__c,
																													   	      Closed_Bad_Lead__c,
																													   	      Closed_Can_t_Reach__c,
																													   	      Closed_Not_Interested_Yet__c,
																													   	      Closed_Unqualified__c
																										          From Campaign 
																											      Where IsActive = true]);
		
		Map<Id, Lead> mapLeads = new Map<Id, Lead>([Select Id,
																									Status,
																									LeadSource,
																									Campaign__c,
																									(Select Id, 
																												CampaignId, 
																												Campaign.IsActive,
																												LeadId 
																									 From CampaignMembers 
																									 Where Campaign.IsActive = true ORDER BY CreatedDate DESC
																									 LIMIT 2)
																					    From Lead
																					    Where Id IN : setIdOfLeadsToUpdate]);
		//Iterating CampaignMembers to reduce the Counts of Status fields of Campaign.
		for(CampaignMember campMember : pLstCampaignMembers){
			if(mapCampaigns.containsKey(campMember.CampaignId) && campMember.LeadId <> null){
				if(mapCampaignsToUpdate.containsKey(campMember.CampaignId))
						mapCampaignsToUpdate.put(campMember.CampaignId, this.compareUpdateCampaignStatus(mapLeads.get(campMember.LeadId).Status, 
																													 mapCampaignsToUpdate.get(campMember.CampaignId), COUNT_DECREASE));
					else
						mapCampaignsToUpdate.put(campMember.CampaignId, this.compareUpdateCampaignStatus(mapLeads.get(campMember.LeadId).Status, 
																							 						 mapCampaigns.get(campMember.CampaignId), COUNT_DECREASE));
			}//End if.
		}//End for.
		for(Id idLead : setIdOfLeadsToUpdate){
			Lead leadRecord = new Lead(Id = idLead);
			//Chacking if the Lead associated with Campaign member to delete has another Campaign Member associated with an Active Campaign.											
			if(mapLeads.get(idLead).CampaignMembers <> null &&  mapLeads.get(idLead).CampaignMembers.size() > 1){
				leadRecord.Campaign__c = mapLeads.get(idLead).CampaignMembers[1].CampaignId ;
				leadRecord.LeadSource = mapCampaigns.get(mapLeads.get(idLead).CampaignMembers[1].CampaignId).Lead_Source__c;
			}//End if.
			else
				leadRecord.Campaign__c = null;	
			
			lstLeadsToUpdate.add(leadRecord);
		}//End for
		if(!lstLeadsToUpdate.isEmpty())
			update(lstLeadsToUpdate);
		
		if(!mapCampaignsToUpdate.isEmpty())
			update(mapCampaignsToUpdate.values());
		}catch(Exception objexception){
			Id IdforError;
			 for (Integer index = 0; index < objexception.getNumDml(); index ++) {
		        IdforError =  objexception.getDmlId(index);
		       CampaignMember CampMemberRec = leadWithCampaignMemberRecord.get(IdforError);
		       CampMemberRec.addError(objexception.getDmlMessage(index));
		    }//End for.
		}//End Catch.
		
	}//End onDeleteCampaignMemberDecreaseStatusCounts method.

	
	
	/* The method will Update the Count of Status fields of Campaign whenever a Lead is Updated and Lead Status is Changed .
	 */
	public void onUpdateLeadUpdateCountOnCampaign(Map<Id, Lead> pMapOldLeads, Map<Id, Lead> pMapNewLeads){
		if(isExecuted == false){
			Map<Id, Campaign> mapCampaignsToUpdate = new Map<Id, Campaign> ();
			Set<Id> setIdLeadsWhoseCampaignToUpdate = new Set<Id>();			
			Set<Id> setIdCampaignsToUpdate = new Set<Id>();
			
			for(Lead leadNewRecord : pMapNewLeads.values()){
				Lead leadOldRecord = pMapOldLeads.get(leadNewRecord.Id);
				if(leadOldRecord.Status <> leadNewRecord.Status){
					setIdLeadsWhoseCampaignToUpdate.add(leadNewRecord.Id);
				}
			}//End for.	
			
			Map<Id, CampaignMember> mapCamapignMembers = new Map<Id, CampaignMember>( [Select Id, 
																																										   LeadId, 
																																										   CampaignId
																																							   From CampaignMember
																																							   Where LeadId IN : setIdLeadsWhoseCampaignToUpdate
																																							   AND Campaign.isActive = true]);
			for(Id idCampaignMember : mapCamapignMembers.keySet()){
				setIdCampaignsToUpdate.add(mapCamapignMembers.get(idCampaignMember).CampaignId);
			}//End for.
			Map<Id, Campaign> mapCampaigns = new Map<Id, Campaign>([Select Id, 
																														         Name, 
																														   	     Lead_Source__c,
																														   	     Open_Attempting_Contact__c,
																														   	     Open_Awaiting_App_App_Sent__c,
																														   	     Converted_Signed_App__c,
																														   	     Converted_Verbal_App__c,
																														   	     Closed_Bad_Lead__c,
																														   	     Closed_Can_t_Reach__c,
																														   	     Closed_Not_Interested_Yet__c,
																														   	     Closed_Unqualified__c
																											         From Campaign 
																												     Where Id IN : setIdCampaignsToUpdate 
																												     AND IsActive = true]);																												   
																																							   
			for(CampaignMember campMember : mapCamapignMembers.values()){ 
				if(mapCampaigns.containsKey(campMember.CampaignId)){
					if(mapCampaignsToUpdate.containsKey(campMember.CampaignId)){
							mapCampaignsToUpdate.put(campMember.CampaignId, this.compareUpdateCampaignStatus(pMapOldLeads.get(campMember.LeadId).Status, 
																														 mapCampaignsToUpdate.get(campMember.CampaignId), COUNT_DECREASE));
							mapCampaignsToUpdate.put(campMember.CampaignId, this.compareUpdateCampaignStatus(pMapNewLeads.get(campMember.LeadId).Status, 
																														 mapCampaignsToUpdate.get(campMember.CampaignId), COUNT_INCREASE));
																														 
																														 
					}//End if.
					else{
						mapCampaignsToUpdate.put(campMember.CampaignId, this.compareUpdateCampaignStatus(pMapOldLeads.get(campMember.LeadId).Status, 
																							 mapCampaigns.get(campMember.CampaignId), COUNT_DECREASE));
						mapCampaignsToUpdate.put(campMember.CampaignId, this.compareUpdateCampaignStatus(pMapNewLeads.get(campMember.LeadId).Status, 
																							 mapCampaignsToUpdate.get(campMember.CampaignId), COUNT_INCREASE));
					}//End else.
				}//End if.
			}//End for.
			
			if(!mapCampaignsToUpdate.isEmpty())
				update(mapCampaignsToUpdate.values());
			
			
			isExecuted = true;
		}//End if isExecuted.
	}//End onUpdateLeadUpdateCountOnCampaign method.
	
	
	
	/* The method will reduce the Count of Status fields of Campaign whenever a Lead is deleted.
	 */
	public void onDeleteLeadUpdateCampaign(List<Lead> lstDeletedLeads){
		//Map willl contain CampaignMember records that gets Deleted. 
		Map<Id,CampaignMember> mapIdCampaignMemberWhichGetsDeleted = new Map<Id,CampaignMember>([Select Id, 
																																																   LeadId, 
																																																   CampaignId,
																																																   Campaign.isActive
																																													   From CampaignMember
																																													   Where LeadId IN : lstDeletedLeads
																																													   AND Campaign.isActive = true]);
																																													  
																																													  
		
		if(!mapIdCampaignMemberWhichGetsDeleted.isEmpty())
			delete(mapIdCampaignMemberWhichGetsDeleted.values());
		
	}//End onDeleteLeadUpdateCampaign method.

}//End PopulateCampaignFieldsHandler class.