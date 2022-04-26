public without sharing class OpportunityTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private PartnerRollups pr;

    public OpportunityTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
        pr = new PartnerRollups();
    }
    
    public void OnAfterInsert(Opportunity[] newOpportunities, Set<Id> oppIdSet, Set<Id> partnerIdSet){
        processOpportunityContactRole(newOpportunities, oppIdSet);
        //Opportunity cannot be inserted in Approved Stage as of 3/29/18 becuase of Validation Rule
        pr.calculatePartnerRollups(newOpportunities, oppIdSet, partnerIdSet, NULL);

        if(!Test.isRunningTest()) {
            System.enqueueJob(new OcrolusNewBookQueueable(trigger.new));
        }
    }
    
    public void OnAfterUpdate(Opportunity[] oldOpportunities, Opportunity[] updatedOpportunities, Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOpportunityMap, Set<Id> oppIdSet){
        CreditDataPullManager creditDataUploader = new CreditDataPullManager(oldOpportunities, newOpportunityMap);
        creditDataUploader.uploadCreditData();

        List<Opportunity> liOppsToUpdate = new List<Opportunity>();
        Set<Id> partnerIdSet = new Set<Id>();
        Map<Id,Id> oppSharesToDeleteMap = New Map<Id,Id>(); // <opp.id, iso>
        for(Opportunity opp : updatedOpportunities){
            if((opp.StageName != oldOpportunityMap.get(opp.Id).StageName) ||
               (opp.ISO__c != oldOpportunityMap.get(opp.Id).ISO__c)){
                   if(opp.ISO__c != oldOpportunityMap.get(opp.Id).ISO__c &&  oldOpportunityMap.get(opp.Id).ISO__c != NULL){
                       partnerIdSet.add(oldOpportunityMap.get(opp.Id).ISO__c);
                       oppSharesToDeleteMap.put(opp.Id, oldOpportunityMap.get(opp.Id).ISO__c);
                   }
                   if(opp.ISO__c != NULL){
                       partnerIdSet.add(opp.ISO__c);
                   } 
               }  
        }
        pr.calculatePartnerRollups(updatedOpportunities, oppIdSet, partnerIdSet, oppSharesToDeleteMap);
    }
    
    public void OnAfterDelete(Opportunity[] deletedOpportunities, Map<ID, Opportunity> OpportunityMap){
        Set<Id> partnerIdSet = new Set<Id>();
        for(Opportunity op : deletedOpportunities){
            if(OpportunityMap.get(op.Id).ISO__c != NULL){
                partnerIdSet.add(op.ISO__c);
            }
        }
        pr.calculatePartnerRollups(deletedOpportunities, NULL, partnerIdSet, NULL);
    }
    
    public void OnUndelete(List<Opportunity> restoredOpportunities){
        Set<Id> partnerIdSet = new Set<Id>();
        for(Opportunity o : restoredOpportunities){
            if(o.ISO__c != NULL){
                partnerIdSet.add(o.ISO__c);
            }
        }
        pr.calculatePartnerRollups(restoredOpportunities, NULL, partnerIdSet, NULL);
    }
    
    
    
    private void processOpportunityContactRole(List<Opportunity> oppList, Set<Id> oppIdSet){
        
        List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
        
        List<Opportunity> oppToProcess = new List<Opportunity>();
        Set<Id> accountIdSet = new Set<Id>();
        //Get the list of opportunities to process if it doesn't have 
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accountIdSet.add(opp.AccountId);
                oppToProcess.add(opp);
            }
        }
        Map<Id, Id> accToContactMap = new Map<Id, Id>();
        for(Contact c : [Select Id, AccountId From Contact Where AccountId IN : accountIdSet Order By CreatedDate DESC]){
            accToContactMap.put(c.AccountId, c.Id);
        }
        
        for(Opportunity opp : oppToProcess){
            if(accToContactMap.containsKey(opp.AccountId) && !URL.getCurrentRequestUrl().toExternalForm().contains('leadconvert')){
                OpportunityContactRole oCR = new OpportunityContactRole(OpportunityId = opp.Id,
                                                                        ContactId = accToContactMap.get(opp.AccountId),
                                                                        Role = 'Business Owner',
                                                                        IsPrimary = true);
                oppContactRoleList.add(oCR);
            }
        }
        if(Schema.sObjectType.OpportunityContactRole.isAccessible()){
            if(oppContactRoleList.size() > 0) upsert oppContactRoleList;
        }
    }
    
    public without sharing class PartnerRollups{
        public void calculatePartnerRollups(List<Opportunity> triggerOpps, Set<Id> oppIdSet, Set<Id> partnerIdSet, Map<Id,Id> oppSharesToDeleteMap){
            List<ISO__c> liPartnersToUpdate = new List<ISO__c>();
            Map<Id, Id> oppsToShareIdMap = new Map<Id, Id>(); //<opp.Id, iso.OwnerId>
            for(ISO__c iso : [SELECT Id, OwnerId, Owner.isActive, (SELECT Id, StageName, OwnerId, CreatedDate FROM Opportunities__r) FROM ISO__c WHERE Id IN: partnerIdSet]){
                integer approvedOpps = 0;
                integer submittedOpps = 0;
                integer submitted30DaysOpps = 0;
                integer declinedOpps = 0;
                integer fundedOpps = 0;
                integer revivedOpps = 0;
                for(Opportunity opp : iso.Opportunities__r){
                    submittedOpps += 1;
                    if(opp.StageName == 'Approved'){
                        approvedOpps += 1;
                    }
                    else if(opp.StageName == 'Declined'){
                        declinedOpps += 1;
                    }
                    else if(opp.StageName == 'Funded'){
                        fundedOpps += 1;
                    }
                    else if(opp.StageName == 'Closed Lost'){
                        revivedOpps += 1;
                    }
                    if(opp.CreatedDate >= Date.today().AddDays(-30)){
                        submitted30DaysOpps += 1;
                    }
                    if(opp.OwnerId != iso.OwnerId && iso.Owner.isActive == true){
                        oppsToShareIdMap.put(opp.Id, iso.OwnerId);
                    }
                }
                ISO__c partner = New ISO__c(Id=iso.Id, 
                                            Submitted__c = submittedOpps,
                                            Submitted_30_Days__c = submitted30DaysOpps,
                                            Declined__c = declinedOpps,
                                            Funded__c = fundedOpps,
                                            Revive__c = revivedOpps,
                                            Approvals__c=approvedOpps);
                liPartnersToUpdate.add(partner);
                system.debug(partner);
            }
            update liPartnersToUpdate;
            if(oppSharesToDeleteMap != NULL && oppSharesToDeleteMap.size() > 0){
                unshareOpps(oppSharesToDeleteMap);
            }
            if(oppsToShareIdMap != NULL && oppsToShareIdMap.size() > 0){
                shareOpps(oppsToShareIdMap);
            }
        }
        
        private void shareOpps(Map<Id,Id> oppsToShareIdMap){
            List<OpportunityShare> oppShareToInsert = new List<OpportunityShare>();
            for(Id oppId : oppsToShareIdMap.keyset()){
                OpportunityShare os = new OpportunityShare(
                    OpportunityAccessLevel = 'Edit',
                    OpportunityID = oppId,
                    UserOrGroupId = oppsToShareIdMap.get(oppId)
                );
                oppShareToInsert.add(os);
            }
            try{
                List<Database.SaveResult> srList = Database.Insert(oppShareToInsert);
                for(Database.SaveResult sr : srList){
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully shared Opp. OpportuntityShare ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('OpportuntityShare fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        
        private void unshareOpps(Map<Id,Id> oppSharesToDeleteMap){
            List<OpportunityShare> oppSharesToDelete = New List<OpportunityShare>();
            Set<Id> isoOwnerIdSet = New Set<Id>();    
            Map<Id, ISO__c> partners = New Map<Id, ISO__c>([SELECT Id, OwnerId FROM ISO__c WHERE Id IN: oppSharesToDeleteMap.values()]);
            for(ISO__c iso : partners.values()){
                System.debug(iso);
                isoOwnerIdSet.add(iso.ownerId);
            }
            for(OpportunityShare os : [SELECT Id, OpportunityId, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN :oppSharesToDeleteMap.keyset() AND UserOrGroupId IN :isoOwnerIdSet AND RowCause = 'Manual']){
                if(os.UserOrGroupId == partners.get(oppSharesToDeleteMap.get(os.OpportunityId)).OwnerId){

                    oppSharesToDelete.add(os);
                }
            }
            delete oppSharesToDelete;
        }
    }
    
    /*
public void OnBeforeInsert(Opportunity[] newOpportunities){
}


@future public static void OnAfterInsertAsync(Set<ID> newOpportunityIDs){
}

public void OnBeforeUpdate(Opportunity[] oldOpportunities, Opportunity[] updatedOpportunities, Map<ID, Opportunity> oldOpportunityMap, Map<ID, Opportunity> newOpportunityMap){
}



@future public static void OnAfterUpdateAsync(Set<ID> updatedOpportunityIDs){
}

public void OnBeforeDelete(Opportunity[] OpportunitiesToDelete, Map<ID, Opportunity> OpportunityMap){

}



@future public static void OnAfterDeleteAsync(Set<ID> deletedOpportunityIDs){

}


*/
}