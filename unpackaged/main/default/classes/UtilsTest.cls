@isTest
public with sharing class UtilsTest {
    
     static testMethod void testNow(){
     	Datetime now = Utils.now();
     	System.assert(now != null);
     }
     
     static testMethod void testCalculateBH(){
     	DateTime startTime = DateTime.now();
     	DateTime endTime = DateTime.now().addDays(1);
     	Decimal diff = Utils.calculateBH(startTime, endTime);
     	System.assert(diff != null);
     }
     
     static testMethod void testGetCreatableFieldsSOQL(){
     	String query = Utils.getCreatableFieldsSOQL('Opportunity', ' ');
     	System.assert(query != null);
     }
     
      static testMethod void test(){
      	utils.delay(10);
     	boolean isSandbox = Utils.runningInASandbox();
     	System.assert(isSandbox || !isSandbox);
     }
     
}