@IsTest
public with sharing class LogTest {

    public static testMethod void test() {

        Lead lead = new Lead();
        lead.FirstName = 'Ploni';
        lead.LastName = 'Almoni';
        lead.Company = 'Test Company';
        insert lead;

        Log.add('Lead Created');

        Map<String, String> infoMap = new Map<String, String>();
        infoMap.put('Status', 'OK');
        Log.add(infoMap);

        List<String> errorMessageList = new List<String>();
        errorMessageList.add('Error #1');
        errorMessageList.add('Error #2');
        Log.add(errorMessageList);

        // Test log exception
        try {
            Integer num = Integer.valueOf('NAN');
        } catch(Exception ex) {
            Log.add(ex);
        }

        //Test log Database.Error
//        Lead lead2 = new Lead();
//        lead2.FirstName = 'Ploni';
//        Database.SaveResult saveResult  = Database.insert(lead2, false);
//        Log.add(saveResult.getErrors());
        Log.insertLog();

        List<Log__c> logList = [SELECT Id, Message__c FROM Log__c];
        System.assert(logList[0].Message__c != null && logList[0].Message__c != '');

    }

}