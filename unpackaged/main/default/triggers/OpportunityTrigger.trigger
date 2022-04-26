/* Trigger to update Fields on Campaign Object When a Opportunity is created or Updated or Deleted. 
*  Calculate # of Approved Opps per Partner on Update, Delete, Undelete.
*
* 
* Revision History:
*   
* Version         Author                                   Date                                    Description
* 1.0               Ajay Singh Solanki                 18/07/2013                         	Initial Draft
* 2.0               Matt Kowalsi                       29/3/2018                          	Calculate # of Approved Opps per Partner
* 3.0               Matt Kowalsi                       9/4/2018                           	Calculate # All KPIs per Partner and 
*																						  	share Opps with Partner Owner
*/ 


trigger OpportunityTrigger on Opportunity (after insert,  before update, after update, before delete, after delete, after undelete ) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler(Trigger.isExecuting, Trigger.size);
    
    if(Trigger.isInsert && Trigger.isAfter){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> partnerIdSet = new Set<Id>();
        for(Opportunity opp : Trigger.new){
            oppIdSet.add(opp.Id);
            if(opp.ISO__c != null){
                partnerIdSet.add(opp.ISO__c);
            }
        }
        handler.OnAfterInsert(Trigger.new, oppIdSet, partnerIdSet);
        //OpportunityTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());     
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> partnerIdSet = new Set<Id>();
        for(Opportunity opp : Trigger.new){
            oppIdSet.add(opp.Id);
            partnerIdSet.add(opp.ISO__c);
        }
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, oppIdSet);
        //OpportunityTriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
        //OpportunityTriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
    }
    
    else if(Trigger.isUnDelete){
        handler.OnUndelete(Trigger.new);
    }
    /*
if(Trigger.isInsert && Trigger.isBefore){
handler.OnBeforeInsert(Trigger.new);
}
else if(Trigger.isInsert && Trigger.isAfter){
handler.OnAfterInsert(Trigger.new);
OpportunityTriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
}

else if(Trigger.isUpdate && Trigger.isBefore){
handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
}


else if(Trigger.isDelete && Trigger.isBefore){
handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
}

*/
    
    PopulateCampaignFIeldsForOppHandler PopulateCampByOppHndlr = new PopulateCampaignFIeldsForOppHandler();
    OpportunityStageChangeTSManager opportunityStageChangeTSManager = new OpportunityStageChangeTSManager();
    if(trigger.isAfter && trigger.isInsert){
        PopulateCampByOppHndlr.onInsertOpportunityUpdateCampaign(trigger.newMap);
        opportunityStageChangeTSManager.onAfterInsert(trigger.newMap);
    }//End if Before Update.
    if(trigger.isBefore && trigger.isUpdate){
        PopulateCampByOppHndlr.onUpdateOppUpdatecamapign(trigger.oldMap, trigger.newMap);
        opportunityStageChangeTSManager.onBeforeUpdate(trigger.new, trigger.oldMap);
    }//End if Before Update.
    
    if(trigger.isBefore && trigger.isDelete){
        PopulateCampByOppHndlr.onDeleteOppUpdatecamapign(trigger.oldMap);
    }//End if Before Delete.
    
}//End OpportunityTrigger.