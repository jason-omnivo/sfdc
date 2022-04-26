public with sharing class IdeaFinancialGetTokenCallout {

    public String execute(){

        System.debug('GetTokenCallout');

        Http http = new Http();
        HttpRequest req = new HttpRequest();

        IdeaFinancialAPI.Utils utils = new IdeaFinancialAPI.Utils();
        req.setEndpoint(utils.getTokenUrl());
//        Test url with parameters:
//        req.setEndpoint('https://test.salesforce.com/services/oauth2/token?grant_type=password&client_id=3MVG9GnaLrwG9TQS9I6HiWzTalPKcNvnb4Hbu1e.WajsfYTL81YsYFRLt9ywAxFiCDRNXuMB0RRmtTBsf6O9K&client_secret=E84D6721CDBEFFD6E71F7EFCAE8B094253B8A9809A9C83E2F74C689006BD1E47&username=brokerleads@ideafinancial.com.uatdev&password=leadsAP1');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');

        HttpResponse res = http.send(req);
        System.debug(res);

        System.debug('getStatusCode() == ' + res.getStatusCode());
        System.debug('getBody() == ' + res.getBody());
        try {
            GetTokenResponse response = (GetTokenResponse)JSON.deserialize(res.getBody(), GetTokenResponse.class);
            // TODO: what is the better way. I don't need the Object just the token.
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            System.debug(responseMap.get('access_token'));

            return response.access_token;
        } catch (Exception ex) {
            return 'No Token';
        }
    }

    public class GetTokenResponse {
        public String access_token { get; set; }
    }
}