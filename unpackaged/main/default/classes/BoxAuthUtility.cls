/*****************************************************************
* Author: Techila Global Services Pvt Ltd. (Jasneet Duhttps://external-storage-dev-ed.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#a)
* Class Name: BoxAuthUtility
* Created Date: 06-May-2019
* Description: Utility class for Box OAuth2 
*******************************************************************/


public class BoxAuthUtility {
    String code ;
    String REDIRECT_URI;  // Redirect URI
    String STATE = 'Box';

    public static Box_OAuth_Object__c authInfo {
		get {
			if(authInfo == null) {
				 authInfo =
						[SELECT Auth_Endpoint__c, Auth_Token__c,
						Auth_Token_Expires__c, Refresh_Token__c,
						Refresh_Token_Expires__c, Client_Id__c, Client_Secret__c
						FROM Box_OAuth_Object__c
						ORDER BY Auth_Token_Expires__c DESC][0];
			}
			return authInfo;
		}
		public set;
	}    
    static String APP_KEY = authInfo.Client_Id__c;
    static String APP_SECRET = authInfo.Client_Secret__c;
	
   
    public BoxAuthUtility(){
  	  
      /*  this.REDIRECT_URI = URL.getSalesforceBaseUrl().toExternalForm() + '' + ApexPages.currentPage().getUrl();
        if(this.REDIRECT_URI.indexOf('?') >0 ){
            this.REDIRECT_URI = this.REDIRECT_URI.substring(0,this.REDIRECT_URI.indexOf('?'));
        }*/
    }
    
    public BoxAuthUtility(Boolean flag){}
    
    /*public PageReference Auth()
    {
        //Authenticating
        PageReference pg = new PageReference('https://account.box.com/api/oauth2/authorize?response_type=code&client_id='+APP_KEY+'&redirect_uri='+REDIRECT_URI+'&state='+STATE) ;
        return pg ;
    }*/
    
    /*public Map<String, Object> AccessToken(String code)
    {
        try {
            String tokenuri = 'https://api.box.com/oauth2/token';
            String body = 'grant_type=authorization_code';
            body += '&code='+code;
            body += '&client_id='+APP_KEY;
            body += '&client_secret='+APP_SECRET;
            body += '&redirect_uri='+REDIRECT_URI;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenuri);
            req.setMethod('POST');
            req.setbody(body);
            req.setTimeout(60*1000);

            Http h = new Http();
            String resp;
            HttpResponse res;
            if(!Test.isRunningTest()){
                res = h.send(req);
            }
            else {
                res = new HttpResponse();
                res.setBody('{"access_token": "test", "refresh_token":"refresh_token"}');
            }
            resp = res.getBody();
            System.debug('HTTP response with Access token : return >>>>'+ resp);

            return (Map<String, Object>)JSON.deserializeUntyped(resp);
        }
        catch(Exception e){
            System.debug('BoxAuthUtility');
            System.debug('AccessToken');
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            return null;
        }                        
    }*/

    // Box Utilities
        public static blob base64EncodeFileContentForBox(Blob file_body, String file_name){
            try {
                String boundary = '----------------------------foo_bar_baz';
                String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
                String footer = '--'+boundary+'--';
                String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                while(headerEncoded.endsWith('='))
                {
                    header+=' ';
                    headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
                }
                String bodyEncoded = EncodingUtil.base64Encode(file_body);
                Blob bodyBlob = null;
                String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
                if(last4Bytes.endsWith('==')) {
                    last4Bytes = last4Bytes.substring(0,2) + '0K';
                    bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
                } else if(last4Bytes.endsWith('=')) {
                    last4Bytes = last4Bytes.substring(0,3) + 'N';
                    bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
                    footer = '\n' + footer;
                    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
                } else {
                    footer = '\r\n' + footer;
                    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
                    bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
                }
                return bodyBlob;
            } catch(Exception e){

                System.debug('ExternalStorageUtility');
                System.debug('base64EncodeFileContentForBox');
                System.debug(e.getStackTraceString());
                System.debug(e.getMessage());
                return null;
            }

        }

        public static string setBoxFilePermissionPublic(String fileId) {
            try {
                String permissionBody = '{"shared_link": {"access":"open"}}';
                //String accessToken = Box_OAuth__c.getOrgDefaults().Auth_Token__c;
                String accessToken = authInfo.Auth_Token__c;
                
                Http http = new Http();

                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://api.box.com/2.0/files/'+fileId.trim());
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                req.setHeader('Accept', 'application/json');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(permissionBody);
                req.setMethod('PUT');
                req.setTimeout(60 * 1000);
                HttpResponse respJson;
                if(!Test.isRunningTest()) {
                respJson = http.send(req);
                }
                else {
                    respJson = new HttpResponse();
                    respJson.setBody('{"shared_link": {"url": "url"}}');
                }

                Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(respJson.getBody());
                if( resp.containsKey('shared_link') ) {
                    Map<String, Object> resp1 = (Map<String, Object>)resp.get('shared_link');
                    if( resp1.containsKey('url') ) {
                        return String.valueof(resp1.get('url'));
                    }
                }
                return '';
            } catch(Exception e){

                System.debug('ExternalStorageUtility');
                System.debug('setBoxFilePermissionPublic');
                System.debug(e.getStackTraceString());
                System.debug(e.getMessage());

                return '';
            }
            
        }    

