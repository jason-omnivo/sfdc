public class EntryPackage {
	
    public List<FolderItems.Entry> entries{get; set;}
    public Integer totalSize {get; set;}
    
    public EntryPackage() {
    	entries = new List<FolderItems.Entry>();
    	totalSize = 0;
    }
    
    public EntryPackage(FolderItems.Entry entry) {
    	this();
    	this.add(entry);
    }
    
    public void add(FolderItems.Entry entry) {
    	this.entries.add(entry);
    	this.totalSize += entry.size;	
    }
    
}