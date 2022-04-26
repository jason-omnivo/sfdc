@isTest
public with sharing class BankFinderControllerTest {
	
	 static testMethod void testController(){


        OAuthSettings__c boxOauthSettings = new OAuthSettings__c(Name = 'Box', 
                                                                 AuthEndpoint__c = 'https://api.box.com/oauth2/',
                                                                 ClientID__c = '3mzva5k0vese7c8g2p5ta4fc8wtp1s18',
                                                                 ClientSecret__c = 'NvWeDmNlqRowsWXmgzVknifLSiZNLLu9');
        insert boxOauthSettings;

        Box_OAuth__c boxOAuth = new Box_OAuth__c(); //SetupOwnerId = UserInfo.getUserId()
        boxOAuth.Auth_Token__c = '1234567890';
        boxOAuth.Refresh_Token__c = '1234567890';
        boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
        boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
        insert boxOAuth;

		Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Auth_Endpoint__c = 'https://api.box.com/oauth2/';
        boxAuthObj.Auth_Token__c = '1234567890';
        boxAuthObj.Refresh_Token__c = '1234567890';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = '12345';
        boxAuthObj.Client_Secret__c  = '12345';
        insert boxAuthObj;

        Account acc = new Account(Name = 'Test Opp',
                                    Percent_of_Ownership_1__c = 10,
                                    Industry__c = 'Technology',
                                    Legal_State__c = 'NY',
                                    Date_Business_Established__c = Date.newInstance(1992, 08, 26),
                                    Partner_1_Credit_Score__c = 90,
                                    DBA_Name__c = 'sda');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',
                                            AccountId = acc.Id,
                                            StageName = 'Prospecting',
                                            CloseDate = Date.newInstance(2014, 11, 4));
        insert opp;
				
        Funder__c funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                                            Restricted_Industries__c = 'Fashion;',
                                            Restricted_States__c = 'IL;',
                                            Time_in_business__c = 1,
                                            Credit_Score__c = 89,
                                            Active__c = true,
                                            Minimum_Annual_Revenue__c = -1000,
                                            Longest_Term__c = 20,
                                            Max_Neg_Days_Last_Month__c = 20,
                                            Minimum_Avg_Daily_Balance__c = -100,
                                            Positions__c = 'Unlimited',
                                            Contact_Email__c = 'test@email.com',
                                            Payment_Options__c = 'Daily');
                                            
        insert funder;
     	
     	funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                                            Restricted_Industries__c = 'Fashion;',
                                            Restricted_States__c = 'IL;',
                                            Time_in_business__c = 1,
                                            Credit_Score__c = 89,
                                            Active__c = true,
                                            Minimum_Annual_Revenue__c = -1000,
                                            Longest_Term__c = 20,
                                            Max_Neg_Days_Last_Month__c = 20,
                                            Minimum_Avg_Daily_Balance__c = -100,
                                            Positions__c = 'Unlimited',
                                            Contact_Email__c = 'test@email.com',
                                            Payment_Options__c = 'Daily');

		insert funder;
		
     	funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                                    Restricted_Industries__c = 'Fashion;',
                                    Restricted_States__c = 'IL;',
                                    Time_in_business__c = 1,
                                    Credit_Score__c = 89,
                                    Active__c = true,
                                    Minimum_Annual_Revenue__c = -1000,
                                    Longest_Term__c = 20,
                                    Max_Neg_Days_Last_Month__c = 20,
                                    Minimum_Avg_Daily_Balance__c = -100,
                                    Positions__c = 'Unlimited',
                                    Contact_Email__c = 'test@email.com',
                                    Payment_Options__c = 'Daily');

		insert funder;
		
		
        funder = new Funder__c(Ownership_Percentage_Requirment__c = 0,
                            Restricted_Industries__c = '',
                            Restricted_States__c = '',
                            Time_in_business__c = null,
                            Credit_Score__c = 89,
                            Active__c = true,
                            Minimum_Annual_Revenue__c = null,
                            Longest_Term__c = 20,
                            Max_Neg_Days_Last_Month__c = 0,
                            Minimum_Avg_Daily_Balance__c = -100,
                            Positions__c = 'Up to 1',
                            Contact_Email__c = 'test@email.com');
        insert funder;
		
		Funding_Payment__c fundingPayment = new Funding_Payment__c();
		fundingPayment.Opportunity__c = opp.Id;
		fundingPayment.Funder__c = funder.id;
		
		insert fundingPayment;
		
		box__FRUP__c frup = new box__FRUP__c();
		frup.box__Folder_ID__c = '123455';
		frup.box__Record_ID__c = opp.Id;
		
		insert frup;
		
        Test.startTest();

        PageReference pageRef = Page.BankFinder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
	
		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
		
	/*
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
		multimock.setStaticResource('https://api.box.com/2.0/folders/413165545057/items', 'GetFolderResponse');
		multimock.setStaticResource('http://example.com/example/sfdc', 'GetFolderResponse');
		multimock.setStatusCode(200);
		multimock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, multimock);
		
		
	    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('GetFolderResponse');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock);
	
	
        StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
		mock2.setStaticResource('GetFolderResponse');
		mock2.setStatusCode(200);
		mock2.setHeader('Content-Type', 'application/json');
		Test.setMock(HttpCalloutMock.class, mock2);
		*/
		

        BankFinderController c = new BankFinderController();
        //c.submitToBanks();

        c.getMatchedBanks();

        c.submitToBanks();
        //Test no selection
        c.matchBankList[0].isSelected = false;
        c.submitToBanks();

		c.getNonMatchedBanks();
		c.getlastmonthNegDays();
		c.sortByFunderName();
		c.sortByFunderName();
		c.sortByCommision();
		c.sortByTier();
		c.sortBymaxAmount();
		c.sortByLongestTerm();
		c.sortByPaymentOptions();
		c.sortByLowestBuyRate();
		c.sortByApprovalTimeIn_Hours();
		c.sortByPCTFromApprovedToFunded();
		c.sortByLowestBuyRate();
		
		c.matchBankList[0].isSelected = true;
		c.submitToBanks();
		
        c.matchBankList[0].isSelected = true;
        c.note = 'Lorem ipsum dolor sit amet.';
        c.submitToBanks();
        boxOAuth.Auth_Token__c = '1234567890';
        boxOAuth.Refresh_Token__c = '1234567890';
        boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
        boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(-60);
        update boxOAuth;
        c.submitToBanks();
        Test.stopTest();

    }
	
    static testMethod void testControllerBigFiles(){


        OAuthSettings__c boxOauthSettings = new OAuthSettings__c(Name = 'Box', 
                                                                 AuthEndpoint__c = 'https://api.box.com/oauth2/',
                                                                 ClientID__c = '3mzva5k0vese7c8g2p5ta4fc8wtp1s18',
                                                                 ClientSecret__c = 'NvWeDmNlqRowsWXmgzVknifLSiZNLLu9');
        insert boxOauthSettings;

        Box_OAuth__c boxOAuth = new Box_OAuth__c(); //SetupOwnerId = UserInfo.getUserId()
        boxOAuth.Auth_Token__c = '1234567890';
        boxOAuth.Refresh_Token__c = '1234567890';
        boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
        boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
        insert boxOAuth;

		Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Auth_Endpoint__c = '';
        boxAuthObj.Auth_Token__c = '1234567890';
        boxAuthObj.Refresh_Token__c = '1234567890';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = '12345';
        boxAuthObj.Client_Secret__c  = '12345';
        insert boxAuthObj;

        Account acc = new Account(Name = 'Test Opp',
                                    Percent_of_Ownership_1__c = 10,
                                    Industry__c = 'Technology',
                                    Legal_State__c = 'NY',
                                    Date_Business_Established__c = Date.newInstance(1992, 08, 26),
                                    Partner_1_Credit_Score__c = 90,
                                    DBA_Name__c = 'sda');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',
                                            AccountId = acc.Id,
                                            StageName = 'Prospecting',
                                            CloseDate = Date.newInstance(2014, 11, 4));
        insert opp;

    	Funder__c funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                            Restricted_Industries__c = 'Fashion;',
                            Restricted_States__c = 'IL;',
                            Time_in_business__c = 1,
                            Credit_Score__c = 89,
                            Active__c = true,
                            Minimum_Annual_Revenue__c = -1000,
                            Longest_Term__c = 20,
                            Max_Neg_Days_Last_Month__c = 20,
                            Minimum_Avg_Daily_Balance__c = -100,
                            Positions__c = 'Unlimited',
                            Contact_Email__c = 'test@email.com',
                            Payment_Options__c = 'Daily');

		insert funder;
		
		box__FRUP__c frup = new box__FRUP__c();
		frup.box__Folder_ID__c = '123455';
		frup.box__Record_ID__c = opp.Id;
		
		insert frup;

        Test.startTest();

        PageReference pageRef = Page.BankFinder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
	
		
		string oppName = 'Test Opp - Submitted ' + DateTime.now().format('yyyy-MM-dd');
		QueueHttpMock mock = new QueueHttpMock();
		HttpResponse res1 = new HttpResponse();
		res1.setBody('{"total_count":1,"entries":[{"type":"folder","id":"2600405987","sequence_id":"0","etag":"0","name":"' + oppName + '","created_at":"2014-10-23T09:34:21-07:00","modified_at":"2014-10-27T10:09:05-07:00","description":"","size":3651518,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"2600384835","sequence_id":"0","etag":"0","name":"Salesforce"}]},"created_by":{"type":"user","id":"190985855","name":"sochy eisenberg","login":"sochye@gmail.com"},"modified_by":{"type":"user","id":"190985855","name":"sochy eisenberg","login":"sochye@gmail.com"},"trashed_at":null,"purged_at":null,"content_created_at":"2014-10-23T09:34:21-07:00","content_modified_at":"2014-10-27T10:09:05-07:00","owned_by":{"type":"user","id":"190985855","name":"sochy eisenberg","login":"sochye@gmail.com"},"shared_link":{"url":"https://app.box.com/s/7ibcte0ssyk94xnytdho","download_url":null,"vanity_url":null,"effective_access":"open","is_password_enabled":false,"unshared_at":null,"download_count":0,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"folder_upload_email":null,"parent":{"type":"folder","id":"2600384835","sequence_id":"0","etag":"0","name":"Salesforce"},"item_status":"active"}],"limit_x":30,"offset":0}');
		res1.setStatusCode(200);
		res1.setHeader('Content-Type', 'application/json');
		
		HttpResponse res2 = new HttpResponse();
		res2.setBody('{"type": "folder","id": "11446498","sequence_id": "1","etag": "1","name": "Pictures","created_at": "2012-12-12T10:53:43-08:00","modified_at": "2012-12-12T11:15:04-08:00","description": "Some pictures I took","size": 629644,"path_collection": {"total_count": 1,"entries": [{"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"}]},"created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"modified_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"owned_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"shared_link": {"url": "https://www.box.com/s/vspke7y05sb214wjokpk","download_url": "https://www.box.com/shared/static/vspke7y05sb214wjokpk","vanity_url": null,"is_password_enabled": false,"unshared_at": null,"download_count": 0,"preview_count": 0,"access": "open","permissions": {"can_download": true,"can_preview": true}},"folder_upload_email": {"access": "open","email": "upload.Picture.k13sdz1@u.box.com"},"parent": {"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"},"item_status": "active","item_collection": {"total_count": 2,"entries": [{"type": "file","id": "5000948880","sequence_id": "3","etag": "3","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc","name": "tigers.jpeg"},{"type": "folder","id":"6000948880","sequence_id": "4","etag": "3","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc","name": "Statements"}],"offset": 0,"limit": 100},"tags": ["approved","ready to publish"]}');
		res2.setStatusCode(200);
		res2.setHeader('Content-Type', 'application/json');
		
		HttpResponse res3 = new HttpResponse();
		res3.setBody('{"total_count":5,"entries":[{"type":"file","id":"69150148921","etag":"0","name":"APP-&More.pdf","description":"","size":100000000},{"type":"file","id":"69150151069","etag":"0","name":"BS_3067_022016.pdf","description":"","size":625146},{"type":"file","id":"69150152293","etag":"0","name":"BS_3067_032016.pdf","description":"","size":486244},{"type":"file","id":"69150150065","etag":"0","name":"BS_3067_042016.pdf","description":"","size":308766},{"type":"file","id":"69150149689","etag":"0","name":"BS_3067_052016.pdf","description":"","size":185899}],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}');
		res3.setStatusCode(200);
		res3.setHeader('Content-Type', 'application/json');
		
		HttpResponse res4 = new HttpResponse();
		res4.setBody('{"type": "folder","id": "11446498","sequence_id": "1","etag": "1","name": "Pictures","created_at": "2012-12-12T10:53:43-08:00","modified_at": "2012-12-12T11:15:04-08:00","description": "Some pictures I took","size": 629644,"path_collection": {"total_count": 1,"entries": [{"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"}]},"created_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"modified_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"owned_by": {"type": "user","id": "17738362","name": "sean rose","login": "sean@box.com"},"shared_link": {"url": "https://www.box.com/s/vspke7y05sb214wjokpk","download_url": "https://www.box.com/shared/static/vspke7y05sb214wjokpk","vanity_url": null,"is_password_enabled": false,"unshared_at": null,"download_count": 0,"preview_count": 0,"access": "open","permissions": {"can_download": true,"can_preview": true}},"folder_upload_email": {"access": "open","email": "upload.Picture.k13sdz1@u.box.com"},"parent": {"type": "folder","id": "0","sequence_id": null,"etag": null,"name": "All Files"},"item_status": "active","item_collection": {"total_count": 2,"entries": [{"type": "file","id": "5000948880","sequence_id": "3","etag": "3","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc","name": "tigers.jpeg"},{"type": "folder","id":"6000948880","sequence_id": "4","etag": "3","sha1": "134b65991ed521fcfe4724b7d814ab8ded5185dc","name": "Statements"}],"offset": 0,"limit": 100},"tags": ["approved","ready to publish"]}');
		res4.setStatusCode(200);
		res4.setHeader('Content-Type', 'application/json');
				
		HttpResponse res5 = new HttpResponse();
		res5.setBody('');
		res5.setStatusCode(302);
		res5.setHeader('Location', 'https://api.box.com/2.0/12345');
		
		HttpResponse res6 = new HttpResponse();
		res6.setBody('12345');		
		res6.setStatusCode(200);
		
		mock.addResponse(res1);
		mock.addResponse(res2);
		mock.addResponse(res3);
		mock.addResponse(res4);
		mock.addResponse(res5);
		mock.addResponse(res6);
		Test.setMock(HttpCalloutMock.class, mock);
		
        BankFinderController c = new BankFinderController();
        //c.submitToBanks();

        c.getMatchedBanks();
        c.matchBankList[0].isSelected = true;

        //c.submitToBanks();
        //Test no selection
        //c.submitToBanks();

		c.getNonMatchedBanks();
		c.sortByFunderName();
		c.sortByCommision();
		c.sortByLongestTerm();
		c.sortByPaymentOptions();
		c.sortByLowestBuyRate();
		c.sortByApprovalTimeIn_Hours();
		c.sortByPCTFromApprovedToFunded();
		c.sortByLowestBuyRate();
		
		c.matchBankList[0].isSelected = true;
		c.submitToBanks();
		
        c.matchBankList[0].isSelected = true;
        c.note = 'Lorem ipsum dolor sit amet.';
        c.submitToBanks();
        boxOAuth.Auth_Token__c = '1234567890';
        boxOAuth.Refresh_Token__c = '1234567890';
        boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
        boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(-60);
        update boxOAuth;
        c.submitToBanks();
        Test.stopTest();

    }
    
     static testMethod void testSendEmailWithBoxFiles(){
 	    
 	     OAuthSettings__c boxOauthSettings = new OAuthSettings__c(Name = 'Box', 
                                                                 AuthEndpoint__c = 'https://api.box.com/oauth2/',
                                                                 ClientID__c = '3mzva5k0vese7c8g2p5ta4fc8wtp1s18',
                                                                 ClientSecret__c = 'NvWeDmNlqRowsWXmgzVknifLSiZNLLu9');
        insert boxOauthSettings;

        Box_OAuth__c boxOAuth = new Box_OAuth__c(); //SetupOwnerId = UserInfo.getUserId()
        boxOAuth.Auth_Token__c = '1234567890';
        boxOAuth.Refresh_Token__c = '1234567890';
        boxOAuth.AuthTokenExpires__c = Datetime.now().addSeconds(-3600);
        boxOAuth.RefreshTokenExpires__c = Datetime.now().addDays(60);
        insert boxOAuth;

		Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Auth_Endpoint__c = '';
        boxAuthObj.Auth_Token__c = '1234567890';
        boxAuthObj.Refresh_Token__c = '1234567890';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = '12345';
        boxAuthObj.Client_Secret__c  = '12345';
        insert boxAuthObj;
        
 	    List<Account> accountList = TestDataGenerator.createAccountList(1);
 	    List<Contact> contactList = TestDataGenerator.createContactList(accountList);
 	    List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
 	    List<Funder__c> funderList = TestDataGenerator.createFunderlist(2);
 	    
 	    box__FRUP__c frup = new box__FRUP__c();
		frup.box__Folder_ID__c = '123455';
		frup.box__Record_ID__c = oppList[0].Id;
		
		insert frup;
		
 	    Set<Id> funderIdSet = new Set<Id>();
 	    for(funder__c funder : funderList) {
 	    	funderIdSet.add(funder.Id);
 	    }
 	    
 	    List<FolderItems.Entry> entries = new List<FolderItems.Entry>();
 	    FolderItems.Entry entry = new FolderItems.Entry('file', '12345', '123', 'Test file', 'Test description',1000);
 	    entries.add(entry);
 	    
 	    Test.startTest();
        
        QueueHttpMock mock = new QueueHttpMock();
		HttpResponse res1 = new HttpResponse();
		res1.setBody('');
		res1.setStatusCode(302);
		res1.setHeader('Location', 'https://api.box.com/2.0/12345');
		
		HttpResponse res2 = new HttpResponse();
		res2.setBody('12345');		
		res2.setStatusCode(200);
        
        mock.addResponse(res1);
		mock.addResponse(res2);
        Test.setMock(HttpCalloutMock.class, mock);
        
        SendEmailWithBoxFiles sendEmailWithBoxFiles = new SendEmailWithBoxFiles(oppList[0].Id, funderIdSet, entries, '', 1, 1); 
        ID jobID = System.enqueueJob(sendEmailWithBoxFiles);
        Test.stopTest();
        System.assert(jobID != null);
     }
}