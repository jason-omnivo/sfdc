/*  The Handler class to update Fields on Campaign record based on the Statges, Funding amount, Primary Campaign 
 *	 and Type of the Opportunity records related to that Campaign.
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 18/07/2013                         Initial Draft
 */ 


public with sharing class PopulateCampaignFIeldsForOppHandler {
	//Constants
	private static final String  STAGE_CLOSED_WON  = 'Closed Won';               								//Opportunity Stage Name.
	private static final String  COUNT_INCREASE = 'Increase';															//Increase count fields on Campaign
    private static final String  COUNT_DECREASE = 'Decrease';														//Decrease count fields on Campaign
    
	
	//Properties
	private Map<String, String> mapOppStagesWithCampaignField;  //Map will contain Opportunity  Stages and api name of Campaign Field which maintain it's count.
	private Map<String, String> mapOppTypesWithCampaignField;    //Map will contain Opportunity Type and api name of Campaign Field which maintain it's count.
	private Map<Id, Double> mapCampaignRelatedAmount ;  			 //Map will contain Campaign Id and sum of amount field of related Oppporunities Where Stage is closed Won.
	private Map<Id, Double> mapCampaignRelatedFundAmt ;  		 //Map will contain Campaign Id and sum of Funding amount field of related Oppporunities Where Stage is closed Won.
	private String campaignfieldApiName = '';
	private Integer countOfStages = 0; 
	private Integer countOfTypes = 0; 
	private Double fundingAmount = 0;
	private Double amountOfOpp = 0;
	public static Boolean isExecuted = false;
	
	
	//Constructor
	public PopulateCampaignFIeldsForOppHandler(){
		mapCampaignRelatedAmount = new Map<Id, Double>();
		mapCampaignRelatedFundAmt = new Map<Id, Double>();
		mapOppStagesWithCampaignField = new Map<String, String>();
		mapOppTypesWithCampaignField = new Map<String, String>();
		this.getOpportunityStagesNTypes();
	}//End Constructor.
	
	
	
	/* The method will populate mapOppStagesWithCampaignField by fetching values from CampaignFieldApiName 
	 *  field of OpportunityStages Custom Setting.
	 */
	public void getOpportunityStagesNTypes(){
		//Fetching all Stages from OpportunityStages Custom Setting.
		Map<String, OpportunityStages__c> mapOppStages = OpportunityStages__c.getAll();
		
		 for(String stageName : mapOppStages.keySet()){
		 	mapOppStagesWithCampaignField.put(stageName.trim(), mapOppStages.get(stageName).CampaignFieldApiName__c.trim());          // Adding Stage into list. 
		 }//End for.
		 //Fetching all Types from OpportunityTypes Custom Setting.
		Map<String, OpportunityTypes__c> mapOppTypes = OpportunityTypes__c.getAll();
		 for(String opportunityType : mapOppTypes.keySet()){
		 	mapOppTypesWithCampaignField.put(opportunityType,
		 																  mapOppTypes.get(opportunityType).Campaign_Opp_Type_Api_Name__c.trim());          			// Adding Type into list. 
		 }//End for.
	}//End getOpportunityStages method.
	
	
	 
	/* Method will update fields on Campaign when a new Opportunity is created and Related to an Active Campaign.
	 */
	public void onInsertOpportunityUpdateCampaign(Map<Id, Opportunity> pMapNewOpportunities){
		
		//Map will contain Campaign Id and List of Campaigns that gets updated. 
		Map<Id, Campaign> mapCampaignsToUpdate = new Map<Id, Campaign>();
		
		//Map will contain Opportunity Id and it's Campaign Id. 
		Map<Id, Id> mapIdOppNCamapaign = new Map<Id, Id>();
		
		for(Opportunity oppRecord :  pMapNewOpportunities.values()){
			if(oppRecord.CampaignId <> null){
				
				if(oppRecord.StageName.trim() == STAGE_CLOSED_WON){
					this.updatedCampaignAmount(mapCampaignRelatedAmount , oppRecord, COUNT_INCREASE );
					this.updatedCampaignFundingAmount(mapCampaignRelatedFundAmt, oppRecord, COUNT_INCREASE);
				}//End if
				
				mapIdOppNCamapaign.put(oppRecord.Id, oppRecord.CampaignId );
			}//End if Outer.
		}//End for. 
		
		//Map will contain Campaign records.
		Map<Id, Campaign> mapCampaignRecords = new Map<Id, Campaign>([Select Id, 
																																 		ActualCost,
																						 									   			Opportunities_Agreements_Sent__c,
																						 									   			Opportunities_Application_In__c,
																						 									   			Opportunities_Application_Missing_In__c,
																						 									   			Opportunities_Approved__c,
																						 									   			Opportunities_Closed_Lost__c,
																						 									   			Opportunities_Closed_Won__c,
																						 									   			Opportunities_Declined__c,
																						 									   			Opportunities_Default__c,
																						 									   			Opportunities_Funded__c,
																						 									   			Opportunities_Ready_to_Submit__c,
																						 									   			Opportunities_Renewals__c,
																						 									   			Opportunities_Signed__c,
																						 									   			Opportunities_Underwriting__c,
																						 									   			Opportunities_Renewal__c,
																						 									   			Opportunities_New_Deal__c,
																						 									   			Funded__c,
																						 									   	 		FundedAmount__c
																															   	 From Campaign
																															     Where Id IN : mapIdOppNCamapaign.values()
																															     AND isActive = true]);
		
		//Calling method to update Amount and Funding amount of Campaign related to a Opportunity.
		this.updatedCampaignAmt_N_FundingAmt(mapCampaignRelatedAmount, mapCampaignRelatedFundAmt, pMapNewOpportunities.values());
		
		//Iterating New Opportunities  to update Fields on Campaign based on Opportunity.
		for(Id IdOppRecord :  mapIdOppNCamapaign.keySet()){
			if(mapCampaignRecords.containsKey(pMapNewOpportunities.get(IdOppRecord).CampaignId)){
				if(mapCampaignsToUpdate.containsKey(pMapNewOpportunities.get(IdOppRecord).CampaignId)){
					mapCampaignsToUpdate.put(pMapNewOpportunities.get(IdOppRecord).CampaignId ,
																	updateCampaignStagesCount(pMapNewOpportunities.get(IdOppRecord).StageName,
																													 mapCampaignsToUpdate.get(pMapNewOpportunities.get(IdOppRecord).CampaignId),
																													 COUNT_INCREASE));
					
					mapCampaignsToUpdate.put(pMapNewOpportunities.get(IdOppRecord).CampaignId ,
																	updateCampaignOppType(pMapNewOpportunities.get(IdOppRecord).Type,
																											   mapCampaignsToUpdate.get(pMapNewOpportunities.get(IdOppRecord).CampaignId),
																											   COUNT_INCREASE));
				}//End if.
				else{
					mapCampaignsToUpdate.put(pMapNewOpportunities.get(IdOppRecord).CampaignId ,
																	updateCampaignStagesCount(pMapNewOpportunities.get(IdOppRecord).StageName,
																													 mapCampaignRecords.get(pMapNewOpportunities.get(IdOppRecord).CampaignId),
																													 COUNT_INCREASE));
																									  
					mapCampaignsToUpdate.put(pMapNewOpportunities.get(IdOppRecord).CampaignId ,
																	updateCampaignOppType(pMapNewOpportunities.get(IdOppRecord).Type,
																											   mapCampaignsToUpdate.get(pMapNewOpportunities.get(IdOppRecord).CampaignId),
																											   COUNT_INCREASE));
				}//End else.
			}//End if.
		}//End for. 
		
		//Iterating Campaigns that gets Updated to populate ROI % and # Funded fields.
		for(Campaign campRecord : mapCampaignsToUpdate.values()){
			if(mapCampaignRelatedFundAmt.get(campRecord.Id) <> null)
				campRecord.FundedAmount__c = mapCampaignRelatedFundAmt.get(campRecord.Id);
			campRecord.Funded__c = campRecord.Opportunities_Closed_Won__c;
		}//End for.
		
		if(mapCampaignsToUpdate.values().size() > 0)
			update(mapCampaignsToUpdate.values());
		
	}//End onInsertOpportunityUpdateCampaign method.
	
	
	
	/* Method will update fields on Campaign when a Opportunity is Updated and Related to an Active Campaign.
	 */
	public void onUpdateOppUpdatecamapign(Map<Id, Opportunity> pMapOldOpp, Map<Id, Opportunity> pMapNewOpp){
		if(isExecuted == false){
		
			//Map will contain Campaign Id along with Campaign that gets updated. 
			Map<Id, Campaign> mapCampaignsToUpdate = new Map<Id, Campaign>();
			
			//Map will contain Campaign Id along with Campaign which are Active. 
			Map<Id, Campaign> mapCampaignRecord = new Map<Id, Campaign>();
			
			//Map will contain Opportunity Id along with  Opportunity whose Campaign Id is updated to null. 
			Map<Id, Opportunity> mapOppWithCampaignNull = new Map<Id, Opportunity>();
			 
	        //Map will contain Opportunity Id and Campaign Id for Opportunity whose Stage has been changed.
	        Map<Id, Id> mapIdOppStagesUpdated = new Map<Id, Id>();
	                
	        //Map will contain Opportunity Id and Campaign Id for Opportunity whose Primary Campaign has been changed.
	        Map<Id, Id> mapIdOppCampaignUpdated = new Map<Id, Id>();
	                
	        //Map will contain Opportunity Id and Campaign Id for Opportunity whose Type has been chnaged.
	        Map<Id, Id> mapIdOppTypeUpdated = new Map<Id, Id>();
	        
	        //Set will contain ids of Opportunities whose amount has been calculated.
	        Set<Id> idOppWhoseAmountCalculated = new Set<Id>();
	        
	        //Set will contain Id's of old Campaigns.
	        Set<Id> idOldCampaigns = new Set<Id>();
	        
	        for(Opportunity oppNewRecord : pMapNewOpp.values()){
	        	Opportunity oppOldRecord = pMapOldOpp.get(oppNewRecord.Id);
	        	//Checking if the CampaignId in new Opportunity is not null.
	        	if(oppNewRecord.CampaignId <> null){
	        		
	        		if(oppOldRecord.CampaignId <> oppNewRecord.CampaignId){
		                mapIdOppCampaignUpdated.put(oppNewRecord.Id, oppNewRecord.CampaignId);
		                idOldCampaigns.add(oppOldRecord.CampaignId);
		                //Checking if the Opportunity Stage is Closed Won.
		                if(oppNewRecord.StageName.trim() == STAGE_CLOSED_WON){
		                	this.updatedCampaignAmount(mapCampaignRelatedAmount, oppNewRecord, COUNT_INCREASE );
		                	this.updatedCampaignFundingAmount(mapCampaignRelatedFundAmt, oppNewRecord, COUNT_INCREASE);
		                }//End if STAGE_CLOSED_WON.
						if(oppOldRecord.CampaignId <> null && oppOldRecord.StageName == STAGE_CLOSED_WON){
							this.updatedCampaignAmount(mapCampaignRelatedAmount, oppOldRecord, COUNT_DECREASE);
							this.updatedCampaignFundingAmount(mapCampaignRelatedFundAmt, oppOldRecord, COUNT_DECREASE);
						}//End if Old STAGE_CLOSED_WON.
		            }//End if CampaignId Changed.
	        		
	        		
		            //Checking if the Opportunity Stage has been changed.
		            if(oppOldRecord.StageName <> oppNewRecord.StageName && !mapIdOppCampaignUpdated.containsKey(oppNewRecord.Id)){
		                mapIdOppStagesUpdated.put(oppNewRecord.Id, oppNewRecord.CampaignId);         
		                //Checking if the Opportunity Stage has been changed to Closed Won.
		                if(oppNewRecord.StageName.trim() == STAGE_CLOSED_WON && !idOppWhoseAmountCalculated.contains(oppNewRecord.Id)){
		                	this.updatedCampaignAmount(mapCampaignRelatedAmount, oppNewRecord, COUNT_INCREASE );
		                	this.updatedCampaignFundingAmount(mapCampaignRelatedFundAmt, oppNewRecord, COUNT_INCREASE);
		                	idOppWhoseAmountCalculated.add(oppNewRecord.Id);
		                	
		                }//End if inner.
		                //Checking if the Opportunity Stage has been changed from Closed Won.
		                else if(oppOldRecord.StageName.trim() == STAGE_CLOSED_WON && oppOldRecord.CampaignId <> null){
		                	this.updatedCampaignAmount(mapCampaignRelatedAmount, oppOldRecord, COUNT_DECREASE  );
		                	this.updatedCampaignFundingAmount(mapCampaignRelatedFundAmt, oppOldRecord, COUNT_DECREASE);
		                	idOppWhoseAmountCalculated.add(oppOldRecord.Id);
		                }//End else if.
		            }//End if StageName.
		            
		            if(oppOldRecord.Type <> oppNewRecord.Type && !mapIdOppCampaignUpdated.containsKey(oppNewRecord.Id))
		                mapIdOppTypeUpdated.put(oppNewRecord.Id, oppNewRecord.CampaignId);    
		            
		            if(oppOldRecord.Funding_Amt__c <> oppNewRecord.Funding_Amt__c &&  oppNewRecord.StageName.trim() == STAGE_CLOSED_WON 
		            	&& !mapIdOppCampaignUpdated.containsKey(oppNewRecord.Id) && !idOppWhoseAmountCalculated.contains(oppNewRecord.Id)){
		            	this.updatedCampaignFundingAmount(mapCampaignRelatedFundAmt, oppNewRecord, COUNT_INCREASE);
		            }//End if
		                
		            if(oppOldRecord.Amount <> oppNewRecord.Amount && oppNewRecord.StageName.trim() == STAGE_CLOSED_WON
		            	&&  !mapIdOppCampaignUpdated.containsKey(oppNewRecord.Id) && !idOppWhoseAmountCalculated.contains(oppNewRecord.Id)){
		            	this.updatedCampaignAmount(mapCampaignRelatedAmount, oppNewRecord, COUNT_INCREASE );
		            }//End if oppOldRecord.Amount <> oppNewRecord.Amount.
		            
	        	}//End if oppNewRecord.CampaignId <> null. 	
	        	
	        	//Checking if the CampaignId in new Opportunity is updated to null.
	        	if(oppNewRecord.CampaignId <> oppOldRecord.CampaignId && oppNewRecord.CampaignId == null){
	        		mapOppWithCampaignNull.put(oppNewRecord.Id, oppOldRecord);
	        	}//End if oppNewRecord.CampaignId == null.
	        }//End for.
	        
	        mapCampaignRecord = new Map<Id, Campaign>([Select Id,
																										 ActualCost,
														 									   			 Opportunities_Agreements_Sent__c,
														 									   			 Opportunities_Application_In__c,
														 									   			 Opportunities_Application_Missing_In__c,
														 									   			 Opportunities_Approved__c,
														 									   			 Opportunities_Closed_Lost__c,
														 									   			 Opportunities_Closed_Won__c,
														 									   			 Opportunities_Declined__c,
														 									   			 Opportunities_Default__c,
														 									   			 Opportunities_Funded__c,
														 									   			 Opportunities_Ready_to_Submit__c,
														 									   			 Opportunities_Renewals__c,
														 									   			 Opportunities_Signed__c,
														 									   			 Opportunities_Underwriting__c,
														 									   		 	 Opportunities_Renewal__c,
														 									   			 Opportunities_New_Deal__c,
														 									   			 Funded__c,
														 									   	 		 FundedAmount__c
														                                        From Campaign
														                                        Where (Id IN : mapIdOppStagesUpdated.values() 
																                                              OR Id IN : mapIdOppCampaignUpdated.values() 
																                                              OR Id IN : mapIdOppTypeUpdated.values()
																                                              OR Id IN : mapCampaignRelatedFundAmt.keySet()
																                                              OR Id IN : mapCampaignRelatedAmount.keySet()
																                                              OR Id IN : idOldCampaigns)
														                                        AND isActive = true]);
	                                           
	        //Updating Campaigns whose related Opportunities Stage field has been updated.                                   
			for(Id IdOppRecord : mapIdOppStagesUpdated.keySet()){
				if(mapCampaignRecord.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
						if(mapCampaignsToUpdate.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
							
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignStagesCount(pMapNewOpp.get(IdOppRecord).StageName,
																															 mapCampaignsToUpdate.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																															 COUNT_INCREASE));
						}//End if.
						else{
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignStagesCount(pMapNewOpp.get(IdOppRecord).StageName,
																															 mapCampaignRecord.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																															 COUNT_INCREASE));
						}//End else
				}//End if outer.
				if(mapCampaignRecord.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
					if(mapCampaignsToUpdate.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																				updateCampaignStagesCount(pMapOldOpp.get(IdOppRecord).StageName,
																																 mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																																 COUNT_DECREASE));
					}//End if.
					else{
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignStagesCount(pMapOldOpp.get(IdOppRecord).StageName,
																															 mapCampaignRecord.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																															 COUNT_DECREASE));
					}//End else
				}//End if.
			} //End for                               
	                   
	        for(Id IdOppRecord : mapIdOppCampaignUpdated.keySet()){ 
	        	
	        	/*******************Updating Stages count fields of New and Old Campaigns******************/
	        	if(mapCampaignRecord.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
						if(mapCampaignsToUpdate.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
							
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignStagesCount(pMapNewOpp.get(IdOppRecord).StageName,
																															 mapCampaignsToUpdate.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																															 COUNT_INCREASE));
						}//End if.
						else{
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignStagesCount(pMapNewOpp.get(IdOppRecord).StageName,
																															 mapCampaignRecord.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																															 COUNT_INCREASE));
						}//End else
				}//End if Updating Stages new.
				if(mapCampaignRecord.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
					if(mapCampaignsToUpdate.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																				updateCampaignStagesCount(pMapOldOpp.get(IdOppRecord).StageName,
																																 mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																																 COUNT_DECREASE));
					}//End if.
					else{
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignStagesCount(pMapOldOpp.get(IdOppRecord).StageName,
																															 mapCampaignRecord.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																															 COUNT_DECREASE));
					}//End else
				}//End if Updating Stages old.
				
				/*******************Updating Count of Opportunity Type  of New and Old Campaigns******************/
				if(mapCampaignRecord.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
						if(mapCampaignsToUpdate.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
							
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignOppType(pMapNewOpp.get(IdOppRecord).Type,
																												 	   mapCampaignsToUpdate.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																												 	   COUNT_INCREASE));
						}//End if.
						else{
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignOppType(pMapNewOpp.get(IdOppRecord).Type,
																												 	   mapCampaignRecord.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																												 	   COUNT_INCREASE));
						}//End else
				}//End if Updating Type new.
				if(mapCampaignRecord.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
					if(mapCampaignsToUpdate.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																		updateCampaignOppType(pMapOldOpp.get(IdOppRecord).Type,
																											 	   mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																											 	   COUNT_DECREASE));
					}//End if.
					else{
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																		updateCampaignOppType(pMapOldOpp.get(IdOppRecord).Type,
																											 	   mapCampaignRecord.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																											 	   COUNT_DECREASE));
					}//End else
				}//End if Updating Type old.
			}//End for                                  
	        
	        //Updating Campaigns whose related Opportunities Type field has been updated. 
	        for(Id IdOppRecord : mapIdOppTypeUpdated.keySet()){
	        	if(mapCampaignRecord.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
						if(mapCampaignsToUpdate.containsKey(pMapNewOpp.get(IdOppRecord).CampaignId)){
							
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignOppType(pMapNewOpp.get(IdOppRecord).Type,
																												 	   mapCampaignsToUpdate.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																												 	   COUNT_INCREASE));
						}//End if.
						else{
							mapCampaignsToUpdate.put(pMapNewOpp.get(IdOppRecord).CampaignId ,
																			updateCampaignOppType(pMapNewOpp.get(IdOppRecord).Type,
																												 	   mapCampaignRecord.get(pMapNewOpp.get(IdOppRecord).CampaignId),
																												 	   COUNT_INCREASE));
						}//End else
				}//End if outer.
				if(mapCampaignRecord.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
					if(mapCampaignsToUpdate.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																		updateCampaignOppType(pMapOldOpp.get(IdOppRecord).Type,
																											 	   mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																											 	   COUNT_DECREASE));
					}//End if.
					else{
						mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																		updateCampaignOppType(pMapOldOpp.get(IdOppRecord).Type,
																											 	   mapCampaignRecord.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																											 	   COUNT_DECREASE));
					}//End else
				}//End if.
			}//End for                       
			
			//Calling method to update Amount and Funding amount of Campaign related to a Opportunity.
			this.updatedCampaignAmt_N_FundingAmt(mapCampaignRelatedAmount, mapCampaignRelatedFundAmt, pMapNewOpp.values());
			
			
			//Iterating Campaigns that gets Updated to populate ROI % , # Funded and $ Funded fields .  
			for(Id IdCampaign : mapCampaignRecord.keySet()){
				Campaign campToUpdate = mapCampaignRecord.get(IdCampaign);
				
				if(mapCampaignsToUpdate.containsKey(IdCampaign)){
					campToUpdate.Funded__c = mapCampaignsToUpdate.get(IdCampaign).Opportunities_Closed_Won__c;
				}
				
				if(mapCampaignRelatedFundAmt.get(IdCampaign) <> null)	
					campToUpdate.FundedAmount__c = mapCampaignRelatedFundAmt.get(IdCampaign);
					
				mapCampaignsToUpdate.put(campToUpdate.Id, campToUpdate);
			}//End for.			
			
			if(!mapOppWithCampaignNull.isEmpty()){
				/* calling onDeleteOppUpdatecamapign mathod to Update the fields on Campaign if  opportunities whose 
				 *  Campaign  is updated to null are present in mapOppWithCampaignNull.
				 */
				this.onDeleteOppUpdatecamapign(mapOppWithCampaignNull);        
			}//End if.
			
			if(!mapCampaignsToUpdate.isEmpty())
				update(mapCampaignsToUpdate.values());    
			
			isExecuted = true;
		}//End if isExecuted.                               
                                           
    }//End onUpdateOppUpdatecamapign method.
	
	
	 
	/* Method will update fields on Campaign when a Opportunity is Deleted and was related to an Active Campaign.
	 */
	public void onDeleteOppUpdatecamapign(Map<Id, Opportunity> pMapOldOpp){
		//Map will contain Campaign Id and List of Campaigns that gets updated. 
		Map<Id, Campaign> mapCampaignsToUpdate = new Map<Id, Campaign>();
		//Map will contain Opportunity Id and it's Campaign Id. 
		Map<Id, Id> mapIdOppNCamapaign = new Map<Id, Id>();
		//Map will contain Active Campaign records.
		Map<Id, Campaign> mapCampaignRecords = new Map<Id, Campaign>();
		
		for(Opportunity oppRecord : pMapOldOpp.values()){
				mapIdOppNCamapaign.put(oppRecord.Id, oppRecord.CampaignId);             //Adding Oppp Id and it's Campaign Id.
				mapCampaignRelatedAmount.put(oppRecord.CampaignId, 0);
				mapCampaignRelatedFundAmt.put(oppRecord.CampaignId, 0);
		}//End for
		
		//Map will contain Campaign records.
		mapCampaignRecords = new Map<Id, Campaign>([Select Id, 
																								 	   ActualCost,
														 									   		   Opportunities_Agreements_Sent__c,
														 									   		   Opportunities_Application_In__c,
														 									   		   Opportunities_Application_Missing_In__c,
														 									   		   Opportunities_Approved__c,
														 									   		   Opportunities_Closed_Lost__c,
														 									   		   Opportunities_Closed_Won__c,
														 									   		   Opportunities_Declined__c,
														 									   		   Opportunities_Default__c,
														 									   		   Opportunities_Funded__c,
														 									   		   Opportunities_Ready_to_Submit__c,
														 									   		   Opportunities_Renewals__c,
														 									   		   Opportunities_Signed__c,
														 									   		   Opportunities_Underwriting__c,
														 									   		   Opportunities_Renewal__c,
														 									   		   Opportunities_New_Deal__c,
														 									   		   Funded__c,
														 									   	 	   FundedAmount__c
																							From Campaign
																							Where Id IN : mapIdOppNCamapaign.values()
																							AND isActive = true]);
																															     
		//Iterating New Opportunities  to update Fields on Campaign based on Opportunity.
		for(Id IdOppRecord :  mapIdOppNCamapaign.keySet()){
			if(mapCampaignRecords.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
				if(mapCampaignsToUpdate.containsKey(pMapOldOpp.get(IdOppRecord).CampaignId)){
					mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																	updateCampaignStagesCount(pMapOldOpp.get(IdOppRecord).StageName,
																													 mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																													 COUNT_DECREASE));
						
					mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																	updateCampaignOppType(pMapOldOpp.get(IdOppRecord).Type,
																											   mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																											   COUNT_DECREASE));
				}//End if.
				else{
					mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																	updateCampaignStagesCount(pMapOldOpp.get(IdOppRecord).StageName,
																													 mapCampaignRecords.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																													 COUNT_DECREASE));
																								  
					mapCampaignsToUpdate.put(pMapOldOpp.get(IdOppRecord).CampaignId ,
																	updateCampaignOppType(pMapOldOpp.get(IdOppRecord).Type,
																											   mapCampaignsToUpdate.get(pMapOldOpp.get(IdOppRecord).CampaignId),
																											   COUNT_DECREASE));
				}//End else.
			}//End if.
		}//End for. 									
		
		//Calling method to update Amount and Funding amount of Campaign related to a Opportunity.  
        this.updatedCampaignAmt_N_FundingAmt(mapCampaignRelatedAmount, mapCampaignRelatedFundAmt, pMapOldOpp.values());
											     
		//Iterating Campaigns that gets Updated to populate ROI % and # Funded fields.
		for(Campaign campRecord : mapCampaignsToUpdate.values()){
			if(mapCampaignRelatedFundAmt.get(campRecord.Id) <> null)
				campRecord.FundedAmount__c = mapCampaignRelatedFundAmt.get(campRecord.Id);
			
			campRecord.Funded__c = campRecord.Opportunities_Closed_Won__c;
		}//End for.
		if(mapCampaignsToUpdate.values().size() > 0)
			update(mapCampaignsToUpdate.values());
	
	}//End onDeleteOppUpdatecamapign method.
	
	
	
	/* The Method will return return the Updated amount and Funding amount related to a Campaign 
	 * based on the Amount in Opportunities which were present in the System.
	 */
	public void  updatedCampaignAmt_N_FundingAmt(Map<Id, Double> pMapCampaignRelatedAmount, 
																						Map<Id, Double> pMapCampaignRelatedFundAmt,
																						List<Opportunity> pLstOppRecords ){
		//Iterating already present opportunitues to get the sum of there amounts.
		for(Opportunity oppRecord : [Select Id, 
																	Amount,
																	Funding_Amt__c,
																	CampaignId,
																	Campaign.isActive 
														From Opportunity 
														Where (CampaignId IN : pMapCampaignRelatedAmount.keySet()
														OR CampaignId IN : pMapCampaignRelatedFundAmt.keySet())
														AND Campaign.isActive = true
														AND Id NOT IN : pLstOppRecords
														AND StageName = :  STAGE_CLOSED_WON]){
			if(mapCampaignRelatedAmount.containsKey(oppRecord.CampaignId)){										
				 amountOfOpp = mapCampaignRelatedAmount.get(oppRecord.CampaignId)  + ((oppRecord.Amount <> null ) ? oppRecord.Amount : 0);		
				 mapCampaignRelatedAmount.put(oppRecord.CampaignId, amountOfOpp);		
			}//End if.
				
			if(mapCampaignRelatedFundAmt.containsKey(oppRecord.CampaignId)){
				 fundingAmount  = mapCampaignRelatedFundAmt.get(oppRecord.CampaignId) + 
				 							   ((oppRecord.Funding_Amt__c <> null ) ? oppRecord.Funding_Amt__c : 0);
				mapCampaignRelatedFundAmt.put(oppRecord.CampaignId, fundingAmount);
			}//End if.
		}//End for.
	}//End updatedCampaignAmt_N_FundingAmt method.
	
	
	
	/* The Method will return return the Updated amount related to a Campaign based on the Amount in Opportunity.
	 */
	public void  updatedCampaignAmount(Map<Id, Double> pMapCampaignRelatedAmount, 
																				   Opportunity pOppRecord,
																				   String pOperation){
		//Checking if the Map already contains Campaign .  
		if(pMapCampaignRelatedAmount.containsKey(pOppRecord.CampaignId)){
			amountOfOpp = Double.valueOf(pMapCampaignRelatedAmount.get(pOppRecord.CampaignId)) + 
									   ((pOperation == COUNT_INCREASE ) ?  ((pOppRecord.Amount <> null) ? Double.valueOf(pOppRecord.Amount) : 0) : 
									   																	(Double.valueOf(pMapCampaignRelatedAmount.get(pOppRecord.CampaignId)) + 0));
			mapCampaignRelatedAmount.put(pOppRecord.CampaignId, amountOfOpp);
		}//End if.
		else
			mapCampaignRelatedAmount.put(pOppRecord.CampaignId, (pOperation == COUNT_INCREASE ) ?
																												((pOppRecord.Amount <> null) ? Double.valueOf(pOppRecord.Amount) : 0) : 0);
	}//End updatedCampaignAmount method.
	

	
	/* The method will update the Opportunity Type Count Fields on Campaign based on the Type of Opportunity and
	 *  will return updated campaign Record.  
	 */  
	public Campaign updateCampaignOppType(String pType, Campaign pCampaignRecord, String pOperation){
		if(!mapOppTypesWithCampaignField.isEmpty() && mapOppTypesWithCampaignField.containsKey(pType)){
			campaignfieldApiName = mapOppTypesWithCampaignField.get(pType);
			
			countOfTypes = Integer.valueOf(pCampaignRecord.get(campaignfieldApiName));
			
			countOfTypes =   (pOperation == COUNT_INCREASE) ? 
														   ( (countOfTypes == null) ? 
														   	  1 : Integer.valueOf(pCampaignRecord.get(campaignfieldApiName)) + 1) :
													       ((countOfTypes == null || countOfTypes == 0) ?
													       	  0 : Integer.valueOf(pCampaignRecord.get(campaignfieldApiName)) - 1);
			
			pCampaignRecord.put(campaignfieldApiName,  countOfTypes);
		}//End if 
		return pCampaignRecord;
	}//End updateCampaignOppType.
	
	
	
	/* The method will update the Opportunity Stages Count Fields on Campaign based on the Stages of Opportunity and
	 *  will return updated campaign Record.  
	 */  
	public Campaign updateCampaignStagesCount(String pStageName, Campaign pCampaignRecord, String pOperation){
		if(!mapOppStagesWithCampaignField.isEmpty() && mapOppStagesWithCampaignField.containsKey(pStageName.trim())){
			campaignfieldApiName = mapOppStagesWithCampaignField.get(pStageName);
			countOfStages = Integer.valueOf(pCampaignRecord.get(campaignfieldApiName));
			countOfStages =   (pOperation == COUNT_INCREASE) ? 
														   ((countOfStages == null) ? 
														   	  1 : countOfStages + 1) :
													       ((countOfStages == null || countOfStages == 0) ?
													       	  0 : Integer.valueOf(pCampaignRecord.get(campaignfieldApiName)) - 1);
			
			pCampaignRecord.put(campaignfieldApiName, countOfStages );
		}//End if 
		return pCampaignRecord;		
	}//End updateCampaignStagesCount method.
	
	
	
	/* The Method will return return the Updated Funding amount related to a Campaign based on the Amount in Opportunity.
	 */
	public void  updatedCampaignFundingAmount(Map<Id, Double> pMapCampaignRelatedFundAmt, 
																				 Opportunity pOppRecord,
																				 String pOperation){
		//Checking if the Map already contains Campaign .  
		if(pMapCampaignRelatedFundAmt.containsKey(pOppRecord.CampaignId)){
			fundingAmount = Double.valueOf(pMapCampaignRelatedFundAmt.get(pOppRecord.CampaignId)) + 
									     ((pOperation == COUNT_INCREASE ) ?  ((pOppRecord.Funding_Amt__c <> null) ? Double.valueOf(pOppRecord.Funding_Amt__c) : 0) : 
									   																	 (Double.valueOf(pMapCampaignRelatedFundAmt.get(pOppRecord.CampaignId)) + 0));
			mapCampaignRelatedFundAmt.put(pOppRecord.CampaignId, fundingAmount);
		}//End if.
		else
			mapCampaignRelatedFundAmt.put(pOppRecord.CampaignId, (pOperation == COUNT_INCREASE ) ?
																												((pOppRecord.Funding_Amt__c <> null) ? Double.valueOf(pOppRecord.Funding_Amt__c) : 0) : 0);
	}//End updatedCampaignAmount method.
}//End PopulateCampaignFIeldsForOppHandler class.