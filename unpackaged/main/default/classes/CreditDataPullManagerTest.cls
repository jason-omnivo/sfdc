@IsTest
private class CreditDataPullManagerTest {

    @TestSetup
    static void setup() {
        Box_OAuth_Object__c boxAuthObj = TestDataGenerator.createBoxOAuthObject();
    }

    @IsTest
    static void testPullCreditData() {

        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        Opportunity opportunity = opportunityList[0];
        opportunity.Form_Step_4_Application_Sent__c = true;
        update opportunity;

    }

    @IsTest
    static void testIsValidSalesforceId() {

        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        List<String> oppIdList = new List<String>();
        for(Opportunity opp : opportunityList) {
            oppIdList.add(opp.Id);
        }
        PullCreditDataQueueable pullCreditDataQueueable = new PullCreditDataQueueable(oppIdList);
        pullCreditDataQueueable.isValidSalesforceId(oppIdList[0], Opportunity.class);

    }

    @IsTest
    static void testQueueable() {

        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        List<String> oppIdList = new List<String>();
        for(Opportunity opp : opportunityList) {
            oppIdList.add(opp.Id);
        }
        PullCreditDataQueueable pullCreditDataQueueable = new PullCreditDataQueueable(oppIdList);
        pullCreditDataQueueable.isValidSalesforceId(oppIdList[0], Opportunity.class);

    }

    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testSchedule() {

        List<Account> accountList = TestDataGenerator.createAccountList(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        for(Opportunity opp : opportunityList) {
            opp.Form_Step_4_Application_Sent__c = true;
        }
        update opportunityList;

        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new PullCreditSchedule());
        Test.stopTest();

        List<Opportunity> opportunityList_updated = [SELECT Id FROM Opportunity WHERE Pull_Credit_Report__c = FALSE];

    }

    static testmethod void testGetMiddleScore_3_Scores() {

        List<Account> accountList = TestDataGenerator.createAccountListForCreditReport(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        LASERCA__Personal_Credit_Report__c creditReport = TestDataGenerator.createCreditReport(accountList[0], opportunityList[0]);

        List<String> oppIdList = new List<String>();
        for(Opportunity opp : opportunityList) {
            oppIdList.add(opp.Id);
        }
        PullCreditDataQueueable pullCreditDataQueueable = new PullCreditDataQueueable(oppIdList);
        Decimal score = pullCreditDataQueueable.getMiddleScore(creditReport);

        System.assert(score > 0);

    }

    static testmethod void testGetMiddleScore_1_Score() {

        List<Account> accountList = TestDataGenerator.createAccountListForCreditReport(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        LASERCA__Personal_Credit_Report__c creditReport = TestDataGenerator.createCreditReport(accountList[0], opportunityList[0]);
        creditReport.LASERCA__Credit_Score_Other__c = '';
        creditReport.FICO_Auto_08__c = '';

        List<String> oppIdList = new List<String>();
        for(Opportunity opp : opportunityList) {
            oppIdList.add(opp.Id);
        }
        PullCreditDataQueueable pullCreditDataQueueable = new PullCreditDataQueueable(oppIdList);
        Decimal score = pullCreditDataQueueable.getMiddleScore(creditReport);

        System.assert(score > 0);

    }

    static testmethod void testGetMiddleScore_No_Score() {

        List<Account> accountList = TestDataGenerator.createAccountListForCreditReport(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        LASERCA__Personal_Credit_Report__c creditReport = TestDataGenerator.createCreditReport(accountList[0], opportunityList[0]);
        creditReport.LASERCA__Credit_Score_Experian__c = '';
        creditReport.LASERCA__Credit_Score_Other__c = '';
        creditReport.FICO_Auto_08__c = '';

        List<String> oppIdList = new List<String>();
        for(Opportunity opp : opportunityList) {
            oppIdList.add(opp.Id);
        }
        PullCreditDataQueueable pullCreditDataQueueable = new PullCreditDataQueueable(oppIdList);
        Decimal score = pullCreditDataQueueable.getMiddleScore(creditReport);

        System.assertEquals(null, score);

    }

    static testmethod void testGetCreditReportIdsByLogIds() {

        List<Account> accountList = TestDataGenerator.createAccountListForCreditReport(1);
        List<Opportunity> opportunityList = TestDataGenerator.createOpportunityList(1, accountList[0].Id);

        LASERCA__Personal_Credit_Report__c creditReport = TestDataGenerator.createCreditReport(accountList[0], opportunityList[0]);
        LASERCA__Credit_Report_Log__c creditReportLog = TestDataGenerator.createCreditReportLog(creditReport);

        List<String> oppIdList = new List<String>();
        for(Opportunity opp : opportunityList) {
            oppIdList.add(opp.Id);
        }
        PullCreditDataQueueable pullCreditDataQueueable = new PullCreditDataQueueable(oppIdList);

        List<String> creditReportLogIdList = new List<String>{ creditReportLog.Id };
        List<String> oppIdsContainsError = new List<String>();
        List<String> creditReportIds = pullCreditDataQueueable.getCreditReportIdsByLogIds(creditReportLogIdList, oppIdsContainsError);

        System.assert(!creditReportIds.isEmpty());

    }

}