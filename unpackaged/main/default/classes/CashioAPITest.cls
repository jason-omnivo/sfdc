@isTest
private class CashioAPITest {
    
    @isTest static void testCashioAPI() {
        Funder__c funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                                            Restricted_Industries__c = 'Fashion;',
                                            Restricted_States__c = 'IL;',
                                            Time_in_business__c = 1,
                                            Credit_Score__c = 89,
                                            Active__c = true,
                                            Contact_Email__c = 'test@email.com',
                                            Cashio_Id__c = '21',
                                            Logo_URL__c = 'https://s3-us-west-2.amazonaws.com/cashio/lenders/logo_images/000/000/014/thumb/Lender-Logos-Blue-Vine.png?1433268648');
        insert funder;


        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://cs41.salesforce.com/services/apexrest/Cashio/';  
        req.httpMethod = 'POST';


        RestContext.request = req;
        RestContext.response = res;

        String jsonData = '{"utm_source":"test","utm_medium":"test","utm_campaign":"test","test":"test", "submission_id":"12", "action":"create","name":"ryan middlename parker","business_name":"parker plumbing","phone":"234 666 7744","email":"rparker@aol.com","annual_sales":430009,"credit_score":"above 500","state":"nevada","industry":"plumbing","months_in_business":"more than 2","lenders":[{"id":21,"name":"loanme","website":"www.loanme.com"},{"id":25,"name":"finance store","website":"www.financestore.com"},{"id":27,"name":"ondeck capital","website":"www.ondeck.com"}]}';
        RestContext.request.requestBody = Blob.valueOf(jsonData);

        Test.startTest();
        CashioAPI.createLead();
        Test.stopTest();
    }

    @isTest static void testCashioAPI2() {
        Funder__c funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                                            Restricted_Industries__c = 'Fashion;',
                                            Restricted_States__c = 'IL;',
                                            Time_in_business__c = 1,
                                            Credit_Score__c = 89,
                                            Active__c = true,
                                            Contact_Email__c = 'test@email.com',
                                            Cashio_Id__c = '21',
                                            Requires_Manual_Input__c = true,
                                            Funder_Login_URL__c = 'http://loginurl.com',
                                            Funder_Login_Notes__c = 'login notes',
                                            Merchant_App_Url__c = 'http://www.merappurl.com/');
        insert funder;


        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = 'https://cs41.salesforce.com/services/apexrest/Cashio/';  
        req.httpMethod = 'POST';


        RestContext.request = req;
        RestContext.response = res;

        String jsonData = '{"utm_source":"test","utm_medium":"test","utm_campaign":"test","test":"test", "submission_id":"12", "action":"create","name":"Ryan","business_name":"parker plumbing","phone":"234 666 7744","email":"rparker@aol.com","annual_sales":430009,"credit_score":"above 500","state":"nevada","industry":"plumbing","months_in_business":"more than 2","lenders":[{"id":21,"name":"loanme","website":"www.loanme.com"},{"id":25,"name":"finance store","website":"www.financestore.com"},{"id":27,"name":"ondeck capital","website":"www.ondeck.com"}]}';
        RestContext.request.requestBody = Blob.valueOf(jsonData);

        Test.startTest();
        CashioAPI.createLead();
        Test.stopTest();
    }
}