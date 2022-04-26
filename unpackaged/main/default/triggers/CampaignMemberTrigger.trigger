/* The Trigger to update Status Count fields on Campaign and Custom Campaign field on Lead associated
 *  to CampaignMember Whenever is created and updated the Status Count Fields on Campaign when a 
 *  CampaignMember is Deleted.
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 16/07/2013                         Initial Draft
 */ 


trigger CampaignMemberTrigger on CampaignMember (before delete, before insert) {
	PopulateCampaignFieldsHandler campaignHandler = new PopulateCampaignFieldsHandler();
	if(trigger.isBefore && trigger.isInsert){
		campaignHandler.onInsertCampaignMemberIncreaseStatusCounts(trigger.new);
	}
	
	if(trigger.isBefore && trigger.isDelete){
		campaignHandler.onDeleteCampaignMemberDecreaseStatusCounts(trigger.old);
	}
	
	
	
}//End CampaignMemberTrigger Trigger.