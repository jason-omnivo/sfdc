public with sharing class BoxAuth {

	private static Box_OAuth_Object__c boxAuthObj {
		get {
			if(boxAuthObj == null) {
				 boxAuthObj =
						[SELECT Auth_Endpoint__c, Auth_Token__c,
						Auth_Token_Expires__c, Refresh_Token__c,
						Refresh_Token_Expires__c, Client_Id__c, Client_Secret__c
						FROM Box_OAuth_Object__c
						ORDER BY Auth_Token_Expires__c DESC][0];
			}
			return boxAuthObj;
		}
		private set;
	}
	
    public static oAuthSettings__c oAuthSetting {
        get {
            if (oAuthSetting == null) {
                //oAuthSetting = oAuthSettings__c.getInstance('Box');
                //if (oAuthSetting == null) {
                //    throw new BoxAuthException('No Box OAuth Settings Found');
                //}
                oAuthSetting = new oAuthSettings__c();
                oAuthSetting.AuthEndpoint__c = boxAuthObj.Auth_Endpoint__c;
                oAuthSetting.ClientId__c = boxAuthObj.Client_Id__c;
                oAuthSetting.ClientSecret__c = boxAuthObj.Client_Secret__c;
            }
            return oAuthSetting;
        } 
        private set;
    }

    private static Box_OAuth__c boxOAuth {
        get {
            if (boxOAuth == null) {
                //System.debug('20141103 debug : BoxAuth.boxOAuth' + UserInfo.getUserId() );
                //System.debug('20141103 debug : BoxAuth.boxOAuth' + Box_OAuth__c.getValues(UserInfo.getUserId()) );
                //boxOAuth = Box_OAuth__c.getValues(UserInfo.getUserId());
                //boxOAuth = Box_OAuth__c.getOrgDefaults();
                boxOAuth = new Box_OAuth__c();
            }
				boxOAuth.Auth_Token__c = boxAuthObj.Auth_Token__c;
				boxOAuth.AuthTokenExpires__c = boxAuthObj.Auth_Token_Expires__c;
				boxOAuth.Refresh_Token__c = boxAuthObj.Refresh_Token__c;
				boxOAuth.RefreshTokenExpires__c	= boxAuthObj.Refresh_Token_Expires__c;
            return boxOAuth;
        }
        set;
    }

    public static Box_OAuth__c authInfo {
        get {
            authInfo = boxOAuth;
            if (authInfo == null) {
                throw new BoxAuthException('No Box Auth Token Set');
            }
            if (authInfo.AuthTokenExpires__c < Datetime.now()) {
                if (authInfo.RefreshTokenExpires__c > Datetime.now()) {
                    //refreshToken();
                } else {
                    delete authInfo;
                    throw new BoxAuthException('Box refresh token has expired. Reauthorize with Box.');
                }
            }
            return authInfo;
        }
    }

    // The Code is passed back from Box after the user approves the connection.
    // It will be used to get the auth and refresh tokens.
    private String code {
        get {
            code = System.currentPagereference().getParameters().get('code');
            return code;
        } 
        set;
    }

    // The User ID to set the authorization token on.
    private Id userId {
        get {
            if (userId == null) {
                try {
                    userId = System.currentPagereference().getParameters().get('state');
                } catch (Exception e) {}
                if (userId == null) {
                    userId = UserInfo.getUserId();
                }
            }
            return userId;
        }
        set;
    }
    
    public PageReference checkCode() {
        if (code != null) {
            System.debug(code);
            getToken(code);
            PageReference pr = Page.boxauth;
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }

    public Boolean isAuthorized {
        get {
            if (boxOAuth == null) {
                return false;
            }
            return (boxOAuth.Auth_Token__c != null);
        }
        set;
    }

    public BoxObject2.User currentUser {
        get {
            if (currentUser == null) {
                try{
                    currentUser = BoxAPIv2.getCurrentUser();
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }
                
            }
            System.debug(currentUser);
            return currentUser;
        }
        set;
    }

    public PageReference requestToken() {
        PageReference boxRequest = new PageReference(oAuthSetting.AuthEndpoint__c + 'authorize');
        boxRequest.getParameters().put('response_type', 'code');
        boxRequest.getParameters().put('client_id', oAuthSetting.ClientId__c);
        boxRequest.getParameters().put('state', userId);
        return boxRequest;
    }

    public static void refreshToken() {
        boxAuthRequest('token', 'grant_type=refresh_token&refresh_token=' + boxOAuth.Refresh_Token__c);
    }

    private void getToken(String code) {
        boxAuthRequest('token', 'grant_type=authorization_code&code=' + code);
    }
/*
    public PageReference revokeToken() {
        boxAuthRequest('revoke', 'token=' + boxOAuth.Auth_Token__c);
        if(boxOAuth != null && boxOAuth.Id != null){
            delete boxOAuth;
        }
        boxOAuth = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Token revoked successfully'));
            
        return null;
    }
	*/
    private static void boxAuthRequest(String requestType, String payload) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
	
        System.debug('requestType: ' + requestType);
        System.debug('payload: ' + payload);
        req.setMethod('POST');
        req.setEndpoint(oAuthSetting.AuthEndpoint__c + requestType);
        req.setBody(payload + '&client_id=' + oAuthSetting.ClientId__c + '&client_secret=' + oAuthSetting.ClientSecret__c);

        HttpResponse res = http.send(req);
        String jsonString = res.getBody();
        System.debug('jsonString before replace: ' + jsonString);
        jsonString = jsonString.replace('1.0e+15', '999999999999');
        System.debug('jsonString after replace: ' + jsonString);
        System.debug('res status code:  ' + res.getStatusCode());
        if (res.getStatusCode() > 299) {
            BoxAuthError err = (BoxAuthError)JSON.deserialize(jsonString, BoxAuthError.class);
            //Do not delete the Auth record if there is an error.
            //if (boxOAuth != null) {
            //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Deleting boxOauth record.'));
            //    delete boxOAuth;
            //    //delete Box_OAuth__c.getValues(UserInfo.getUserId());
            //    boxOAuth = null;
            //}
            if(!System.isFuture()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.error_description));
            }
            System.debug(jsonString);
            System.debug(err.error_description);
            //throw new BoxAuthException(err.error_description);
        }

        if (jsonString.length() > 0) {
            BoxAuthResponse boxAuthRes = (BoxAuthResponse) System.JSON.deserialize(jsonString, BoxAuthResponse.class);
            if(boxAuthObj.Auth_Token__c != null){
                boxAuthObj.Auth_Token__c = boxAuthRes.access_token;
                boxAuthObj.Refresh_Token__c = boxAuthRes.refresh_token;
                boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(boxAuthRes.expires_in);
                boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
                update boxAuthObj;
            }
        }
    }

}