@isTest
public class EntryPackageManagerTest {
    
    //////////////Test entriesToPackages////////////////
    static testMethod void testBigFile() {
   		
   		List<FolderItems.Entry> entryList = new List<FolderItems.Entry>();
   		entryList.add(new FolderItems.Entry('file', '1', '0', 'test file.pdf', 'a test file', 1000000)); 
   		entryList.add(new FolderItems.Entry('file', '2', '0', 'test file.pdf', 'a test file', 1000000));
   		entryList.add(new FolderItems.Entry('file', '3', '0', 'test file.pdf', 'a test file', 1000000));
   		entryList.add(new FolderItems.Entry('file', '4', '0', 'test file.pdf', 'a test file', 10500000)); // 10.5MB file which is above the max size per single email
   		entryList.add(new FolderItems.Entry('file', '5', '0', 'test file.pdf', 'a test file', 1000000));
   		entryList.add(new FolderItems.Entry('file', '6', '0', 'test file.pdf', 'a test file', 1000000));
		
		EntryPackageManager epm = new EntryPackageManager();
   		List<EntryPackage> packageList = epm.entriesToPackages(entryList);
   		System.assertEquals(NULL, packageList);
   		    
    }
    
    static testMethod void testFilesLessThan10MB() {
   		
   		List<FolderItems.Entry> entryList = new List<FolderItems.Entry>();
   		entryList.add(new FolderItems.Entry('file', '1', '0', 'test file.pdf', 'a test file', 1000000));
   		entryList.add(new FolderItems.Entry('file', '2', '0', 'test file.pdf', 'a test file', 2000000));
   		entryList.add(new FolderItems.Entry('file', '3', '0', 'test file.pdf', 'a test file', 3000000));
   		entryList.add(new FolderItems.Entry('file', '4', '0', 'test file.pdf', 'a test file', 500000));
   		entryList.add(new FolderItems.Entry('file', '5', '0', 'test file.pdf', 'a test file', 700000));
   		entryList.add(new FolderItems.Entry('file', '6', '0', 'test file.pdf', 'a test file', 800000));
   		
   		EntryPackageManager epm = new EntryPackageManager();
   		List<EntryPackage> packageList = epm.entriesToPackages(entryList);
   		System.assert(packageList.size() == 1);
   		System.assertEquals(8000000, packageList[0].totalSize);
   		System.assertEquals(6, packageList[0].entries.size());
   		 
    }
    
    static testMethod void testFilesMoreThan10MB() {
    	
   		List<FolderItems.Entry> entryList = new List<FolderItems.Entry>();
   		entryList.add(new FolderItems.Entry('file', '1', '0', 'test file.pdf', 'a test file', 3000000));
   		entryList.add(new FolderItems.Entry('file', '2', '0', 'test file.pdf', 'a test file', 4000000));
   		entryList.add(new FolderItems.Entry('file', '3', '0', 'test file.pdf', 'a test file', 3000000));
   		entryList.add(new FolderItems.Entry('file', '4', '0', 'test file.pdf', 'a test file', 2500000));
   		entryList.add(new FolderItems.Entry('file', '5', '0', 'test file.pdf', 'a test file', 6500000));
   		entryList.add(new FolderItems.Entry('file', '6', '0', 'test file.pdf', 'a test file', 2000000));
   		
   		EntryPackageManager epm = new EntryPackageManager();
   		List<EntryPackage> packageList = epm.entriesToPackages(entryList);
   		System.assertEquals(3, packageList.size());
   		System.assertEquals(9500000, packageList[0].totalSize);
   		System.assertEquals(2, packageList[0].entries.size());
   		System.assertEquals(9500000, packageList[1].totalSize);
   		System.assertEquals(3, packageList[1].entries.size());
   		System.assertEquals(2000000, packageList[2].totalSize);
   		System.assertEquals(1, packageList[2].entries.size());
   		
    }
    
}