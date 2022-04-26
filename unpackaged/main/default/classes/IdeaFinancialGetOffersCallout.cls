public with sharing class IdeaFinancialGetOffersCallout {

    public IdeaFinancialAPI.GetOfferDetailsResponse execute(IdeaFinancialAPI.GetOfferDetailsRequest request){

        System.debug('IdeaFinancialGetOffersCallout.execute');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        IdeaFinancialAPI.Utils utils = new IdeaFinancialAPI.Utils();

        IdeaFinancialGetTokenCallout callout = new IdeaFinancialGetTokenCallout();
        String token = callout.execute();

        req.setEndpoint(utils.getOffersDetailsUrl());
//        req.setEndpoint('callout:IdeaFinancials_test/services/apexrest/api/broker/v3/getOfferDetails');
//        req.setEndpoint('https://ideafinancial--uatdev.my.salesforce.com/services/apexrest/api/broker/v3/getOfferDetails');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
//        req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
//        req.setHeader('Authorization', 'Bearer 00D63000000860f!ARwAQIqursDJKULIWyyjBCYUNrAIvef3ZHP_2DI.1MlFhg2qJyzz3T4vJB_NxJC.26wYCqxepUboy__ysPjDP_uHBs1QQC7R');

        System.debug('request: ' + request);
        System.debug(JSON.serialize(request));
        req.setBody(JSON.serialize(request));
        // Working request
//        req.setBody('{"Header": {"ApplicationID": "0066300000GrDb3AAF","BrokerId": "060160","ApiUserId": "emcfinancial","ApiPassword": "emcfinancial"},"Agent": {"FirstName": "Jose","LastName": "Blake","Email": "gp@axxissolutions.com"}}');
        HttpResponse res = http.send(req);
        System.debug(res);

        System.debug('getStatusCode() == ' + res.getStatusCode());
        System.debug('getBody() == ' + res.getBody());

        IdeaFinancialAPI.GetOfferDetailsResponse response = (IdeaFinancialAPI.GetOfferDetailsResponse) Json.deserialize(res.getBody(), IdeaFinancialAPI.GetOfferDetailsResponse.class);
        return response;
    }
}