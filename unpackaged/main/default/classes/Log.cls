public without sharing class Log {

    private static Log__c log = new Log__c(Message__c = '');

    public static void add(String message) {
        add(LoggingLevel.DEBUG, message);
    }

    public static void add(LoggingLevel logLevel, String message) {
        log.Message__c += logLevel + ' | ' + message + '\r\n';
        System.debug(logLevel, message);
        if(logLevel == LoggingLevel.ERROR)
            log.Is_Contains_Error__c = true;
    }

    public static void add(Map<String, String> objMap) {
        String message = '';
        for(String key : objMap.keySet()) {
            message += key + '= ' + objMap.get(key) + '\n';
        }
        add(message);
    }

    public static void add(List<String> errorMessageList) {
        for(String message : errorMessageList) {
            add(LoggingLevel.ERROR, message);
        }
    }

    public static void add(Exception ex) {
        String errorMessage = ex.getMessage() + '\r\n';
        errorMessage += ex.getStackTraceString();
        add(LoggingLevel.ERROR, errorMessage);
    }

    public static void insertLog() {
        insert log;
        log = new Log__c(Message__c = '');
    }

//    public static void add(List<Database.Error> errorList) {
//        for(Database.Error err : errorList) {
//            add(err);
//        }
//    }
//
//    public static void add(Database.Error err) {
//        String errorMessage = err.getStatusCode() + ': ' + err.getMessage() + '\r\n';
//        errorMessage += 'Fields : ' + err.getFields();
//        add(LoggingLevel.ERROR, errorMessage);
//    }
//
//    public static void setRelatedRecord(String recordName, String recordId) {
//        log.Related_Record_Name__c = recordName;
//        log.Related_Record_Id__c = recordId;
//    }

}