        public static String getBoxFolderId(String folderName,String inFolderId) {
            try {
                String body = '{ "name":"'+folderName+'", "parent": {"id": "'+inFolderId+'"} }';

                //String accessToken = Box_OAuth2_Cred__c.getOrgDefaults().Auth_Token__c;
                //String accessToken = Box_OAuth__c.getOrgDefaults().Auth_Token__c;
                String accessToken = authInfo.Auth_Token__c;
                
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://api.box.com/2.0/folders');
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Content-Length',String.valueof(body.length()));
                req.setBody(body);
                req.setTimeout(60 * 1000);
                HttpResponse respJson;
                if(!Test.isRunningTest()){
                    respJson= http.send(req);
                }
                else {
                    respJson= new HttpResponse();
                    respJson.setBody('{"id":"test"}');
                }
                String searchedFolderId = inFolderId;
                JSONParser parser = JSON.createParser(respJson.getBody());
                while (parser.nextToken() != null) {
                    if (parser.getText() == 'id') {
                        parser.nextToken();
                        searchedFolderId = parser.getText();
                        break;
                    }
                }
                return searchedFolderId;
            } catch(Exception e){
                System.debug('ExternalStorageUtility');
                System.debug('getBoxFolderId');
                System.debug(e.getStackTraceString());
                System.debug(e.getMessage());
                return '';
            }
        }

        public static List<String> getFieldsOfsObject(String sObjectName){
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
            Schema.SObjectType sObjType = gd.get(sObjectName);
            Schema.DescribeSObjectResult describeResult = sObjType.getDescribe();
            List<String> fields;
            fields = new List<String>(describeResult.fields.getMap().keySet());
            return fields;
        }        


