public class EntryPackageManager {
	
    Integer maxSizePerPackage = 10000000;
    List<EntryPackage> packages;
    
    public List<EntryPackage> entriesToPackages(List<FolderItems.Entry> entries) {
    	
    	packages = new List<EntryPackage>();
    	packages.add(new EntryPackage());
    	boolean SpaceFound;
    	
    	entries.sort();
    	
    	for(FolderItems.Entry entry : entries) {

    		if(entry.size > maxSizePerPackage) {
    			return null;
    		}

    		/*
    		for(EntryPackage packageObj : packages) {

    			if(!SpaceFound && hasEnoughSpace(packageObj, entry)) {
    				packageObj.add(entry);
    				SpaceFound = true;
    			}

    		}
    		*/
    		Integer indexOfBestMatch = bestMatch(entry);
    		if(indexOfBestMatch > -1) {
    			packages[indexOfBestMatch].add(entry);
    		} else {
    			packages.add(new EntryPackage(entry));
    		}
    		
    	}
    	
    	return packages;
    }
    
    private Integer bestMatch(FolderItems.Entry entry) {
    	
    	Integer indexOfBestMatch = -1;
    	Integer bestMatchSize = 0;
    	
    	for(Integer i = 0; i < packages.size(); i++) {
    		if(hasEnoughSpace(packages[i], entry) && entry.size > bestMatchSize) {
    			indexOfBestMatch = i;
    			bestMatchSize = entry.size;
    		}	
    	}
    	
    	return indexOfBestMatch;
    }
    
    private boolean hasEnoughSpace(EntryPackage packageObj, FolderItems.Entry entry) {
    	return packageObj.totalSize + entry.size <= maxSizePerPackage;
    }
    
    
}