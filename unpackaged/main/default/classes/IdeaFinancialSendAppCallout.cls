public with sharing class IdeaFinancialSendAppCallout {

    public IdeaFinancialAPI.SendApplicationResponse execute(IdeaFinancialAPI.SendApplicationRequest request){

        System.debug('IdeaFinancialGetOffersCallout.execute');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        IdeaFinancialAPI.Utils utils = new IdeaFinancialAPI.Utils();

        IdeaFinancialGetTokenCallout callout = new IdeaFinancialGetTokenCallout();
        String token = callout.execute();

        req.setEndpoint(utils.getSendApplicationUrl());
        req.setTimeout(120000);
//        req.setEndpoint('callout:IdeaFinancials_test/services/apexrest/api/broker/v3/sendApplication');
//        req.setEndpoint('https://ideafinancial--uatdev.my.salesforce.com/services/apexrest/api/broker/v3/sendApplication');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + token);
//        req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
//        req.setHeader('Authorization', 'Bearer 00D63000000860f!ARwAQIqursDJKULIWyyjBCYUNrAIvef3ZHP_2DI.1MlFhg2qJyzz3T4vJB_NxJC.26wYCqxepUboy__ysPjDP_uHBs1QQC7R');

        System.debug('request: ' + request);
        System.debug(JSON.serialize(request));
        req.setBody(JSON.serialize(request));
        // Working request:
//        req.setBody('{"Owners": [{"SSN": "555555555","PercentageOfOwnership": 40,"LastName": "Eizik","HomeAddress": {"Zip": "55555","State": "NY","City": "Brooklyn","Address2": null,"Address1": "55 Shul st."},"FirstName": "Amitay","FICO": 750,"Email": "0544444444@gmail.com","DateOfBirth": "1975-05-05T00:00:00.000Z","AlternatePhone": "0555555555"}],"Header": {"RequestId": "","RequestDate": "","IsTestLead": true,"BrokerId": "060160","ApiUserId": "emcfinancial","ApiPassword": "emcfinancial"},"Business": {"TaxID": "822545070","SelfReportedIndustry": "General Industry","SelfReportedCashFlow": {"MonthlyAverageCreditCardVolume": 2658.54,"MonthlyAverageBankBalance": 12565.36,"AnnualRevenue": 444444},"Phone": "0544444444","Name": "AmitayApp","NAICS": "31334","LegalEntityType": "LLC","InceptionDate": "2004-04-04T00:00:00.000Z","DBA": "Amitay444","Address": {"Zip": "44444","State": "NY","City": "New York","Address2": null,"Address1": "44 Ami st."}},"ApplicationData": {"UseOfFunds": "Personal business loan","StatedCreditHistory": 1,"RequestedLoanAmount": 20000,"FilterID": "868836"},"Agent": {"Phone": "0555555555","LastName": "lName","FirstName": "fName","Email": "email33@gmaill.com"}}');
        HttpResponse res = http.send(req);
        System.debug(res);

        System.debug('getStatusCode() == ' + res.getStatusCode());
        System.debug('getBody() == ' + res.getBody());

        IdeaFinancialAPI.SendApplicationResponse response = (IdeaFinancialAPI.SendApplicationResponse) Json.deserialize(res.getBody(), IdeaFinancialAPI.SendApplicationResponse.class);
        return response;
    }
}