global class BoxAutoUpdateTokenSchedule implements Schedulable {
    
	private string boxAppName {get; set;}
	public BoxAutoUpdateTokenSchedule(string boxAppName) {
		this.boxAppName = boxAppName;
	}
	
	global void execute(SchedulableContext sc) {
		BoxAutoUpdateToken boxAutoUpdateToken = new BoxAutoUpdateToken(boxAppname);
	 	System.enqueueJob(boxAutoUpdateToken);
	}
	
}