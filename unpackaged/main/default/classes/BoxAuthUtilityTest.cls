@isTest
public class BoxAuthUtilityTest {
    /*private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HTTPResponse res = new HTTPResponse();
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
            
        }
    }*/
    
    //@isTest(SeeAllData=true)
    @isTest
    public static void test1(){
        //OAuthSettings__c objOauth = new OAuthSettings__c();
        //objOauth.Name = 'Box';
        //objOauth.AuthEndpoint__c = 'https://api.box.com/oauth2/' ;
        //objOauth.ClientId__c = 'o64e0pvy40cthziqawl9jm4fyk8dpy77' ;
        //objOauth.ClientSecret__c = 'iOMt6MAxXWbjQ9ivCkshjO9gHSQWBz4i';
        //insert objOauth;
        Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Name = 'EMC App2';
        boxAuthObj.Auth_Endpoint__c = 'https://api.box.com/oauth2/';
        boxAuthObj.Auth_Token__c = 'kT9goswrfLFRb1fUeYBtIbja3hMbg3Da';
        boxAuthObj.Refresh_Token__c = 'kiucGs4Rny0XxfOaoFRXTvNN5pRJX54H55fMvs5yuuBvISeFHSNqRIKilC3KRH60';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = 'erhf4g9v1el82jqesfd9dtt2h1vyc14e';
        boxAuthObj.Client_Secret__c  = 'a1qUgMkcPFG1sNGXzpTzZkX0uo6k09wa';
        insert boxAuthObj;

        //PageReference pageReference = Page.ApplicationForm;
        //Test.setCurrentPage(pageReference);
        
        ApexPages.currentPage().getParameters().put('code', 'test');    
        BoxAuthUtility obj = new BoxAuthUtility();
        new BoxAuthUtility(true);
        
        //obj.auth();
        //obj.AccessToken('test');
        
       	Account a = new Account();
		a.Name='Test Cloufi Account';
        a.DBA_Name__c='Test DBA Name';
 		insert a;
		
        Opportunity opp=new Opportunity();
		opp.Name='Test Opportunity 101';
		Opp.StageName='Prospecting';
		opp.CloseDate=system.today();
		opp.Accountid=a.id;
		insert opp;


        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        Insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion where id =: cv.Id];

        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = a.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId = cv.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
    	ContentDocumentLink cdltest = [SELECT Id, LinkedEntityId, ContentDocumentId from ContentDocumentLink where id = :contentlink.id];
        System.debug(cdltest.LinkedEntityId);
	   System.debug(a.id);
      /*  
        {
			Set<Id> contentVersionIdSet = new Set<id>{cv.id};
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            String q;

            q =  'SELECT ' + String.join(BoxAuthUtility.getFieldsOfsObject('ContentVersion'), ',' );
            q += ' FROM ContentVersion WHERE Id IN : contentVersionIdSet';                
            
            contentVersionList = Database.Query(q);

            Set<Id> contentDocumentIdSet = new Set<Id>();
            Map<Id, Id> contentVersionDocumentMap = new Map<Id, Id>();
            Map<Id, Id> contentVersionAndLinkEntityMap = new Map<Id, Id>();
            
            for(ContentVersion objContentVersion : contentVersionList){
                contentDocumentIdSet.add(objContentVersion.ContentDocumentId);
                contentVersionDocumentMap.put(objContentVersion.ContentDocumentId, objContentVersion.Id);
            }
            
            for(ContentDocumentLink objContentDocumentLink : [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type FROM ContentDocumentLink WHERE ContentDocumentId IN : contentDocumentIdSet]){
                if(objContentDocumentLink.LinkedEntity.Type != 'User'){
                    contentVersionAndLinkEntityMap.put(contentVersionDocumentMap.get(objContentDocumentLink.ContentDocumentId), objContentDocumentLink.LinkedEntityId);
                }
            }

            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Set<id> contentDocumentIdSetToDelete = new Set<id>();
            for(ContentVersion objContentVersion : contentVersionList){
                if(contentVersionAndLinkEntityMap.get(objContentVersion.Id) != null) {
                    Id recordId = contentVersionAndLinkEntityMap.get(objContentVersion.Id);
                    Schema.SObjectType sObjType = gd.get(recordId.getSObjectType().getDescribe().getName());
                    Schema.DescribeSObjectResult describeResult = sObjType.getDescribe(); 
                    
                    String query;

                   // query = 'SELECT Id, Name FROM '+ describeResult.getName();
                   // query += ' WHERE Id = \''+recordId+'\'';
                    
                    query ='SELECT Id, Name FROM Opportunity';
					query += ' WHERE accountid= \''+recordId+'\'';
					query +=' ORDER BY createddate DESC LIMIT 1';
					System.debug(recordId);
					System.debug(query);
                    sObject objLinkedEntity = Database.Query(query);            
            
                }
            }
        }
        
        */
        BoxAuthUtility.getFieldsOfsObject('contact');
        Box_OAuth__c objBoxOAuthSetting = Box_OAuth__c.getorgdefaults();
        objBoxOAuthSetting.Auth_Token__c = 'test';
        upsert objBoxOAuthSetting;
        BoxAuthUtility.uploadFilesInBoxForAll(new Set<id>{cv.id});
      
    }
    
    @isTest
    static void test3(){
        Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Name = 'EMC App2';
        boxAuthObj.Auth_Endpoint__c = 'https://api.box.com/oauth2/';
        boxAuthObj.Auth_Token__c = 'kT9goswrfLFRb1fUeYBtIbja3hMbg3Da';
        boxAuthObj.Refresh_Token__c = 'kiucGs4Rny0XxfOaoFRXTvNN5pRJX54H55fMvs5yuuBvISeFHSNqRIKilC3KRH60';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = 'erhf4g9v1el82jqesfd9dtt2h1vyc14e';
        boxAuthObj.Client_Secret__c  = 'a1qUgMkcPFG1sNGXzpTzZkX0uo6k09wa';
        insert boxAuthObj;

       	Account a = new Account();
		a.Name='Test Cloufi Account';
        a.DBA_Name__c='Test DBA Name';
 		insert a;
		
        Opportunity opp=new Opportunity();
		opp.Name='Test Opportunity 101';
		Opp.StageName='Prospecting';
		opp.CloseDate=system.today();
		opp.Accountid=a.id;
		insert opp;
        
        dsfs__DocuSign_Status__c docsign = new dsfs__DocuSign_Status__c();
        docsign.dsfs__DocuSign_Envelope_ID__c ='80579003-947B-482F-95B2-ABE6F91AA046';
        docsign.dsfs__Subject__c='Please DocuSign: EMC Funding Application.pdf';
        docsign.dsfs__Opportunity__c=opp.id;
        docsign.dsfs__Company__c=a.id;
        insert docsign;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=docsign.id;
        insert attach;
        
        BoxAuthUtility.getFieldsOfsObject('Attachment');
        Box_OAuth__c objBoxOAuthSetting = new Box_OAuth__c();
        objBoxOAuthSetting.Auth_Token__c =  boxAuthObj.Auth_Token__c;
        upsert objBoxOAuthSetting;
        BoxAuthUtility.uploadFilesInBoxForAttachment(new Set<id>{attach.id});
        BoxAuthUtility.setBoxFilePermissionPublic('aa');
    }

    
      
}