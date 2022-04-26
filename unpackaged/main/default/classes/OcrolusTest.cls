@IsTest
private class OcrolusTest {

    @TestSetup
    static void setup() {
        TestDataGenerator.createBoxOAuthObject();
        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
    }

    @IsTest
    static void testNewBookRequest() {
        OcrolusNewBookRequest request = new OcrolusNewBookRequest();
        request.name = 'Test';
        System.assert(request != null);
    }

    @IsTest
    static void testNewBookResponseSuccess() {

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'OcrolusNewBookResponseSuccess' LIMIT 1];
        String body = sr.Body.toString();

        OcrolusNewBookResponse response = (OcrolusNewBookResponse)JSON.deserialize(body, OcrolusNewBookResponse.class);
        System.assert(response.status != null);
        System.assert(response.message != null);
        System.assert(response.response.name != null);
        System.assert(response.response.created != null);
        System.assert(response.response.pk != null);
        System.assert(response.response.is_public != null);
        System.assert(response.response.owner_email != null);
        System.assert(response.response.uuid != null);

    }

    @IsTest
    static void testNewBookResponseFailed() {

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'OcrolusNewBookResponseFailed' LIMIT 1];
        String body = sr.Body.toString();

        OcrolusNewBookResponse response = (OcrolusNewBookResponse)JSON.deserialize(body, OcrolusNewBookResponse.class);
        System.assert(response.code != null);
        System.debug(response.meta.status);
        System.debug(response.meta.msg);
        System.debug(response.meta.code);

    }

    @IsTest
    static void testOcrolusCalloutSuccess() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('OcrolusNewBookResponseSuccess');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        OcrolusNewBookBL ocrolusNewBookBL = new OcrolusNewBookBL();
        OcrolusNewBookRequest request = ocrolusNewBookBL.generateForOpp(opp);
        OcrolusNewBookCallout ocrolusNewBookCallout = new OcrolusNewBookCallout();

        OcrolusNewBookResponse response = ocrolusNewBookCallout.execute(request);
        System.assert(response != null);

        ocrolusNewBookBL.updateBookFields(opp, response);
        System.assert(opp.Ocrolus_Book_PK__c != null);
        Test.stopTest();

    }

    @IsTest
    static void testOcrolusCalloutFailed() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('OcrolusNewBookResponseFailed');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        OcrolusNewBookBL ocrolusNewBookBL = new OcrolusNewBookBL();
        OcrolusNewBookRequest request = ocrolusNewBookBL.generateForOpp(opp);
        OcrolusNewBookCallout ocrolusNewBookCallout = new OcrolusNewBookCallout();

        OcrolusNewBookResponse response = ocrolusNewBookCallout.execute(request);
        System.assert(response == null);

        Test.stopTest();

    }

    @IsTest
    static void testQueueable() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('OcrolusNewBookResponseSuccess');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        System.enqueueJob(new OcrolusNewBookQueueable(oppList));

        Test.stopTest();

    }

}