    @future(callout=true)
    public static void uploadFilesInBoxForAll(Set<Id> contentVersionIdSet){
        try {
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            String q;

            q =  'SELECT ' + String.join(BoxAuthUtility.getFieldsOfsObject('ContentVersion'), ',' );
            q += ' FROM ContentVersion WHERE Id IN : contentVersionIdSet';                
            
            contentVersionList = Database.Query(q);
            
            //Box_OAuth2_Cred__c objBoxOAuthSetting = Box_OAuth2_Cred__c.getorgdefaults();
            Box_OAuth__c objBoxOAuthSetting = Box_OAuth__c.getorgdefaults();
            
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
                    
                    query ='SELECT Id, Name FROM Opportunity';
                    query += ' WHERE accountid= \''+recordId+'\'';
                    query +=' ORDER BY createddate DESC LIMIT 1';

                    
                    sObject objLinkedEntity = Database.Query(query);
                    
                    String fileName = objContentVersion.Title.replace('/','');

                    List<String> folderHierarchy = new List<String>();
                    folderHierarchy.add('Statements');
                    folderHierarchy.add('Opportunities');
                    //folderHierarchy.add(String.valueOf(objLinkedEntity.get('Name')).replace('/',''));
                    folderHierarchy.add(String.valueOf(objLinkedEntity.get('Name')));
                    folderHierarchy.add(String.valueOf('Statements').replace('/',''));

                    
                    // parent for file
                    String parentFolder = '0';
                    
                    if(folderHierarchy.size() > 0){
                        for(String folderName : folderHierarchy){
                            parentFolder = BoxAuthUtility.getBoxFolderId(folderName,parentFolder);
                        }
                    }
                   // box__FRUP__c newFolder = new box__FRUP__c();
                    //newFolder.box__Record_ID__c = recordId; //id of the salesforce record
                    //newFolder.box__Folder_ID__c = parentFolder;  //id of the box folder you want on the salesforce record
                    //insert newFolder;
                    //variables for file upload
                    blob uploadContent = objContentVersion.VersionData;
                    
                    // file uploading 
                   
                    blob base64EncodeFile = BoxAuthUtility.base64EncodeFileContentForBox(uploadContent,fileName.trim());
                    String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+parentFolder;
                    String boundary = '----------------------------foo_bar_baz';
                    
                    HttpRequest requestupload = new HttpRequest();
                    requestupload.setBodyAsBlob(base64EncodeFile);
                    requestupload.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                    requestupload.setHeader('Content-Length',String.valueof(requestupload.getBodyAsBlob().size()));
                    //requestupload.setHeader('Authorization', 'Bearer '+objBoxOAuthSetting.Auth_Token__c.trim());
                    String accessToken = authInfo.Auth_Token__c;
                  	requestupload.setHeader('Authorization', 'Bearer '+accessToken.trim());
                    
                    requestupload.setMethod('POST');
                    requestupload.setEndpoint(uploadEndPointURL);
                    requestupload.setTimeout(120000);
                    //Send request to Box
                    
                    Http hpPutUpload = new Http();
                    HttpResponse responseFileUpload;
                    String jsonFileResUpload;
                    system.debug('requestupload >>'+requestupload);
                    Integer statusCode;
                    
                    if(!Test.isRunningTest()) {
                        responseFileUpload = hpPutUpload.send(requestupload);
                        statusCode = responseFileUpload.getStatusCode();
                        
                        if(statusCode == 201){
                            jsonFileResUpload = responseFileUpload.getBody();
                        }
                        else {
                            System.debug('Status Code ->'+String.valueOf(statusCode) + ' - ' + responseFileUpload.getBody());
                        }
                    }
                    else {
                        jsonFileResUpload = '{"name": "Test Image GMEg1WU6r6.png", "id": "id:ZjFvMRv6-XAAAAAAAAApwA"}';
                        statusCode = 201;
                    }
                    
                    if(statusCode == 201) {
                        String fileID;
                        contentDocumentIdSetToDelete.add(objContentVersion.ContentDocumentId);
                        JSONParser parser = JSON.createParser(jsonFileResUpload);
                        while (parser.nextToken() != null) {
                            if(String.Valueof(parser.getCurrentToken()) == 'FIELD_NAME' && String.Valueof(parser.getText()) == 'id'){
                                parser.nextToken();
                                fileID = parser.getText();
                                break;
                            }
                        }
                        
                        String path_lowerFile;
                        if(fileID != null) {
                            BoxAuthUtility.setBoxFilePermissionPublic(fileId);

                        } 
                    }
                }
            }
            if(contentDocumentIdSetToDelete.size()>0){
                List<ContentDocument> contentDocumentList = [select id from ContentDocument where id in :contentDocumentIdSetToDelete];
                System.debug('files to delete from Salesforce: ' + contentDocumentList);
                delete contentDocumentList;
            }
        }  catch(Exception e){
            System.debug('ContentVersionTriggerHandler');
            System.debug('uploadFilesInBoxForAll');
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
        }                        
    }

    @future(callout=true)
    public static void uploadFilesInBoxForAttachment(Set<Id> attachmentIdSet){
        try {
            //Box_OAuth2_Cred__c objBoxOAuthSetting = Box_OAuth2_Cred__c.getorgdefaults();
            Box_OAuth__c objBoxOAuthSetting = Box_OAuth__c.getorgdefaults();

            List<Attachment> attachmentList = new List<Attachment>();
            String q;

            q =  'SELECT ' + String.join(BoxAuthUtility.getFieldsOfsObject('Attachment'), ',' );
            q += ' FROM Attachment WHERE parent.Type = \'dsfs__DocuSign_Status__c\' AND Id IN : attachmentIdSet';                
            
            attachmentList = Database.Query(q);
            
            Set<id> attachmentParentIdSet = new Set<id>();

            for(Attachment objAttachment : attachmentList){
                attachmentParentIdSet.add(objAttachment.ParentId);
            }

            Map<id, dsfs__DocuSign_Status__c> docusignStatusOpportunityMap = new Map<id, dsfs__DocuSign_Status__c>([select id, dsfs__Opportunity__c from dsfs__DocuSign_Status__c where dsfs__Opportunity__c != '' and  id IN : attachmentParentIdSet]);


            Set<id> opportunityIdSet = new Set<Id>();
            for(Id key: docusignStatusOpportunityMap.keyset()){
                opportunityIdSet.add(docusignStatusOpportunityMap.get(key).dsfs__Opportunity__c);
            }

            Map<id, Opportunity> opportunityIdNameMap = new Map<id, Opportunity>([select id, name from Opportunity where id in :opportunityIdSet]);


            for(Attachment objAttachment : attachmentList){
                if(docusignStatusOpportunityMap.get(objAttachment.ParentId) != null) {
                    
                    String fileName = objAttachment.Name.replace('/','');

                    List<String> folderHierarchy = new List<String>();
                    folderHierarchy.add('Statements');
                    folderHierarchy.add('Opportunities');
                    //folderHierarchy.add(opportunityIdNameMap.get(docusignStatusOpportunityMap.get(objAttachment.ParentId).dsfs__Opportunity__c).Name.replace('/',''));
                    folderHierarchy.add(opportunityIdNameMap.get(docusignStatusOpportunityMap.get(objAttachment.ParentId).dsfs__Opportunity__c).Name);
                    folderHierarchy.add(String.valueOf('Statements').replace('/',''));
                    // parent for file
                    String parentFolder = '0';
                    
                    if(folderHierarchy.size() > 0){
                        for(String folderName : folderHierarchy){
                            parentFolder = BoxAuthUtility.getBoxFolderId(folderName,parentFolder);
                        }
                    }

                    Blob uploadContent = objAttachment.Body;
                    
                    // file uploading 
                   
                        Blob base64EncodeFile = BoxAuthUtility.base64EncodeFileContentForBox(uploadContent,fileName.trim());
                        String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+parentFolder;
                        String boundary = '----------------------------foo_bar_baz';

                        HttpRequest requestupload = new HttpRequest();
                        requestupload.setBodyAsBlob(base64EncodeFile);
                        requestupload.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                        requestupload.setHeader('Content-Length',String.valueof(requestupload.getBodyAsBlob().size()));
                        //requestupload.setHeader('Authorization', 'Bearer '+objBoxOAuthSetting.Auth_Token__c.trim());
                        String accessToken = authInfo.Auth_Token__c;
                  		requestupload.setHeader('Authorization', 'Bearer '+accessToken.trim());
                    
                    	requestupload.setMethod('POST');
                        requestupload.setEndpoint(uploadEndPointURL);
                        requestupload.setTimeout(120000);

                        //Send request to Box
                        Http hpPutUpload = new Http();
                        HttpResponse responseFileUpload;
                        String jsonFileResUpload;
                        system.debug('requestupload >>'+requestupload);
                        Integer statusCode;

                        responseFileUpload = hpPutUpload.send(requestupload);
                        statusCode = responseFileUpload.getStatusCode();
                   
                    
                        if(statusCode == 201){
                            jsonFileResUpload = responseFileUpload.getBody();
                        }
                        else {
                            System.debug('Status Code ->'+String.valueOf(statusCode) + ' - ' + responseFileUpload.getBody());
                        }

                    
                        if(statusCode == 201) {
                            String fileID;
                            JSONParser parser = JSON.createParser(jsonFileResUpload);
                            while (parser.nextToken() != null) {
                                if(String.Valueof(parser.getCurrentToken()) == 'FIELD_NAME' && String.Valueof(parser.getText()) == 'id'){
                                    parser.nextToken();
                                    fileID = parser.getText();
                                    break;
                                }
                            }
                            if(fileID != null) {
                                BoxAuthUtility.setBoxFilePermissionPublic(fileId);
                            } 
                        }
                }
            }

        }
        catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            System.debug(e.getLineNumber());
            System.debug(e.getTypeName());
        }                        
    }


    
    // creating refresh function for token
        
     /*   @future(callout=true)
        public static void refreshToken(){
            String refreshToken='';
            //Box_OAuth2_Cred__c storageConfig = Box_OAuth2_Cred__c.getorgdefaults();
            Box_OAuth__c storageConfig = Box_OAuth__c.getorgdefaults();
            if(!Test.isRunningTest()){
                refreshToken = storageConfig.Refresh_Token__c;
            }else{
                refreshToken='bkdfh8w435j2oi9nslnd8fj23o9unfr';   
            }
            
            System.debug(storageConfig + ' ' + refreshToken);
            
            if(String.isBlank(refreshToken)){
                return;
            }

            String tokenuri = 'https://api.box.com/oauth2/token';
            String body = '';
            body += 'client_id='+ APP_KEY;
            body += '&client_secret='+ APP_SECRET;
            body += '&refresh_token='+refreshToken;
            body += '&grant_type=refresh_token';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(tokenuri);
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setMethod('POST');
            req.setbody(body);
            req.setTimeout(60*1000);
            Http h = new Http();
            HttpResponse res;
            res = h.send(req);
            OAuthToken objOAuthToken = (OAuthToken) JSON.deserialize(res.getBody(), OAuthToken.class);
            storageConfig.Auth_Token__c = objOAuthToken.access_token;
            storageConfig.Refresh_Token__c = objOAuthToken.refresh_token;            
            upsert storageConfig;
            System.debug(storageConfig + ' ' + refreshToken);

        }
        class OAuthToken {
            String access_token;
            String refresh_token;
        }*/
   //////////////////////////////
    private class ParentFolder {
        public String id;
        
        public ParentFolder(String id) {
            this.id = id;
        }
    }
    
    private class Folder {
        public String name;
        ParentFolder parent;
        
        public Folder(String name, String parentId) {
            this.name = name;
            this.parent = new ParentFolder(parentId);
        }
    }
}