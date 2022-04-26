public with sharing class BoxAPIv2 {
  private static string endpoint = 'https://www.box.com/api/2.0';

  private static String getBoxResponse(String method, String request) {
  	System.debug('BoxAPIv2.getBoxResponse');
  	System.debug('method: ' + method);
  	System.debug('request: ' + request);
    return getBoxResponse(method, request, null);
  }
 
  private static String getBoxResponse(String method, String request, String payload) {
  	System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 1');
    Http h = new Http();
    System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 2');
    HttpRequest req = new HttpRequest();
    System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 3');
    req.setEndpoint(endpoint + request);
    System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 4');
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);
    req.setMethod(method);
    req.setTimeout(30000);
    if (payload != null) {
      req.setBody(payload);
    }
    System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 5');
    
    String jsonString = '';
    Integer numberOfRetries = 4;
    Integer statusCode = 401;
    while((statusCode == 401 || statusCode == 302) && numberOfRetries > 0) {
    	
	    HttpResponse res = h.send(req); 
		 System.debug('req: ' + req);
	    System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 6');
	    jsonString = res.getBody();
	    // The Box API returns some reserved words. Find and replace them so we can deserialize
	    jsonString = jsonString.replace('"limit":', '"limit_x":');
	    jsonString = jsonString.replace('1.0e+15', '999999999999');
	    System.debug(jsonString);
	    
	    String location = res.getHeader('Location');
		statusCode = res.getStatusCode();
	    
	    System.debug('Location: ' + location);
	    System.debug('Status Code: ' + res.getStatusCode());
		
	    if (statusCode > 299 && statusCode != 401 && statusCode != 302) {
	        error = (BoxObject2.Error)JSON.deserialize(jsonString, BoxObject2.Error.class);
	        throw new BoxException(error.message);
	    }
	    
		numberOfRetries = numberOfRetries - 1;
	    Utils.delay(1000);
    }

    // Now that we are done with callouts, we can update the oauth tokens if they changed.
    // Commented this since we will just handle this in the Bank Finder Controller
    //upsert BoxAuth.authInfo;
    
    return jsonString;
  }
  
  //Matt Kowalski at TechingCrew made this an asynchronous method to avoid DML/Callout conflict
  /*@Future(callout=true)
  public static void upsertAuthInfo(){
    if(BoxAuth.authInfo.Auth_Token__c != null){
        upsert BoxAuth.authInfo;
    }
  }*/
    
 /* public static void upsertAuthInfoSync(){
    //if(BoxAuth.authInfo.Auth_Token__c != null){
    //    upsert BoxAuth.authInfo;
   // }
  }*/

  public static BoxObject2.Error error;
  
  public static BoxObject2.FolderFile getFolder(String folderId, Boolean isTrashed) {
  	System.debug('BoxObject2.getFolder(1,2) - 1');
    String path = '/folders/' + folderId;
    System.debug('BoxObject2.getFolder(1,2) - 2');
    System.debug('path: ' + path);
    if (isTrashed) {
      path = path + '/trash';
    }
    System.debug('BoxObject2.getFolder(1,2) - 3');
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('GET', path), BoxObject2.FolderFile.class);
  }

  public static BoxObject2.FolderFile getFolder(String folderId) {
  	System.debug('BoxObject2.getFolder(1) - 1');
    return getFolder(folderId, false);  
  }
  
  public static FolderItems getFolderItems(String folderId) {
    System.debug('get folder items url: ' + 'https://api.box.com/2.0/folders/' + folderId  + '/items' + '?fields=type,id,etag,name,description,size,item_statuslock');
  	System.debug('1');
  	Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://api.box.com/2.0/folders/' + folderId  + '/items' + '?fields=type,id,etag,name,description,size,item_statuslock');
    System.debug('2');
    String params = '?fields=type,id,file_version,sequence_id,etag,sha1,name,description,size,path_collection,created_at,modified_at,trashed_at,purged_at,content_created_at,content_modified_at,expires_at,created_by,modified_by,owned_by,shared_link,parent,item_status,version_number,comment_count,permissions,tags,lock,extension,is_package,expiring_embed_link,watermark_info,allowed_invitee_roles,is_externally_owned,has_collaborations,metadata';
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);
    System.debug('3');
    req.setTimeout(30000);
	req.setMethod('GET');
    System.debug('4');
    
    
    /*
    HttpResponse res = h.send(req);
    System.debug('5');
    String jsonString = res.getBody();
    System.debug('json: ' + jsonString);
    System.debug('Location: ' + res.getHeader('Location'));
    
    jsonString = jsonString.replace('"limit":', '"limit_x":');
    jsonString = jsonString.replace('1.0e+15', '999999999999');
	jsonString = jsonString.replace('"type":', '"type_Z":');
	
    if (res.getStatusCode() > 299 ) {
        error = (BoxObject2.Error)JSON.deserialize(jsonString, BoxObject2.Error.class);
        throw new BoxException(error.message);
    }*/
	
	
	
	String jsonString = '';
    Integer numberOfRetries = 4;
    Integer statusCode = 401;
    while((statusCode == 401 || statusCode == 302) && numberOfRetries > 0) {
    	
	    HttpResponse res = h.send(req); 
		 System.debug('req: ' + req);
	    System.debug('BoxAPIv2.getBoxResponse(1,2,3) - 6');
	    jsonString = res.getBody();
	    System.debug('json: ' + jsonString);
   	    System.debug('Location: ' + res.getHeader('Location'));
	    // The Box API returns some reserved words. Find and replace them so we can deserialize
	    jsonString = jsonString.replace('"limit":', '"limit_x":');
	    jsonString = jsonString.replace('1.0e+15', '999999999999');
	    System.debug(jsonString);
	    
	    String location = res.getHeader('Location');
		statusCode = res.getStatusCode();
	    
	    System.debug('Location: ' + location);
	    System.debug('Status Code: ' + res.getStatusCode());
		
	    if (statusCode > 299 && statusCode != 401 && statusCode != 302) {
	        error = (BoxObject2.Error)JSON.deserialize(jsonString, BoxObject2.Error.class);
	        throw new BoxException(error.message);
	    }
	    
		numberOfRetries = numberOfRetries - 1;
	    Utils.delay(1000);
    }
    
    return (FolderItems)JSON.deserialize(jsonString, FolderItems.class);
  }

  public static BoxObject2.FolderFile createFolder(String name, String parentId) {
    String payload = '{"name":"' + name + '", "parent": {"id": "' + parentId + '"}}';
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('POST', '/folders', payload), BoxObject2.FolderFile.class);    
  }

  public static void deleteFolder(String folderId) {
    getBoxResponse('DELETE', '/folders/' + folderId + '?recursive=true');
  }
  public static BoxObject2.FolderFile shareFolder(String folderId) {
    String payload = '{"shared_link": {"access": "open"} }';
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('PUT', '/folders/' + folderId, payload), BoxObject2.FolderFile.class);
  }

  public static BoxObject2.FolderFile getFile(String fileId) {
    return (BoxObject2.FolderFile)JSON.deserialize(getBoxResponse('GET', '/file/' + fileId), BoxObject2.FolderFile.class);    
  }

  public static void deleteFile(String fileId) {
    getBoxResponse('DELETE', '/files/' + fileId);
  }
  public static BoxObject2.SearchResult search(String query, String type) {
  	System.debug('BoxAPIv2.search - 1');
    String payload = 'query=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&content_types=name' + '&type=' + type;
    System.debug('payload: ' + payload);
    System.debug('BoxAPIv2.search - 2');
    return (BoxObject2.SearchResult)JSON.deserialize(getBoxResponse('GET', '/search?' + payload, null), BoxObject2.SearchResult.class);
  }

  public static BoxObject2.Collaboration addCollaboration(String folderId, String email, String role) {
    String payload = '{"item": { "id": "' + folderId + '", "type": "folder"}, "accessible_by": { "login": "' + email + '", "type": "user" }, "role": "' + role + '"}';
    return (BoxObject2.Collaboration)JSON.deserialize(getBoxResponse('POST', '/collaborations', payload), BoxObject2.Collaboration.class);
  }

  public static BoxObject2.CollaborationCollection getFolderCollaboration(String folderId) {
    return (BoxObject2.CollaborationCollection)JSON.deserialize(getBoxResponse('GET', '/folders/' + folderId + '/collaborations'), BoxObject2.CollaborationCollection.class); 
  }

  public static BoxObject2.User getCurrentUser() {
    return (BoxObject2.User)JSON.deserialize(getBoxResponse('GET', '/users/me'), BoxObject2.User.class); 
  }

  public static PageReference getFileDownloadLink(String fileId) {
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint + '/files/' + fileId + '/content');
    req.setHeader('Authorization', 'Bearer ' + BoxAuth.authInfo.Auth_Token__c);
    req.setMethod('GET');
    req.setTimeout(30000);

    System.debug(req);

    HttpResponse res = h.send(req);
    PageReference pr;
    // Box returns a redirect to download the file
    if (res.getStatusCode() == 302) {
      pr = new PageReference(res.getHeader('Location'));
    }
    return pr;
  }
}