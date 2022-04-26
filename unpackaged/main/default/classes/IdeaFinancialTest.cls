@IsTest
public with sharing class IdeaFinancialTest {

    @testSetup()
    static void setup(){
        IdeaFinancialAPISettings__c settings = TestDataGenerator.createIdeaFinancialSettings();
        User user = TestDataGenerator.createUser();
        Account account = TestDataGenerator.createAccount();
        Opportunity opportunity = TestDataGenerator.createOpportunity(account.Id, user.Id);
        Funder__c funder = TestDataGenerator.createIdeaFinancialFunder();
        settings.Idea_Funder_Id__c = funder.Id;
        update settings;
//        Submissions__c submission = TestDataGenerator.createIdeaFinancialSubmission(opportunity.Id, funder.Id);
        TestDataGenerator.createIdeaFinancialSubmission(opportunity.Id, funder.Id);
//        Box_OAuth_Object__c boxAuthObj = TestDataGenerator.createBoxOAuthObject();
        TestDataGenerator.createBoxOAuthObject();
        Offer__c offer = TestDataGenerator.createIdeaFinancialOffer(opportunity.Id, funder.Id);
    }

    @IsTest
    static void sendAppTest(){
        Opportunity opp = (Opportunity) [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        IdeaFinancialBL bl = new IdeaFinancialBL(opp.Id);
        IdeaFinancialSendAppCallout callout = new IdeaFinancialSendAppCallout();
        IdeaFinancialAPI.SendApplicationRequest request = bl.generateSendAppRequest(bl.account);
        IdeaFinancialAPI.SendApplicationResponse response = callout.execute(request);
        String id = bl.getApplicationId(response);
        Test.stopTest();
    }

    @IsTest
    static void sendAppTest1(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Submissions__c> submissionsList = [SELECT Id, Opportunity__c, Funder__c, Funder__r.Name, Submit_Funder_Using_Internal_API__c FROM Submissions__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        SubmitFunderInternalAPIsManager manager = new SubmitFunderInternalAPIsManager();
    	manager.executeSubmitToFundersCallouts(submissionsList);
        Test.stopTest();
    }


    @IsTest
    static void getOffersTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        IdeaFinancialBL bl = new IdeaFinancialBL(opp.Id);
        bl.appId = '1234';
        IdeaFinancialGetOffersCallout callout = new IdeaFinancialGetOffersCallout();
        IdeaFinancialAPI.GetOfferDetailsRequest request = bl.generateGetOfferDetailsRequest();
        IdeaFinancialAPI.GetOfferDetailsResponse response = callout.execute(request);
        bl.handleGetOfferDetailsResponse(response);
        Test.stopTest();
    }

//    @IsTest
//    static void offerAcceptTest(){
//        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
//        Offer__c offer = [SELECT Id FROM Offer__c LIMIT 1];
//        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
//        IdeaFinancialBL bl = new IdeaFinancialBL(opp.Id);
//        bl.appId = '1234';
//        IdeaFinancialOfferAcceptanceCallout callout = new IdeaFinancialOfferAcceptanceCallout();
//        IdeaFinancialAPI.OfferAcceptanceRequest request = bl.generateOfferAcceptanceRequest(offer.Id);
//        IdeaFinancialAPI.OfferAcceptanceResponse response = callout.execute(request);
//        Test.stopTest();
//    }

    @IsTest
    static void offerTriggerTest(){
        Offer__c offer = [SELECT Id, Status__c, Funder__r.Name FROM Offer__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        offer.Status__c = 'Accepted';
        update offer;
        Test.stopTest();
    }

    @IsTest
    static void scheduleTest() {
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        IdeaFinancialGetOffersSchedulable getOffersSchedulable = new IdeaFinancialGetOffersSchedulable();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched', chron, getOffersSchedulable);
        test.stopTest();
    }

    @IsTest
    static void utilsTest(){
        // After All callouts executed in test methods I don't need this function
        IdeaFinancialAPI.Utils utils = new IdeaFinancialAPI.Utils();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        utils.getAccessToken(); // Needs a Mock Class
        Test.stopTest();
    }

    @IsTest
    static void responseObjectsTest(){

        IdeaFinancialAPI.SendApplicationResponse saResponse = new IdeaFinancialAPI.SendApplicationResponse();
        saResponse.IsSuccessful = true;
        saResponse.PersonalizedUrl = '';
        saResponse.message = '';
        saResponse.errorCode = '';
        saResponse.Status = '';
        saResponse.ContactInformation = new IdeaFinancialAPI.ContactInformation();
        saResponse.ContactInformation.Name = '';
        saResponse.ContactInformation.Email = '';
        saResponse.ContactInformation.WorkPhone = '';
        saResponse.ContactInformation.WorkPhoneExtension = '';
        saResponse.ContactInformation.Fax = '';
        saResponse.Offers = new List<IdeaFinancialAPI.Offer>();
        IdeaFinancialAPI.Offer offer = new IdeaFinancialAPI.Offer();
        saResponse.Offers.add(offer);

        IdeaFinancialAPI.GetOfferDetailsResponse odResponse = new IdeaFinancialAPI.GetOfferDetailsResponse();
        odResponse.IsSuccessful = true;
        odResponse.declinedReason = '';
        odResponse.applicationType = '';
        odResponse.message = '';
        odResponse.errorCode = '';
        odResponse.accountManager = new IdeaFinancialAPI.AccountManager();
        odResponse.accountManager.phone = '';
        odResponse.accountManager.name = '';
        odResponse.accountManager.email = '';
        odResponse.CheckoutRequirements = new List<IdeaFinancialAPI.CheckoutRequirement>();
        IdeaFinancialAPI.CheckoutRequirement cr = new IdeaFinancialAPI.CheckoutRequirement();
        cr.Name = '';
        cr.requirementCompleted = true;
        odResponse.CheckoutRequirements.add(cr);
        IdeaFinancialAPI.OfferAcceptanceResponse oaResponse = new IdeaFinancialAPI.OfferAcceptanceResponse();
        oaResponse.IsSuccessful = true;
        oaResponse.Status = '';
        oaResponse.message = '';
        oaResponse.errorCode = '';
        oaResponse.Results = new List<IdeaFinancialAPI.Result>();
        IdeaFinancialAPI.Result result = new IdeaFinancialAPI.Result();
        result.IsSuccessful = true;
        result.ApplicationId = '';
        oaResponse.Results.add(result);
    }

//    @IsTest
//    static void offerTriggerTest(){
////        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
//        System.debug('1.1');
//        Offer__c offer = [SELECT Id, Opportunity__c FROM Offer__c LIMIT 1];
//        System.debug('1.2');
//        Test.startTest();
//        System.debug('1.3');
////        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
//        offer.Status__c = 'Accepted';
//        System.debug('1.4');
//        update offer;
//        System.debug('1.5');
//        System.enqueueJob(new IdeaFinancialAcceptOffer(offer.Opportunity__c, offer.Id));
//        Test.stopTest();
//        System.debug('1.6');
//    }

    @IsTest
    static void uploadFilesTest(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, new IdeaFinancialMock());
        System.enqueueJob(new IdeaFinancialBL.UploadFiles(opp.Id));
        Test.stopTest();
    }
}