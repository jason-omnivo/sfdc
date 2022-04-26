trigger BoxFolderCreationTrigger on Account (after insert) {
    
    public Set<ID> accids = new Set<ID>();
    
    for(Account acc : Trigger.New) {
        accIds.add(acc.Id);
    }
    
    if(accIds.size() > 0) {
        BoxFutureClass.createFolder(accIds);
    }
    
}