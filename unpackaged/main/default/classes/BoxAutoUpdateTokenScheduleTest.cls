@isTest
public class BoxAutoUpdateTokenScheduleTest {
    
    public static String CRON_EXP = '0 0 0 18 6 ? 2020';
    public static testMethod void testSchedule() {
    	
    	Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
    	boxAuthObj.Name = 'EMC-SF-1';
    	boxAuthObj.Auth_Endpoint__c = 'https://api.box.com/oauth2/';
        boxAuthObj.Auth_Token__c = '1234567890';
        boxAuthObj.Refresh_Token__c = '1234567890';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(-3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = '12345';
        boxAuthObj.Client_Secret__c  = '12345';
        insert boxAuthObj;
        
       
        Test.startTest();

		Test.setMock(HttpCalloutMock.class, new BoxMockHttpResponse());
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new BoxAutoUpdateTokenSchedule(boxAuthObj.Name));
        
        System.assertEquals('1234567890', boxAuthObj.Auth_Token__c);
		
        Test.stopTest();       
		
    }
    
	public static testMethod void testAuthResponse() {
		
		BoxAuthResponse boxAuthResponse = new BoxAuthResponse();
		boxAuthResponse.access_token = '1234';
		boxAuthResponse.expires_in = 3600;
		boxAuthResponse.restricted_to = new List<string>();
		boxAuthResponse.refresh_token = '1234';
	    boxAuthResponse.token_type = 'Bearer';
	    
	    System.assert(boxAuthResponse != null);
	}
	
	public static testMethod void testAuthError() {
		
		BoxAuthError boxAuthError = new BoxAuthError();
		boxAuthError.error = 'Error';
		boxAuthError.error_description = 'Error Description';

	    System.assert(boxAuthError != null);
	}
	
    public static testMethod void testBoxAuthException() {
		
		try {
			new BoxAuthException();
		} catch(BoxAuthException ex) {		
		    System.assert(ex != null);
		}

	}
    
    
}