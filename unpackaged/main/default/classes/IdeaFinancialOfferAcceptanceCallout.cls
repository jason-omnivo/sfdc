public with sharing class IdeaFinancialOfferAcceptanceCallout {

    public IdeaFinancialAPI.OfferAcceptanceResponse execute(IdeaFinancialAPI.OfferAcceptanceRequest request){

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        IdeaFinancialAPI.Utils utils = new IdeaFinancialAPI.Utils();

        IdeaFinancialGetTokenCallout callout = new IdeaFinancialGetTokenCallout();
        String token = callout.execute();

        req.setEndpoint(utils.getOfferAcceptanceUrl());
//        req.setEndpoint('callout:IdeaFinancials_test/services/apexrest/api/broker/v3/offerAcceptance');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
//        req.setHeader('Authorization', 'Bearer {!$Credential.Password}');

        System.debug('request: ' + request);
        System.debug(JSON.serialize(request));
        req.setBody(JSON.serialize(request));
//        req.setBody('{"Header": {"BrokerId": "060160","ApiUserId": "emcfinancial","ApiPassword": "emcfinancial"},"Acceptance": [{"ApplicationId":"0066300000GrDb3AAF","OfferId":"a1S63000001SSYYEA4","Status":"Accepted","CompetitorName":""}]}');
        HttpResponse res = http.send(req);
        System.debug(res);

        System.debug('getStatusCode() == ' + res.getStatusCode());
        System.debug('getBody() == ' + res.getBody());

        IdeaFinancialAPI.OfferAcceptanceResponse response = (IdeaFinancialAPI.OfferAcceptanceResponse) Json.deserialize(res.getBody(), IdeaFinancialAPI.OfferAcceptanceResponse.class);
        return response;
    }

}