public without sharing class OcrolusNewBookQueueable implements Queueable, Database.AllowsCallouts {

    List<Opportunity> oppList;

    public OcrolusNewBookQueueable(List<Opportunity> oppList) {
//        this.oppList = oppList;
        this.oppList = [SELECT Id, Name FROM Opportunity WHERE Id IN :oppList];
    }

    public void execute(QueueableContext context) {

        List<Opportunity> oppList2Update = new List<Opportunity>();
        for(Opportunity opp : oppList) {

            OcrolusNewBookBL ocrolusNewBookBL = new OcrolusNewBookBL();
            OcrolusNewBookRequest request = ocrolusNewBookBL.generateForOpp(opp);
            System.debug('request: ' + request);
            OcrolusNewBookCallout ocrolusNewBookCallout = new OcrolusNewBookCallout();
            OcrolusNewBookResponse response = ocrolusNewBookCallout.execute(request);
            System.debug('response: ' + response);
            if(response != null) {
                Opportunity opp2Update = new Opportunity();
                opp2Update.Id = opp.Id;
                ocrolusNewBookBL.updateBookFields(opp2Update, response);
                oppList2Update.add(opp2Update);
            }

        }
        System.debug('oppList2Update');
        System.debug(oppList2Update);
        try {
            update oppList2Update;
        } catch(Exception ex) {
            System.debug('Queueable Not success');
            System.debug(ex);
        }

    }

}