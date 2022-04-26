public class ContactCopyUtil {
  public static boolean isRecursive = false;

  @future

  public static void copyFrom(set<id> oppids) {

    isRecursive = true;

    List<Opportunity> opps = new List<opportunity>();
    for(Opportunity o:[select id,primary_contact__c,(select id,role,contactid from opportunitycontactroles where isprimary=true) from opportunity where id in :oppids])
      if(o.opportunitycontactroles<>null &&
         o.opportunitycontactroles.size()==1 &&
         o.opportunitycontactroles[0].contactid<>o.primary_contact__c)
        opps.add(new Opportunity(id=o.id,
          primary_contact__c=o.opportunitycontactroles[0].contactid));

    update opps;  }
}