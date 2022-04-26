public with sharing class BoxAutoUpdateToken implements Queueable, Database.AllowsCallouts {
	
	private string boxAppName;
	private Box_OAuth_Object__c boxAuth;
	
	public BoxAutoUpdateToken(string boxAppName) {
		this.boxAppName = boxAppName;
	}
	
	public void execute(QueueableContext context) {
		this.boxAuth = [SELECT Id, Name, Auth_Token__c, Auth_Endpoint__c,
										Auth_Token_Expires__c, Refresh_Token__c,
										Refresh_Token_Expires__c, Client_Id__c, Client_Secret__c
										FROM Box_OAuth_Object__c WHERE Name = :this.boxAppName];
		System.debug(this.boxAuth);
		BoxAuthResponse response = boxAuthRequest();
		System.debug(response);
		if(response != null) {
			System.debug('now: ' + DateTime.now());
			this.boxAuth.Auth_Token__c = response.access_token;
			this.boxAuth.Auth_Token_Expires__c = DateTime.now().addSeconds(response.expires_in - 10);
			this.boxAuth.Refresh_Token__c = response.refresh_token;
			this.boxAuth.Refresh_Token_Expires__c = DateTime.now().addDays(60);
			update this.boxAuth;
			System.debug('Update success');
		} else {
			System.debug('Update failed');
		}
										
	}
	
	 private BoxAuthResponse boxAuthRequest() {
	 	
	 	string authPath = 'token';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
	
        req.setMethod('POST');
        req.setEndpoint(this.boxAuth.Auth_Endpoint__c + authPath);
        req.setBody('grant_type=refresh_token&refresh_token=' + this.boxAuth.Refresh_Token__c + '&client_id=' + boxAuth.Client_Id__c + '&client_secret=' + this.boxAuth.Client_Secret__c);

        HttpResponse res = http.send(req);
        String jsonString = res.getBody();
        System.debug('jsonString before replace: ' + jsonString);
        jsonString = jsonString.replace('1.0e+15', '999999999999');
        System.debug('jsonString after replace: ' + jsonString);
        System.debug('res status code:  ' + res.getStatusCode());
        if (res.getStatusCode() > 299) {
            BoxAuthError err = (BoxAuthError)JSON.deserialize(jsonString, BoxAuthError.class);
            System.debug(err);
            return null;
        } else if (jsonString.length() > 0) {
            BoxAuthResponse boxAuthRes = (BoxAuthResponse) System.JSON.deserialize(jsonString, BoxAuthResponse.class);
        	return boxAuthRes;
        } else {
        	return null;
        }
    }
    
}