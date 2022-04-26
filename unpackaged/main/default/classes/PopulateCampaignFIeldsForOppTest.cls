/* Test Code coverage for PopulateCampaignFleldsForOppHandler
 *
 *
 *
 *
 */
@isTest
public class PopulateCampaignFIeldsForOppTest {
	
	//Constants
	private static final String  STAGE_CLOSED_WON  = 'Closed Won';               								//Opportunity Stage Name.
	private static final String  STAGE_CLOSED_UNDERWRITTING  = 'Underwriting';               			//Opportunity Stage Name.
	private static final String  STAGE_CLOSED_LOST  = 'Closed Lost';               								//Opportunity Stage Name.  
	private static final String  TYPE_NEW  = 'New Deal';  																	//Opportunity Type Name. 
	private static final String  TYPE_RENEWAL  = 'Renewal';  															//Opportunity Type Name. 
	
	
	/* The method will check  the code coverage of onInsertOpportunityUpdateCampaign method of 
	 * PopulateCampaignFIeldsForOppHandler  class.
	 */
    static testMethod void onInsertOpportunityTest(){
    	//Creating dummy record for Account.
    	Account accRecord = PopulateCampaignFIeldsForOppTest.returnAccount();
    	insert accRecord;
    	
    	//Creating dummy records for Campaign.
    	List<Campaign> lstCampaign = PopulateCampaignFIeldsForOppTest.returnCampaignList();
    	insert lstCampaign;
    	
    	//Creating dummy records for Opportunity.
    	List<Opportunity> lstOpportunities = PopulateCampaignFIeldsForOppTest.returnOpportunityList(accRecord.Id, lstCampaign);
    	
    	Database.SaveResult[] sr =  Database.insert(lstOpportunities);
    	system.assert(sr[0].isSuccess());
    }//End onInsertOpportunityTest method.
    
    
    
    
    /* The method will check  the code coverage of onUpdateOppUpdatecamapign method of 
	 * PopulateCampaignFIeldsForOppHandler  class.
	 */
    static testMethod void onUpdateOpportunityTest(){
    	//Creating dummy record for Account.
    	Account accRecord = PopulateCampaignFIeldsForOppTest.returnAccount();
    	insert accRecord;
    	
    	//Creating dummy records for Campaign.
    	List<Campaign> lstCampaign = PopulateCampaignFIeldsForOppTest.returnCampaignList();
    	insert lstCampaign;
    	
    	//Creating dummy records for Opportunity.
    	List<Opportunity> lstOpportunities = PopulateCampaignFIeldsForOppTest.returnOpportunityList(accRecord.Id, lstCampaign);
    	insert lstOpportunities;
    	
    	lstOpportunities[0].StageName = STAGE_CLOSED_LOST;
    	lstOpportunities[1].Type = TYPE_RENEWAL;
    	lstOpportunities[2].Amount = 44000;
    	lstOpportunities[3].Funding_Amt__c = 22400;
    	
    	//update lstOpportunities;
    	Database.SaveResult[] sr1 =  Database.update(lstOpportunities);
    	system.assert(sr1[0].isSuccess());
    	
    	lstOpportunities[0].StageName = STAGE_CLOSED_WON;
    	lstOpportunities[1].CampaignId = lstCampaign[1].Id;
    	lstOpportunities[2].StageName = STAGE_CLOSED_LOST;
    	//update lstOpportunities;
    	Database.SaveResult[] sr2 =  Database.update(lstOpportunities);
    	system.assert(sr2[0].isSuccess());
    	
    	lstOpportunities[2].StageName = STAGE_CLOSED_WON;
    	lstOpportunities[2].amount = 1000;
    	lstOpportunities[2].Funding_Amt__c = 3000;
    	//update lstOpportunities;
    	Database.SaveResult[] sr3 =  Database.update(lstOpportunities);
    	system.assert(sr3[0].isSuccess());
    	
    }//End onInsertOpportunityTest method.
    
    
    
    /* The method will check  the code coverage of onDeleteOppUpdatecamapign method of 
	 * PopulateCampaignFIeldsForOppHandler  class.
	 */
    static testMethod void onDeletOpportunityTest(){
    	//Creating dummy record for Account.
    	Account accRecord = PopulateCampaignFIeldsForOppTest.returnAccount();
    	insert accRecord;
    	
    	//Creating dummy records for Campaign.
    	List<Campaign> lstCampaign = PopulateCampaignFIeldsForOppTest.returnCampaignList();
    	insert lstCampaign;
    	
    	//Creating dummy records for Opportunity.
    	List<Opportunity> lstOpportunities = PopulateCampaignFIeldsForOppTest.returnOpportunityList(accRecord.Id, lstCampaign);
    	insert lstOpportunities;
    	
    	Database.DeleteResult[] sr =  Database.delete(lstOpportunities);
    	system.assert(sr[0].isSuccess());
    	
    }//End onDeletOpportunityTest method.
    
    
    
