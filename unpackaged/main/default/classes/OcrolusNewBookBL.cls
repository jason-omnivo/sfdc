public with sharing class OcrolusNewBookBL {

    public OcrolusNewBookRequest generateForOpp(Opportunity opp) {
        OcrolusNewBookRequest request = new OcrolusNewBookRequest();
        request.name = opp.Name + ' (' + opp.Id + ') - ' + Datetime.now();
        return request;
    }

    public void updateBookFields(Opportunity opp, OcrolusNewBookResponse response) {
        opp.Ocrolus_Book_Name__c = response.response.name;
        opp.Ocrolus_Book_PK__c = response.response.pk;
        opp.Ocrolus_Book_UUID__c = response.response.uuid;
    }

}