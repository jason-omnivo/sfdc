/* The Trigger to update 'Description' Field of Opportunity Object that gets created after Lead Conversion
 *  by the Description field of Lead.
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 19/06/2013                         Initial Draft
 */  



trigger LeadTrigger on Lead (before update, after update, before insert, after insert, before delete) {
    
    LeadConversionHandler conversionHandler = new LeadConversionHandler();
    PopulateCampaignFieldsHandler campaignHandler = new PopulateCampaignFieldsHandler();
    LeadStatusChangeTSManager leadStatusChangeTSManager = new LeadStatusChangeTSManager();
    
    if(trigger.isBefore && trigger.isUpdate) {
    	leadStatusChangeTSManager.onUpdateOrInsert(trigger.new, trigger.old);
    }
    
    if(trigger.isBefore && trigger.isInsert) {
    	leadStatusChangeTSManager.onUpdateOrInsert(trigger.new, null);
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        /* calling mapFieldsToOpportunity_N_Account method  of conversionHandler to update 'Description' 
         * Field of Opportunity Object.
         */
        conversionHandler.mapFieldsToOpportunity_Account_Contact(trigger.new, trigger.oldMap);
         
         if(PopulateCampaignFieldsHandler.isExecuted == false)
            campaignHandler.onUpdateLeadUpdateCountOnCampaign(trigger.oldMap, trigger.newMap);
         
    }//End if after Update.
    
    
    if(trigger.isBefore && trigger.isDelete){
            campaignHandler.onDeleteLeadUpdateCampaign(trigger.old);
    }//End if Before Delete.
    


    ////////////////////////////////////////////////////
    //Process for setting the opportunity contact role to primary upon conversion
    ////////////////////////////////////////////////////
    if(trigger.isAfter && trigger.isUpdate){
        List<Lead> convertedLeadsToProcess = new List<Lead>();

        for (Lead l : Trigger.new){
            if (((Lead)trigger.oldMap.get(l.Id)).isConverted == false && l.isConverted == true
                && l.ConvertedOpportunityId != null && l.ConvertedContactId != null)
                convertedLeadsToProcess.add(l);
        }
        if (convertedLeadsToProcess.size() > 0){
            Set<Id> OpptyIdSet = new Set<Id>();
            Set<Id> ContactIdSet = new Set<Id>();
            for(Lead l: convertedLeadsToProcess){
                OpptyIdSet.add(l.ConvertedOpportunityId);
                ContactIdSet.add(l.ConvertedContactId);
            }
            // Map<OpportunityId, Map<ContactId, OpportunityContactRole>>
            Map<Id, Map<Id, OpportunityContactRole>> oCRMap = new Map<Id, Map<Id, OpportunityContactRole>>();
            for(OpportunityContactRole oCR :[SELECT Id,IsPrimary,OpportunityId,ContactId FROM OpportunityContactRole WHERE OpportunityId IN :OpptyIdSet AND ContactId IN :ContactIdSet]){
                if (!oCRMap.containsKey(oCR.OpportunityId))
                    oCRMap.put(oCR.OpportunityId, new Map<Id, OpportunityContactRole>());
                
                oCRMap.get(oCR.OpportunityId).put(oCR.ContactId,oCR);

                //if (oCR.IsPrimary == false){
                //}
            }

            List<OpportunityContactRole> oCRToUpdate = new List<OpportunityContactRole>();
            for(Lead l: convertedLeadsToProcess){
                if (oCRMap.ContainsKey(l.ConvertedOpportunityId) && oCRMap.get(l.ConvertedOpportunityId).containsKey(l.ConvertedContactId)){
                    OpportunityContactRole oCR = oCRMap.get(l.ConvertedOpportunityId).get(l.ConvertedContactId);
                    oCR.Role = 'Business Owner';
                    oCR.IsPrimary = true;
                    oCRToUpdate.add(oCR);
                }
            }
            if (oCRToUpdate.size() > 0){
                update oCRToUpdate;
            }
        }
    }
}//End LeadTrigger.