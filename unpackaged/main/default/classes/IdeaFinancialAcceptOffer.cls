public with sharing class IdeaFinancialAcceptOffer implements Queueable, Database.AllowsCallouts {

    IdeaFinancialBL bl { get; set; }
    IdeaFinancialOfferAcceptanceCallout callout { get; set; }
    String offerId { get; set; }

    public IdeaFinancialAcceptOffer(String oppId, String offerId){

        System.debug('IdeaFinancialAcceptOffer - Queueable ctr');
        this.offerId = offerId;
        bl = new IdeaFinancialBL(oppId);
        callout = new IdeaFinancialOfferAcceptanceCallout();
    }

    public void execute(QueueableContext context) {

        System.debug('IdeaFinancialAcceptOffer - Queueable - execute');
        try{
            IdeaFinancialAPI.OfferAcceptanceRequest request = bl.generateOfferAcceptanceRequest(offerId);
            IdeaFinancialAPI.OfferAcceptanceResponse response = callout.execute(request);

        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
}