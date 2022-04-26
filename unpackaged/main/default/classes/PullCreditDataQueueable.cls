global without sharing class PullCreditDataQueueable implements Queueable,
Database.AllowsCallouts {
    private List<Id> opportunityIdList = new List<Id>();

    public PullCreditDataQueueable(List<Id> opportunityIdList) {
        this.opportunityIdList = opportunityIdList;
    }


    public void execute(QueueableContext context) {

        try {


            Log.add('Upload Credit Data');
            List<String> creditReportLogIdList = new List<String>();
            List<String> oppIdsContainsError = new List<String>();

            List<String> creditReportIdList = new List<String>();

            for (Id opportunityId : opportunityIdList) {
                String creditReportResponse = LASERCA.MappingUtil.processSingleRecord(opportunityId, null, null);
                Log.add('Credit Report Response ' + creditReportResponse);

                if(isValidSalesforceId(creditReportResponse, LASERCA__Personal_Credit_Report__c.class)) {
                    creditReportIdList.add(creditReportResponse);
                } else if (isValidSalesforceId(creditReportResponse, LASERCA__Credit_Report_Log__c.class)) {
                    creditReportLogIdList.add(creditReportResponse);
                    Log.add('creditReportLogIdList ' + creditReportLogIdList);
                    creditReportIdList = getCreditReportIdsByLogIds(creditReportLogIdList, oppIdsContainsError);
                    Log.add('creditReportIdList ' + creditReportIdList);
                } else {
                    oppIdsContainsError.add(opportunityId);
                }

            }

            List<LASERCA__Personal_Credit_Report__c> creditReportList = [
                    SELECT Id, LASERCA__Opportunity__r.Id, LASERCA__Opportunity__r.Account.Id,
                            LASERCA__Opportunity__r.Account.Partner_1_Credit_Score__c, LASERCA__Credit_Score_Experian__c,
                            LASERCA__Credit_Score_Other__c, FICO_Auto_08__c, LASERCA__Experian_Alert_Message__c
                    FROM LASERCA__Personal_Credit_Report__c
                    WHERE Id IN :creditReportIdList
            ];

            Log.add('creditReportList ' + creditReportList);

            List<Account> accountList = new List<Account>();

            for (LASERCA__Personal_Credit_Report__c creditReport : creditReportList) {
                System.debug(creditReport);
                if (creditReport.LASERCA__Opportunity__r != null && creditReport.LASERCA__Opportunity__r.Account != null) {
                    Account account = new Account(Id = creditReport.LASERCA__Opportunity__r.Account.Id);
                    if (String.isNotBlank(creditReport.LASERCA__Credit_Score_Experian__c) && creditReport.LASERCA__Credit_Score_Experian__c.isNumeric()) {
                        account.Partner_1_Credit_Score__c = getMiddleScore(creditReport);
                    } else if(String.isBlank(creditReport.LASERCA__Credit_Score_Experian__c) && String.isNotBlank(creditReport.LASERCA__Experian_Alert_Message__c)) {
                        account.Pull_Credit_Error__c = creditReport.LASERCA__Experian_Alert_Message__c;
                    }
                    accountList.add(account);
                }
            }

            for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIdsContainsError]) {
                Account account = new Account();
                account.Id = opp.AccountId;
                account.Pull_Credit_Error__c = 'Pull Credit Error';
                accountList.add(account);
            }

            Log.add('accountList ' + accountList);

            if (!accountList.isEmpty()) {
                update accountList;
            }
            Log.add('accountList After Update: ' + accountList);

            List<Opportunity> opp2UpdateList = new List<Opportunity>();
            for (Id opportunityId : opportunityIdList) {
                Opportunity opp2Update = new Opportunity();
                opp2Update.Id = opportunityId;
                opp2Update.Pull_Credit_Report__c = false;
                opp2UpdateList.add(opp2Update);
            }

            update opp2UpdateList;
            Log.add('opp2UpdateList: ' + opp2UpdateList);

        } catch(Exception ex) { Log.add(ex); }
        finally {
            Log.insertLog();
        }
    }

    public Decimal getMiddleScore(LASERCA__Personal_Credit_Report__c creditReport) {
        List<Decimal> scoreList = new List<Decimal>();
        if(String.isNotBlank(creditReport.LASERCA__Credit_Score_Experian__c) && creditReport.LASERCA__Credit_Score_Experian__c.isNumeric()) {
            Decimal creditScoreExperian = Decimal.valueOf(creditReport.LASERCA__Credit_Score_Experian__c);
            if(creditScoreExperian > 0) {
                scoreList.add(creditScoreExperian);
            }
        }
        if(String.isNotBlank(creditReport.LASERCA__Credit_Score_Other__c) && creditReport.LASERCA__Credit_Score_Other__c.isNumeric()) {
            Decimal creditScoreOther = Decimal.valueOf(creditReport.LASERCA__Credit_Score_Other__c);
            if(creditScoreOther > 0) {
                scoreList.add(creditScoreOther);
            }
        }
        if(String.isNotBlank(creditReport.FICO_Auto_08__c) && creditReport.FICO_Auto_08__c.isNumeric()) {
            Decimal ficoAuto08 = Decimal.valueOf(creditReport.FICO_Auto_08__c);
            if(ficoAuto08 > 0) {
                scoreList.add(Decimal.valueOf(creditReport.FICO_Auto_08__c));
            }
        }

        scoreList.sort();
        if(scoreList.size() > 1) {
            return scoreList[1];
        } else if(scoreList.size() == 1) {
            return scoreList[0];
        }
        return null;
    }

    public List<String> getCreditReportIdsByLogIds(List<String> creditReportLogIdList, List<String> oppIdsContainsError) {

        List<LASERCA__Credit_Report_Log__c> creditReportLogList = [
                SELECT Id, LASERCA__Personal_Credit_Report__c, LASERCA__Error_Message__c,
                        LASERCA__Opportunity__c, LASERCA__Opportunity__r.AccountId
                FROM LASERCA__Credit_Report_Log__c
                WHERE Id IN :creditReportLogIdList
        ];
        Log.add('creditReportLogList ' + creditReportLogList);

        List<String> creditReportIdList = new List<String>();
        for (LASERCA__Credit_Report_Log__c reportLog : creditReportLogList) {
            if (String.isNotBlank(reportLog.LASERCA__Personal_Credit_Report__c)) {
                creditReportIdList.add(reportLog.LASERCA__Personal_Credit_Report__c);
            } else {
                oppIdsContainsError.add(reportLog.LASERCA__Opportunity__c);
            }
        }
        Log.add('creditReportIdList ' + creditReportIdList);

        return creditReportIdList;

    }

    public Boolean isValidSalesforceId(String sfdcId, System.Type t) {
        try {
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( sfdcId ).matches() ){
                Id id = sfdcId;
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
                return true;
            }
        } catch ( Exception e ){ } return false;
    }

}