    /* Method will return List of Dummy Account record. 
     */
      public static Account returnAccount(){
      	return new Account(Name = 'Tem Account1',
      									  DBA_Name__c = 'DBA Test',
      									  Legal_Name__c = 'Legal Test',
                          Industry__c = 'Test Industry',
                          Date_Business_Established__c = Date.today(),
                          Percent_of_Ownership_1__c = 100,
                          Partner_1_Credit_Score__c = 500);
      }//End returnAccount method.
    
    
    
     /* Method will return List of Dummy Opportunity records. 
     */
      public static List<Opportunity> returnOpportunityList(Id pIdccount, List<Campaign> pLstCampaign){
      	List<Opportunity> lstOpportunities = new List<Opportunity>();
      	for(Integer index = 0; index < 4; index++){
      		lstOpportunities.add(new Opportunity(Name = 'Opp' + index,
      																	 	AccountId = pIdccount,
      																	 	CampaignId = pLstCampaign[0].Id,
      																	 	StageName = STAGE_CLOSED_WON,  
      																	 	Type = TYPE_NEW,
      																	 	Amount = 4000 + index,
      																	 	Funding_Amt__c = 8000 + index,
      																	 	CloseDate = system.today(),
      																	 	Client_Bank_Statements__c = 'Test Bank Statement' + index));
      	}//End for.
      	lstOpportunities[3].StageName = STAGE_CLOSED_UNDERWRITTING;
      	lstOpportunities[3].CampaignId = pLstCampaign[4].Id;
      	lstOpportunities.add(new Opportunity(Name = 'Opp',
      																	 	AccountId = pIdccount,
      																	 	CampaignId = pLstCampaign[0].Id,
      																	 	StageName = STAGE_CLOSED_LOST,  
      																	 	Type = TYPE_RENEWAL,
      																	 	Amount = 4000,
      																	 	Funding_Amt__c = 8000,
      																	 	CloseDate = system.today(),
      																	 	Client_Bank_Statements__c = 'Test Bank Statement5' ));
      	return lstOpportunities;
      }//End returnOpportunityList method.
    
    
    
    /* Method will return List of Dummy Campaign records. 
     */
    public static List<Campaign> returnCampaignList(){
    	List<Campaign> lstCampaigns = new List<Campaign>();
    	for(Integer index = 0; index < 4; index++){
    		lstCampaigns.add(new Campaign(Name = 'Test Camp' + index, 
    															  IsActive = true , 
    															  ActualCost = 2000+index, 
    															  Expected_Apps_Funded__c = 10 + index,
    															   Expected_Leads_Apps__c = 20 + index));
    	}//End for.
    	
    	lstCampaigns.add(new Campaign(Name = 'Test Campaign', 
															  IsActive = false , 
															  ActualCost = 2000, 
															  Expected_Apps_Funded__c = 10,
															  Expected_Leads_Apps__c = 20 ));
    	return lstCampaigns;
    }//End returnCampaignList method.
    
    
    
    /* The method will return the dummy records of OpportunityStages.
     */
     public static List<OpportunityStages__c> returnOpportunityStagesList(){
    	List<OpportunityStages__c> tempOpportunityStagesList = new List<OpportunityStages__c>();
    
    		tempOpportunityStagesList.add(new OpportunityStages__c(Name = STAGE_CLOSED_UNDERWRITTING, CampaignFieldApiName__c = 'Opportunities_Underwriting__c' ));
    		tempOpportunityStagesList.add(new OpportunityStages__c(Name = STAGE_CLOSED_WON, CampaignFieldApiName__c = 'Opportunities_Closed_Won__c' ));
    		tempOpportunityStagesList.add(new OpportunityStages__c(Name = STAGE_CLOSED_LOST, CampaignFieldApiName__c = 'Opportunities_Closed_Lost__c' ));
    	return tempOpportunityStagesList;
    }//End returnOpportunityStagesList Method.
    
    
    /* The method will return the dummy records of OpportunityTypes.
     */
    public static List<OpportunityTypes__c> returnOpportunityTypesList(){
    	List<OpportunityTypes__c> tempOpportunityTypesList = new List<OpportunityTypes__c>();
    
    		tempOpportunityTypesList.add(new OpportunityTypes__c(Name = TYPE_NEW, Campaign_Opp_Type_Api_Name__c = 'Opportunities_New_Deal__c' ));
    		tempOpportunityTypesList.add(new OpportunityTypes__c(Name = TYPE_RENEWAL, Campaign_Opp_Type_Api_Name__c = 'Opportunities_Renewal__c' ));
    	return tempOpportunityTypesList;
    }//End returnOpportunityTypesList Method.
    
}//End PopulateCampaignFIeldsForOppTest class.