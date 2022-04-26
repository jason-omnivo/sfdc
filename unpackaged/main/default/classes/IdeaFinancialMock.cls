@IsTest
global class IdeaFinancialMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HTTPResponse res = new HTTPResponse();
        // Get token response:
        if(req.getEndpoint().contains('oauth2/token')){
            // I'm using only this field
            res.setBody('{"access_token": "00D63000000860f!ARwAQIqursDJKULIWyyjBCYUNrAIvef3ZHP_2DI.1MlFhg2qJyzz3T4vJB_NxJC.26wYCqxepUboy__ysPjDP_uHBs1QQC7R"}');
            // If needed in the future full request:
//            res.setBody('{"access_token": "00D63000000860f!ARwAQIqursDJKULIWyyjBCYUNrAIvef3ZHP_2DI.1MlFhg2qJyzz3T4vJB_NxJC.26wYCqxepUboy__ysPjDP_uHBs1QQC7R","instance_url": "https://ideafinancial--uatdev.my.salesforce.com","id": "https://test.salesforce.com/id/00D63000000860fEAA/005f4000004DH4wAAG","token_type": "Bearer","issued_at": "1637083524983","signature": "C+2iPKvKeb3dVC7kNDDzKkXu3ceXiUf0YvT+VBIFnb4="}');
            res.setStatusCode(200);
            return res;
        }

        if(req.getEndpoint().endsWith('/sendApplication')){
            res.setBody('{"IsSuccessful" : true,"Status" : "Success","applicationID" : "0066300000GrLzTAAV"}');
            res.setStatusCode(200);
            return res;
        }

        if(req.getEndpoint().endsWith('/getOfferDetails')){
            res.setBody('{"status" : "Application Created","declinedReason" : null,"CheckoutRequirements" : [ ],"applicationType" : "New Applicant","accountManager":{"phone" : null,"name" : "Carlos Martelo","email" : "cmartelo@ideafinancial.com"},"offers":[{"status" : "Pending","id" : "a1S63000001SSYYEA4","details":[{"term" : 18,"productType" : "LOC","paymentFrequency" : "Weekly","originationFee" : null,"offerTier" : "","offerDate" : null,"minFee" : null,"minAmount" : null,"maxRate" : null,"maintenanceFee" : 0.0000,"interestRate" : 20.00,"drawFee" : 2.4900,"amount" : 150000}]},{"status" : "Pending","id" : "a1S63000001SSYdEAO","details":[{"term" : 18,"productType" : "Term","paymentFrequency" : "Weekly","originationFee" : null,"offerTier" : "","offerDate" : null,"minFee" : null,"minAmount" : null,"maxRate" : null,"maintenanceFee" : 0.0000,"interestRate" : 22.00,"drawFee" : 0.0000,"amount" : 150000}]},{"status" : "Pending","id" : "a1S63000001SSYiEAO","details":[{"term" : 18,"productType" : "Term","paymentFrequency" : "Weekly","originationFee" : null,"offerTier" : "","offerDate" : null,"minFee" : null,"minAmount" : null,"maxRate" : null,"maintenanceFee" : 0.0000,"interestRate" : 23.00,"drawFee" : 0.0000,"amount" : 200000}]}]}');
            res.setStatusCode(200);
            return res;
        }

        if(req.getEndpoint().endsWith('/offerAcceptance')){
            res.setBody('{"IsSuccessful" : true,"Results":[{"IsSuccessful" : false,"Error" : "Application stage is invalid","ApplicationId" : "0066300000GrDb3AAF"}]}');
            res.setStatusCode(200);
            return res;
        }

        return null;
    }
}