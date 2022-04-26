@IsTest
private class ContentVersionTriggerTest {
    @IsTest
    static void testDocuSignStatus() {

        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        dsfs__DocuSign_Status__c docuSignStatus = TestDataGenerator.createDocuSignStatus(accountList[0], oppList[0]);
        Box_OAuth_Object__c boxOAuthObj = TestDataGenerator.createBoxOAuthObject();
        ContentVersion contentVersion = TestDataGenerator.createContentVersion();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocumentLink = TestDataGenerator.createContentDocumentLink(docuSignStatus.Id, documents[0].Id);
        ContentVersion contentVersion2 = TestDataGenerator.createContentVersion('Test.pdf', documents[0].Id);
    }

    @IsTest
    static void testPersonalCreditReport() {

        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);
        LASERCA__Personal_Credit_Report__c personalCreditReport =
                TestDataGenerator.createPersonalCreditReport(oppList[0]);
        Box_OAuth_Object__c boxOAuthObj = TestDataGenerator.createBoxOAuthObject();
        ContentVersion contentVersion = TestDataGenerator.createContentVersion('Test.pdf');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocumentLink = TestDataGenerator.createContentDocumentLink(personalCreditReport.Id, documents[0].Id);
        ContentVersion contentVersion2 = TestDataGenerator.createContentVersion('Test.pdf', documents[0].Id);
    }

}