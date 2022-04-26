public class ScheduleNotificationExtension {
    
    public Opportunity opp {get; set;}  
 	public Scheduled_Notification__c sn {get; set;}
    
    public Boolean succeeded {get; set;} 
   
    public ScheduleNotificationExtension (ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
        this.opp = [SELECT Id, Name, Owner.Name, Owner.Email
                    FROM Opportunity
                    WHERE Id = :this.opp.Id];
        sn = new Scheduled_Notification__c();
    }

    public PageReference notifyTwoWeeks() {
        Date dateToNotify = Date.today().addDays(14);
    	return notify(dateToNotify);
    }
    
    public PageReference notifyOneMonth() {
        Date dateToNotify = Date.today().addMonths(1);
    	return notify(dateToNotify);
    }
    
    public PageReference notify(Date dateToNotify) {
        sn.Opportunity__c = opp.Id;
        sn.Notification_Date__c = dateToNotify;
        insert sn;
        succeeded = true;
    	return null;
    }
    
}