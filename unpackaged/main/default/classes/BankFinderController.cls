public with sharing class BankFinderController {
    public Opportunity opp{get; set;}
    public List<MatchBank> matchBankList{get; set;}
    public String note {get; set;}

    private List<Submissions__c> submittedList{get; set;}
    private String statementsFolderId;
    private Integer lastMonthNegDays;
    Set<Id> funderSubmittedSet;
    Set<Id> fundedFunderSet;
    Set<String> fundedFunderLabelSet;
    public List<Submissions__c> submissionList;
    
    string matchBankLastSort;
    static string FUNDER_NAME = 'Name';
    static string COMMISION = 'Commision__c';
    static string TIER = 'Tier__c';
    static string MAX_AMOUNT = 'Max_Amount__c';
    static string LONGEST_TERM = 'Longest_Term__c';
    static string PAYMENT_OPTIONS = 'Payment_Options__c';
    static string LOWEST_BUY_RATE = 'Lowest_Buy_Rate__c';
    static string APPROVAL_TIME_IN_HOURS = 'Approval_Time_In_Hours__c';
    static string PCT_FROM_APPROVED_TO_FUNDED = 'PCT_From_Approved_To_Funded__c';
    
    
    public BankFinderController(String oppId){
    	
    	note = '';
        for(Opportunity o : [Select Id, Name, Owner.Email, Owner.UserRole.DeveloperName ,Account.Name, Account.Total_Percent_of_Ownership__c,
							Account.Percent_of_Ownership_1__c, Account.Industry__c, Account.Legal_State__c, Owner.Admin_Email__c,
							Account.Years_in_Business_2__c, Account.Partner_1_Credit_Score__c, Act_1_Avg_Daily_Balance__c,
							Number_Of_Positions_Account_1__c, Act_1_Annual_Revenue_Trend__c,
                             Annual_Revenue_Trend__c,
							(SELECT Number_of_Days_Negative__c FROM Bank_Statements__r
							WHERE Account__c = 'Account 1' ORDER BY Date__c DESC LIMIT 1),
							(SELECT Id, Funder__c, Funder__r.Funder_Label__c FROM Funding_Payments__r)
							From Opportunity Where Id =:oppId Limit 1]){            
            opp = o;
            
            funderSubmittedSet = new Set<Id>();
            for(Submissions__c submission : getAlreadySubmitted()){
                funderSubmittedSet.add(submission.Funder__c);
            }
            
            fundedFunderSet = new Set<Id>();
            fundedFunderLabelSet = new Set<String>(); // labels of funders which already exist in the funding payment list for this opportunity
            for(Funding_Payment__c fundingPayment : opp.Funding_Payments__r) {
        		fundedFunderSet.add(fundingPayment.Funder__r.Id);
            	if(fundingPayment.Funder__r.Funder_Label__c != null && fundingPayment.Funder__r.Funder_Label__c != '') {
            		fundedFunderLabelSet.add(fundingPayment.Funder__r.Funder_Label__c);	
            	}
            }
            lastMonthNegDays = opp.Bank_Statements__r.size() > 0 && opp.Bank_Statements__r[0].Number_of_Days_Negative__c != null ? Integer.valueOf(opp.Bank_Statements__r[0].Number_of_Days_Negative__c) : 0;
            
        }
        
	 }
    
    public BankFinderController(){
    	this(apexpages.currentpage().getparameters().get('oppId'));
    }
    
    public List<Submissions__c> getAlreadySubmitted(){
        if(submittedList == null){
            submittedList = new List<Submissions__c>();
            submittedList = [Select Id, Name, Approval_Numbers__c, Notes_M__c, Bank_Status__c,
							Funder__c, Internal_Status__c, Opportunity__c, Type_of_Deal__c, CreatedDate,
							CreatedById, CreatedBy.Name
							From Submissions__c Where Opportunity__c = :opp.Id];
        }
        return submittedList;
    }
	
	public Integer getLastMonthNegDays() {
		return lastMonthNegDays;
	}
	
	private SortRule.SORT_ORDER getMatchBanksSortOrder(string field) {
		if(matchBankLastSort == field) {
			matchBankLastSort = '';
			return SortRule.SORT_ORDER.Descending;
		} else {
			matchBankLastSort = field;
			return SortRule.SORT_ORDER.Acsending;
		}
	}
	
	public void sortByFunderName() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(FUNDER_NAME, getMatchBanksSortOrder(FUNDER_NAME), SortRule.SORT_FUNCTION.Alphabetical));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
    }
    
	public void sortByCommision() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(COMMISION, getMatchBanksSortOrder(COMMISION), SortRule.SORT_FUNCTION.Numeric));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
    }
    
    public void sortByTier() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(TIER, getMatchBanksSortOrder(TIER), SortRule.SORT_FUNCTION.Alphabetical));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
    }
	
	public void sortByMaxAmount() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(MAX_AMOUNT, getMatchBanksSortOrder(MAX_AMOUNT), SortRule.SORT_FUNCTION.Numeric));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
	}
	
	public void sortByLongestTerm() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(LONGEST_TERM, getMatchBanksSortOrder(LONGEST_TERM), SortRule.SORT_FUNCTION.Numeric));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
	}
	
	public void sortByPaymentOptions() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(PAYMENT_OPTIONS, getMatchBanksSortOrder(PAYMENT_OPTIONS), SortRule.SORT_FUNCTION.Alphabetical));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
    }
    
	public void sortByLowestBuyRate() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(LOWEST_BUY_RATE, getMatchBanksSortOrder(LOWEST_BUY_RATE), SortRule.SORT_FUNCTION.Numeric));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
	}
	
	public void sortByApprovalTimeIn_Hours() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(APPROVAL_TIME_IN_HOURS, getMatchBanksSortOrder(APPROVAL_TIME_IN_HOURS), SortRule.SORT_FUNCTION.Numeric));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
	}
	
	public void sortByPCTFromApprovedToFunded() {
		List<SortRule> sortRuleList = new List<SortRule>();
		sortRuleList.add(new SortRule(PCT_FROM_APPROVED_TO_FUNDED, getMatchBanksSortOrder(PCT_FROM_APPROVED_TO_FUNDED), SortRule.SORT_FUNCTION.Numeric));
		MatchBank.sortRuleList = sortRuleList;
		matchBankList.sort();
	}
	
    public List<MatchBank> getMatchedBanks(){
    
        if(matchBankList == null){
            matchBankList = new List<MatchBank>();
			
			Decimal act1AvgDailyBalance = opp.Act_1_Avg_Daily_Balance__c;
			Decimal numberOfPositionsAccount1 = opp.Number_Of_Positions_Account_1__c;
			Decimal act1AnnualRevenueTrend = opp.Act_1_Annual_Revenue_Trend__c;
			List<Funder__c> funderList = Database.query(
		        'Select Id, Name, Contact_Name__c, Contact_Email__c, Commision__c, Tier__c, Commission_Type__c, ' +
		        'Approval_Speed__c, Paperwork_Requirement__c, Max_Amount__c, Factor__c, ' +
		        'Additional_Email_1__c, Additional_Email_2__c, Positions__c, Funder_Label__c, ' +
		        'Minimum_Annual_Revenue__c, Approval_Time_In_Hours__c, Longest_Term__c, ' +
		        'Payment_Options__c, Lowest_Buy_Rate__c, PCT_From_Approved_To_Funded__c, Submit_Using_API__c, Portal_Lender_None_API__c ' +
		        'From Funder__c ' +
    			'Where Ownership_Percentage_Requirment__c <= ' +  opp.Account.Total_Percent_of_Ownership__c + ' ' +
    			'AND Restricted_Industries__c EXCLUDES (\'' + opp.Account.Industry__c + '\') ' +
    			'AND (Restricted_States__c = NULL OR Restricted_States__c EXCLUDES (\'' + opp.Account.Legal_State__c + '\')) ' +
    		    'AND Time_in_business__c <= ' + opp.Account.Years_in_Business_2__c + ' ' +
		        'AND Credit_Score__c <= ' + opp.Account.Partner_1_Credit_Score__c + ' ' +
    		    'AND (Max_Neg_Days_Last_Month__c <> NULL) AND (Max_Neg_Days_Last_Month__c >= ' + lastMonthNegDays + ') ' +
		        'AND (Minimum_Avg_Daily_Balance__c <> NULL) AND (Minimum_Avg_Daily_Balance__c <= :act1AvgDailyBalance) ' +
		        'AND ((Number_Of_Max_Positions__c < 1) OR (Number_Of_Max_Positions__c >= :numberOfPositionsAccount1)) ' +
    			'AND (Minimum_Annual_Revenue__c <> NULL) AND (Minimum_Annual_Revenue__c <= :act1AnnualRevenueTrend) ' +
    			'AND Id NOT IN :funderSubmittedSet ' +
		        'AND Id NOT IN :fundedFunderSet ' +
		        'AND Funder_Label__c NOT IN :fundedFunderLabelSet ' +
    			'AND Active__c = true ' +
		        'AND (NOT Name LIKE \'%(cashio)%\') ' +
		        'Order By Commision__c DESC, Max_Amount__c ASC, Longest_Term__c ASC, Lowest_Buy_Rate__c ASC, Approval_Time_In_Hours__c ASC, PCT_From_Approved_To_Funded__c ASC'
		    );

/*
				'

*/
/*	
			 List<Funder__c> tfList = Database.query(
		        'Select Id, Name, Contact_Name__c, Contact_Email__c, Commision__c, Commission_Type__c, ' +
		        'Approval_Speed__c, Paperwork_Requirement__c, Max_Amount__c, Factor__c, ' +
		        'Additional_Email_1__c, Additional_Email_2__c, Positions__c, Funder_Label__c, ' +
		        'Minimum_Annual_Revenue__c, Approval_Time_In_Hours__c, Longest_Term__c, ' +
		        'Payment_Options__c, Lowest_Buy_Rate__c, PCT_From_Approved_To_Funded__c ' +
		        'From Funder__c ' +
		        'Where Ownership_Percentage_Requirment__c <= ' +  opp.Account.Total_Percent_of_Ownership__c + ' ' +
		        'AND Restricted_Industries__c EXCLUDES (' + opp.Account.Industry__c + ') ' +
		        'AND Restricted_States__c EXCLUDES (' + opp.Account.Legal_State__c + ') ' +
		        'AND Time_in_business__c <= ' + opp.Account.Years_in_Business_2__c + ' ' +
		        'AND Credit_Score__c <= ' + opp.Account.Partner_1_Credit_Score__c + ' ' +
		        'AND (Max_Neg_Days_Last_Month__c <> NULL) AND (Max_Neg_Days_Last_Month__c >= ' + lastMonthNegDays + ') ' +
		        'AND (Minimum_Avg_Daily_Balance__c <> NULL) AND (Minimum_Avg_Daily_Balance__c <= ' + opp.Act_1_Avg_Daily_Balance__c + ') ' +
		        'AND ((Number_Of_Max_Positions__c = -1) OR (Number_Of_Max_Positions__c >= ' + opp.Number_Of_Positions_Account_1__c + ')) ' +
		        'AND (Minimum_Annual_Revenue__c <> NULL) AND (Minimum_Annual_Revenue__c <= ' + opp.Act_1_Annual_Revenue_Trend__c + ') ' +
		        'AND Id NOT IN :funderSubmittedSet ' +
		        'AND Id NOT IN :fundedFunderSet ' +
		        'AND Funder_Label__c NOT IN :fundedFunderLabelSet ' +
		        'AND Active__c = true ' +
		        'AND (NOT Name LIKE \'%(cashio)%\') ' +
		        'Order By Commision__c DESC, ' +
		        'Max_Amount__c ASC, ' +
		        'Factor__c ASC, ' +
		        'Approval_Time_In_Hours__c ASC'
		    );
		
		        'ORDER BY ' + sortOrder + ' ASC ' +
		        'LIMIT 10'
	*/		
	/*
			List<Funder__c> tfList = [Select Id, Name, Contact_Name__c, Contact_Email__c, Commision__c, Commission_Type__c,
									Approval_Speed__c, Paperwork_Requirement__c, Max_Amount__c, Factor__c,
									Additional_Email_1__c, Additional_Email_2__c, Positions__c, Funder_Label__c,
									Minimum_Annual_Revenue__c, Approval_Time_In_Hours__c, Longest_Term__c,
									Payment_Options__c, Lowest_Buy_Rate__c, PCT_From_Approved_To_Funded__c
                                	From Funder__c 
                                
                                Where Ownership_Percentage_Requirment__c <= :opp.Account.Total_Percent_of_Ownership__c
                                AND Restricted_Industries__c EXCLUDES (:opp.Account.Industry__c)
                                AND Restricted_States__c EXCLUDES (:opp.Account.Legal_State__c)
                                AND Time_in_business__c <= :opp.Account.Years_in_Business_2__c
                                AND Credit_Score__c <= :opp.Account.Partner_1_Credit_Score__c
                                AND (Max_Neg_Days_Last_Month__c <> NULL) AND (Max_Neg_Days_Last_Month__c >=: lastMonthNegDays)
                                AND (Minimum_Avg_Daily_Balance__c <> NULL) AND (Minimum_Avg_Daily_Balance__c <=: opp.Act_1_Avg_Daily_Balance__c)
                                AND ((Number_Of_Max_Positions__c = -1) OR (Number_Of_Max_Positions__c >=: opp.Number_Of_Positions_Account_1__c))
                                AND (Minimum_Annual_Revenue__c <> NULL) AND (Minimum_Annual_Revenue__c <=: opp.Act_1_Annual_Revenue_Trend__c)
                                AND Id NOT IN :funderSubmittedSet
                                AND Id NOT IN :fundedFunderSet
                                AND Funder_Label__c NOT IN :fundedFunderLabelSet
                                AND Active__c = true
                                AND (NOT Name LIKE '%(cashio)%')
                                Order By Commision__c DESC,
                                        Max_Amount__c ASC,
                                        Factor__c ASC,
                                        Approval_Time_In_Hours__c ASC
                                ]; 
			*/
            for(Funder__c f : funderList){
                MatchBank obj = new MatchBank(f);
                obj.isSelected = false;
                matchBankList.add(obj);
            }
        }
        return matchBankList;
    }
    
    public List<NonMatchFunder> getNonMatchedBanks() {
    	
    	List<NonMatchFunder> NonMatchFunderList = new List<NonMatchFunder>();
    	Map<Id, Funder__c> funderMap = new Map<Id, Funder__c>([Select Id, Name, Contact_Name__c, Contact_Email__c, Commision__c, Commission_Type__c,
									Approval_Speed__c, Paperwork_Requirement__c, Max_Amount__c, Factor__c,
									Additional_Email_1__c, Additional_Email_2__c, Positions__c, Funder_Label__c,
									Minimum_Annual_Revenue__c, Number_Of_Max_Positions__c
                                	From Funder__c
                                	WHERE Active__c = true
                                	AND Id NOT IN :funderSubmittedSet
                               		AND (NOT Name LIKE '%(cashio)%')]);
    	

    	List<Id> fundeIdList = new List<Id>();
    	Map<Id, List<String>> reasonMap = new Map<Id, List<String>>(); // reason funder is non match
    	for(Id funderId : funderMap.keySet()) {
    		reasonMap.put(funderId, new List<String>());
    		fundeIdList.add(funderId);
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE Id IN :fundeIdList
    							AND (Ownership_Percentage_Requirment__c = NULL
    							OR Ownership_Percentage_Requirment__c = 0
    							OR Ownership_Percentage_Requirment__c >
								:opp.Account.Total_Percent_of_Ownership__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderOwnershipPercentage);
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Restricted_Industries__c = NULL
    							OR Restricted_Industries__c = ''
    							OR Restricted_Industries__c
								INCLUDES (:opp.Account.Industry__c))]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderRestrictedIndustry);
    	}
    
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND Restricted_States__c <> NULL
    							AND Restricted_States__c <> ''
    							AND Restricted_States__c
								INCLUDES (:opp.Account.Legal_State__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderRestrictedState);
    	}	
    
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Time_in_business__c = NULL
    							OR Time_in_business__c = 0
    							OR Time_in_business__c >
								:opp.Account.Years_in_Business_2__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderTimeInBusiness);
    	}	
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Credit_Score__c = NULL
    							OR Credit_Score__c = 0
    							OR Credit_Score__c >
								:opp.Account.Partner_1_Credit_Score__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderCreditScore);
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Max_Neg_Days_Last_Month__c = NULL
								OR Max_Neg_Days_Last_Month__c <
    							:lastMonthNegDays)]) {
    		reasonMap.get(funder.Id).add(label.UnqualifiedFunderNegativeDays);
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Minimum_Avg_Daily_Balance__c = NULL
								OR Minimum_Avg_Daily_Balance__c >
    							:opp.Act_1_Avg_Daily_Balance__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderAvgDailyBalance);
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Number_Of_Max_Positions__c > 0
								AND Number_Of_Max_Positions__c <
    							: opp.Number_Of_Positions_Account_1__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderNumberOfPositions);
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c
    							WHERE  Id IN :fundeIdList
    							AND (Minimum_Annual_Revenue__c = NULL
								OR Minimum_Annual_Revenue__c >
    							: opp.Act_1_Annual_Revenue_Trend__c)]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderMinimumAnnualRevenue);
    	}
    	
    	/*
    	for(Id funderId : funderSubmittedSet) {
    		if(reasonMap.containsKey(funderId))
    			reasonMap.get(funderId).add(REASON_ALREADY_SUBMITTED);
    	}*/
    	
    	for(Id funderId : fundedFunderSet) {
    		if(reasonMap.containsKey(funderId)) {
    			reasonMap.get(funderId).add(Label.UnqualifiedFunderAlreadyFunded);    			
    		}
    	}
    	
    	for(Funder__c funder : [SELECT Id FROM Funder__c WHERE Id IN :fundeIdList
    													AND Funder_Label__c IN :fundedFunderLabelSet
														AND Id NOT IN : fundedFunderSet]) {
    		reasonMap.get(funder.Id).add(Label.UnqualifiedFunderFundedFunderLabel);
    	}
    	
    	for(Id funderId : reasonMap.keySet()) {
    		if(reasonMap.get(funderId).size() > 0) {
    			NonMatchFunderList.add(new NonMatchFunder(funderMap.get(funderId), reasonMap.get(funderId)));
    		}
    	}
    	
    	NonMatchFunderList.sort();
    	return NonMatchFunderList;
    	
    }

    public PageReference submitToBanks(){
	
        submissionList = new List<Submissions__c>();
        Integer selectedItems = 0;
        
        Set<Id> selectedFunderIdSet = new Set<Id>();
        List<EntryPackage> packageList;
        List<FolderItems.entry> entryList;

        try {
            
	        if(BoxAuth.authInfo == null){
	            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please login via Box Auth page first before using the Bank Finder Application. Please click /apex/boxauth to authenticate'));
	            return null;
	        }
	        /*
        	System.debug('1');
            //Generate the Box link
            System.debug('Main - 1');
            BoxObject2.SearchResult searchResult = BoxAPIv2.search(opp.Name, 'folder');
			System.debug('Main - 2');
			
            BoxObject2.FolderFile recordFolder;
            System.debug('Main - 3');
            System.debug('hic videtur -2 searchResult = ' + searchResult);
			
			
			
			
            //Check if the result set contains the folder with the same name
            if(searchResult.total_count > 0){
                for(BoxObject2.FolderFile folderFile : searchResult.entries){

                    System.debug('hic videtur -1 folderFile.name = ' + folderFile.name + ', opp.Name = ' + opp.Name);
                    System.debug(opp.Name);
                    System.debug(folderFile.name);
					System.debug('Is Equals: ' + (folderFile.name == opp.Name));
                    if(folderFile.name == opp.Name){
                        recordFolder = BoxAPIv2.getFolder(searchResult.entries[0].Id);
                        System.debug(recordFolder);
                    }
                }
            }
			*/
			System.debug('submitToBanks - 1');
			BoxObject2.FolderFile recordFolder;
			box__FRUP__c frup = [SELECT Id, box__Folder_ID__c, box__Record_ID__c
								FROM box__FRUP__c
								WHERE box__Record_ID__c = :opp.Id
								ORDER BY CreatedDate DESC LIMIT 1];
			System.debug('frup: ' + frup);
			String folderId = frup.box__Folder_ID__c;
			System.debug('submitToBanks - 2');
			System.debug('folderId: ' + folderId);
			
			try {
				recordFolder = BoxAPIv2.getFolder(folderId);
			} catch(Exception ex) {
				 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an Issue accessing Box files. Please try again in a few minutes.'));
	            return null;
			}
			System.debug('submitToBanks - 3');
            System.debug('hic videtur 0 ' + recordFolder);

            if(recordFolder != null && recordFolder.item_collection != null && recordFolder.item_collection.entries.size() > 0){
                for(BoxObject2.MiniFolderFile folderEntry : recordFolder.item_collection.entries){
                    if (folderEntry.name == 'Statements' && folderEntry.type == 'folder'){
                        statementsFolderId = folderEntry.id;
                    }
                }
            }
            System.debug('hic videtur 1' + statementsFolderId);

            //Check if the statements folder has been found.
            if(statementsFolderId == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to send, no statements folder found. Please create a folder named "Statements" in the Box.com folder and put the files there.'));
                //BoxAPIv2.upsertAuthInfoSync();
                return null;
            } else{
                FolderItems folderItems = BoxAPIv2.getFolderItems(statementsFolderId); 
                entryList = folderItems.entries;
                EntryPackageManager manager = new EntryPackageManager();
    			packageList = manager.entriesToPackages(entryList);
            }
            System.debug('match bank amount: ' + matchBankList.size());
            for(MatchBank f : matchBankList){
            	System.debug('selected: ' + f.IsSelected);
               if(f.IsSelected){
                    Submissions__c newSubmission = new Submissions__c(Opportunity__c = opp.Id, Funder__c = f.funder.Id);
                    submissionList.add(newSubmission);
					if(!f.funder.Submit_Using_API__c)
						selectedFunderIdSet.add(f.funder.Id);
					selectedItems++;
                }
            }
            
            if(selectedItems == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'In order to Submit to Banks, you must select at least one Bank'));
                //BoxAPIv2.upsertAuthInfoSync();
                return null;
            }
            
            if(selectedItems > 10) {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select no more than 10 funders once'));
               // BoxAPIv2.upsertAuthInfoSync();
                return null;
            }
            System.debug('SendEmailWithBoxFiles: ' + packageList);
            System.debug('111');
            if(submissionList.size() > 0){
            	System.debug('222');          		
            	if(possibleSendWithAttachment(packageList, entryList)) {		
            		System.debug('333');
	            	for(Integer i = 0; i < packageList.size(); i++) {
	            			System.enqueueJob(new SendEmailWithBoxFiles(opp.Id, selectedFunderIdSet, packageList[i].entries, note, i + 1, packageList.size()));
	            	}
            	} else {
            		System.debug('444');
            		sendEmailWithEmbedLink();
            	}
                insert submissionList;
            }
            //BoxAPIv2.upsertAuthInfoSync();

        }catch(Exception e){
        	System.debug(e.getMessage());
        	System.debug(e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The developer has been notified about this error.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()));
            //BoxAPIv2.upsertAuthInfoSync();
            return null;
        }

		return null;
        //return new PageReference('/' + opp.Id);
    }

	private boolean possibleSendWithAttachment(List<EntryPackage> packageList, List<FolderItems.Entry> entryList) {
		// send with attachment only if next conditions are met:
		//	1. packageList is not null. if packageList is null, it beacause there is a file which is bigger than the max size per email
		//  2. there is less than 60 files
		//	3. there is no more than 6 seperate emails
		return packageList != null && entryList.size() < 60 && packageList.size() < 7;
	}
	
	private void sendEmailWithEmbedLink() {
		
		BoxObject2.FolderFile statementsFolder = BoxAPIv2.shareFolder(statementsFolderId);
        System.debug(statementsFolder.shared_link.url);
        String boxLink = statementsFolder.shared_link.url;
                
        List<OrgWideEmailAddress> oweaList = null;

//		String userRoleName = user.UserRole.DeveloperName;
		String userRoleName = opp.Owner.UserRole.DeveloperName;

		if ( userRoleName == 'Manager_Aiden_s_Team' || userRoleName == 'Sales_Reps_Aiden_s_Team') {
			oweaList = [select Id from OrgWideEmailAddress where Address = 'emc2@emcfinancial.com'];
		} else {
			oweaList = [select Id from OrgWideEmailAddress where Address = 'admin@emcfinancial.com'];
		}

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Body, Subject, HTMLValue FROM EmailTemplate WHERE Name='Funder Notification'];
            
		for(MatchBank f : matchBankList){
			if(f.IsSelected){
				
			    String contactName = '';
			    if (f.funder.Contact_Name__c != null) contactName = f.funder.Contact_Name__c;
			    else contactName = 'Funder Contact';

		        //Generate the email for each funder
		        String emailBody = String.valueOf(template.HTMLValue);
		        emailBody = emailBody.replace('<![CDATA[', '');
		        emailBody = emailBody.replace('{!CONTACT_NAME}', contactName);
		        emailBody = emailBody.replace('{!BOX_LINK}', boxLink);
		        emailBody = emailBody.replace('{!ADDITIONAL_NOTES}', note);
		        emailBody = emailBody.replace(']]>', '');
		                    
		        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		        
		        //Set admin@emcfinancial.com as OWEA
		        if (oweaList.size() > 0){
		            mail.setOrgWideEmailAddressId(oweaList[0].Id);
		        }
		
		        String emailSubject = String.valueOf(template.Subject);
				if ( userRoleName == 'Manager_Aiden_s_Team' || userRoleName == 'Sales_Reps_Aiden_s_Team') {
					emailSubject += ' (Aiden\'s team)';
				}
		        emailSubject = emailSubject.replace('{!Account.Name}', opp.Account.Name);
		        
		        mail.setHTMLBody(emailBody);
		        mail.setSubject(emailSubject);
		        
		        List<String> targets = new List<String>();
				
		        if(!runningInASandbox()) {

					if (f.funder.Portal_Lender_None_API__c) {
						if (String.isNotBlank(opp.Owner.Admin_Email__c)) {
							targets.add(opp.Owner.Admin_Email__c);
						} else {
							targets.add('admin@emcfinancial.com');
						}
					} else {

						if (f.funder.Contact_Email__c != null) {
							targets.add(f.funder.Contact_Email__c);
						}

						if (f.funder.Additional_Email_1__c != null) {
							targets.add(f.funder.Additional_Email_1__c);
						}

						if (f.funder.Additional_Email_2__c != null) {
							targets.add(f.funder.Additional_Email_2__c);
						}
					}

					List<String> bccAddresses = new List<String>();
					bccAddresses.add(opp.Owner.Email);
					mail.setBccAddresses(bccAddresses);
				} else {
					targets.add(Label.DeveloperEmail);
				}
		        
		        mail.setToAddresses(targets);
		        emailsToSend.add(mail);
		        
			}
		}
		
		Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);

		if (results[0].success) {
		    System.debug('The email was sent successfully.');
		} else {
		    System.debug('The email failed to send: ' + results[0].errors[0].message);
		}
		
	}
    
    public class NonMatchFunder implements Comparable {
        public Funder__c funder{get; set;}
        public List<String> reasonList {get; set;}
        public NonMatchFunder(Funder__c funder,  List<String> reasonList){
            this.funder = funder;
            this.reasonList = reasonList;
        }
        public Integer compareTo(Object compareTo) {
        	
        	NonMatchFunder funderToCompare = (NonMatchFunder)compareTo;
        	
        	Integer returnValue = 0;
        	
        	
        	if(this.funder.Number_Of_Max_Positions__c > funderToCompare.funder.Number_Of_Max_Positions__c) {
        		returnValue = 1;
        	} else if(this.funder.Number_Of_Max_Positions__c < funderToCompare.funder.Number_Of_Max_Positions__c) {
        		returnValue = -1;
        	}
        	
        	return returnValue;
        	        	
        }
    }
    
    public Boolean sendEmail(String emailTo, String emailSubject, String emailBody){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        //Splitting TO email addresses and adding in array
        String[] toAddresses = new String[]{};
        for(String emailId:emailTo.split(',')){
            if(emailId != null && emailId !=''&& emailId != ' '){
                toAddresses.add(emailId.trim());
            }
        }

        //Assigning TO address array
        mail.setToAddresses(toAddresses);
        mail.setSubject(emailSubject);
        mail.setPlainTextBody((emailBody==null ? 'This email body is empty' : emailBody));
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
        return true;
    }
    
    private static Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public PageReference submitFundersUsingAPI() {

		if(submissionList != null && submissionList.size() > 0) {

			System.debug('A');
			System.debug('A');

			Map<Id,Submissions__c> submissionMap = new Map<Id,Submissions__c>(submissionList);
			List<Submissions__c> submissionToSendUsingAPI =  [
					SELECT Id, Opportunity__c, Funder__c, Submit_Funder_Using_API__c
					FROM Submissions__c
					WHERE id In :submissionMap.keySet() AND Submit_Funder_Using_API__c = True];

			if(submissionToSendUsingAPI.size() > 0) {

				System.debug('A');
				System.debug('A');

				System.debug(submissionToSendUsingAPI.size());
				System.debug(submissionToSendUsingAPI);
				System.debug(submissionToSendUsingAPI[0]);
				System.debug(submissionToSendUsingAPI[0].Id);
				System.debug(submissionToSendUsingAPI[0].Opportunity__c);
				System.debug(submissionToSendUsingAPI[0].Funder__c);
				System.debug(submissionToSendUsingAPI[0].Submit_Funder_Using_API__c);
				System.debug(JSON.serialize(submissionToSendUsingAPI));
				Http http = new Http();
				HttpRequest req=new HttpRequest();
				req.setendpoint(Label.Heroku_API_Submissions_Url + '/submissions/');
				req.Setheader('Content-Type','application/json');
				req.Setheader('Accept','application/json');
				req.setmethod('POST');
				req.setTimeout(120000);
				req.setbody(JSON.serialize(submissionToSendUsingAPI));
				HttpResponse res;
				res = http.send(req);
				String content = res.getbody();
				System.debug(content);
			}

			System.debug('Submit_Funder_Using_Internal_API__c Step 1.1: Starts');
			List<Submissions__c> submissionToSendUsingInternalAPI =  [
					SELECT Id, Opportunity__c, Funder__c, Submit_Funder_Using_API__c, Funder__r.Name, Submit_Funder_Using_Internal_API__c
					FROM Submissions__c
					WHERE id In :submissionMap.keySet() AND Submit_Funder_Using_Internal_API__c = True];
			if(submissionToSendUsingInternalAPI.size() > 0) {
				System.debug('Submit_Funder_Using_Internal_API__c Step 1.2: submissions found');
				System.debug(submissionToSendUsingInternalAPI.size());
				System.debug(submissionToSendUsingInternalAPI);
				System.debug(submissionToSendUsingInternalAPI[0]);
				System.debug(submissionToSendUsingInternalAPI[0].Id);
				System.debug(submissionToSendUsingInternalAPI[0].Opportunity__c);
				System.debug(submissionToSendUsingInternalAPI[0].Funder__c);
				System.debug(submissionToSendUsingInternalAPI[0].Submit_Funder_Using_Internal_API__c);

				SubmitFunderInternalAPIsManager manager = new SubmitFunderInternalAPIsManager();
				manager.executeSubmitToFundersCallouts(submissionToSendUsingInternalAPI);
			}
		}
		return new PageReference('/' + opp.Id);
    }
}