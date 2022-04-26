@isTest
private class PresentSelectedOffersControllerTest {
    static testmethod void testController(){
        Profile pf = [Select Id from Profile where Name = 'System Administrator'];

        User user = new User();
        user.FirstName = 'Test';
        user.LastName = 'User';
        user.Email = 'testuser@test123456789.com';
        user.CompanyName = 'test.com';
        user.Title = 'Test User';
        user.Username = 'testuser@test123456789.com';
        user.Alias = 'testuser';
        user.CommunityNickname = 'Test User';
        user.TimeZoneSidKey = 'America/Mexico_City';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = pf.Id;
        user.LanguageLocaleKey = 'en_US';
        user.Phone = '072-321-3423';
        insert user;

        Account acc = new Account(Name = 'Test Account',
                                    Percent_of_Ownership_1__c = 10,
                                    Industry__c = 'Technology',
                                    State_1__c = 'NY',
                                    Date_Business_Established__c = Date.newInstance(1992, 08, 26),
                                    Partner_1_Credit_Score__c = 90,
                                    DBA_Name__c = 'sda',
                                    Email__c = 'test@email.com',
                                    Full_Name_1__c = 'Test Full Name',
                                    Last_Name_1__c = 'Test Last Name');
        insert acc;

        ISO__c iso = new ISO__c(name = 'Test ISO',
                               Copy_Merchant_on_Approvals__c = true,
                               Contact_Email__c = 'test@test.com');
        insert ISO;
        
        Opportunity opp = new Opportunity(Name = 'Test Opp',
                                            AccountId = acc.Id,
                                            StageName = 'Prospecting',
                                            CloseDate = System.today().addDays(30),
                                            OwnerId = user.Id,
                                         	ISO__c = ISO.Id,
                                         	Final_Stips__c = 'test stips');
        insert opp;

        Funder__c funder = new Funder__c(Ownership_Percentage_Requirment__c = 9,
                                            Restricted_Industries__c = 'Fashion;',
                                            Restricted_States__c = 'IL;',
                                            Time_in_business__c = 1,
                                            Credit_Score__c = 89,
                                            Active__c = true);
        insert funder;

        Offer__c offer = new Offer__c();
        offer.Amount_Advanced__c = 100000;
        offer.Payback_Amount__c = 10000;
        //offer.Number_of_Payments__c = 10;
        offer.Type__c = 'Daily';
        offer.Term__c = 10;
        offer.Lender_Fees__c = 200;
        offer.Daily_Payment__c = 100;
        offer.PSF_Charged__c = 200;
        offer.Opportunity__c = opp.Id;
        offer.Funder__c = funder.Id;
        offer.Commission__c = 100;
        offer.Position__c = '1st';
        insert offer;
		
        Offer__c offer2 = new Offer__c();
        offer2.Amount_Advanced__c = 100000;
        offer2.Payback_Amount__c = 10000;
        //offer.Number_of_Payments__c = 10;
        offer2.Type__c = 'Weekly';
        offer2.Term__c = 10;
        offer2.Lender_Fees__c = 200;
        offer2.Daily_Payment__c = 100;
        offer2.PSF_Charged__c = 200;
        offer2.Opportunity__c = opp.Id;
        offer2.Funder__c = funder.Id;
        offer2.Commission__c = 100;
        offer2.Position__c = '2nd';
        insert offer2;
        
        
        PageReference pageRef = Page.PresentSelectedOffers;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ids',offer.Id + ',' + offer2.Id);

        PresentSelectedOffersController controller = new PresentSelectedOffersController();
        //controller.offers.add(offer);
        //controller.sendOffersEmail();
        controller.execute();

        controller.validations.add(new PresentSelectedOffersController.ValidationObj(offer, 'String msg'));
        controller.execute();
        List<Offer__c> os = controller.getSelectedOffers();
        List<PresentSelectedOffersController.ValidationObj> vo = controller.getValidations();
        String pp = controller.getParentPage();
        
        pageRef = Page.PresentAndEditSelectedOffers;
        Test.setCurrentPage(pageRef);
        opp.ISO__c = null;
        update opp;
        ApexPages.currentPage().getParameters().put('ids',offer.Id + ',' + offer2.Id);
		ApexPages.currentPage().getParameters().put('isEditPage','true');
        controller = new PresentSelectedOffersController();
		controller.execute();
        controller.sendEditedOffersEmail();
        opp.ISO__c = iso.Id;
        update opp;
		controller = new PresentSelectedOffersController();
		controller.execute();
        controller.emailMsg.cc = 'test@test.com, matt@techingcrew.com';
        controller.sendEditedOffersEmail();
        controller.emailMsg.cc = '';
        controller.sendEditedOffersEmail();
        controller.emailMsg.bcc = 'xxx';
        controller.emailMsg.cc = ',;,';
        controller.sendEditedOffersEmail();
        controller.editEmailSuccess = true;
        Test.setCurrentPage(pageRef);
        controller.execute();
    }
}