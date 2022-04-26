public class UtilityClass {
    
    
    public static void sendErrorMail(String lineNumber,String errorMessage,String stackTrace, String typeName){
        String emailId = System.Label.groupEmail; 
		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { emailId };
        message.subject = 'Error Log :'+datetime.now();
        message.plainTextBody = 'Error Log \n Line No :'+lineNumber+'\nError Message :'+errorMessage+'\nStack Trace :'+stackTrace+'\nType Name :'+typeName;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
}