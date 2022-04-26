trigger BoxFolderCreationTriggerOpp on Opportunity (after insert) {
    public Set<ID> oppids = new Set<ID>();
    
    for(Opportunity opp : Trigger.New) {
        oppIds.add(opp.Id);
    }
    
    if(oppIds.size() > 0) {
        BoxFutureClass.createFolderForOpp(oppIds);
    }
    
}