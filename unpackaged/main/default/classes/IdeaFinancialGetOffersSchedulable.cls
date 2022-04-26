public with sharing class IdeaFinancialGetOffersSchedulable implements Schedulable{

    public void execute(SchedulableContext sc) {
        System.debug('IdeaFinancialGetOffersSchedulable.execute');
//        System.enqueueJob(new IdeaFinancialBL.GetOffersForIdeaSubmissions());
        IdeaFinancialBL.OffersManager manager = new IdeaFinancialBL.OffersManager();
        manager.getOffers();
    }
}