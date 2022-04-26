public with sharing class Utils {
    
    @TestVisible
	private static Datetime now;
	
	static public BusinessHours Bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true];
	
	public static Datetime now() {
	    return now == null ? Datetime.now() : now;
	}
	
	public static decimal calculateBH(DateTime startTime, DateTime endTime) {
		Long diff = BusinessHours.diff(Utils.Bh.Id, startTime, endTime);
		Decimal num = diff / 1000.0 / 60.0 / 60.0;
		Decimal fixedNum = num.setScale(2, RoundingMode.HALF_DOWN);
		return fixedNum;
	}
	
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    public static Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static void delay(Long delayTime) {
        Long start = DateTime.now().getTime();
        while(DateTime.now().getTime()-start < delayTime);
    }
	
}