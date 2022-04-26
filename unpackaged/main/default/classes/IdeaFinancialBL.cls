public with sharing class IdeaFinancialBL {

    public String oppId { get; set; }
    public String appId { get; set; }
    public String funderId { get; set; }
//    public Boolean tryToGetOffers { get; set; }

    public Account account { get; set; }
    public Opportunity opportunity { get; set; }
    public Submissions__c ideaFinancialSubmission { get; set; }
    public Funder__c ideaFinancialFunder { get; set; }
    public List<Offer__c> offerList { get; set; }
    public Map<String, Offer__c> offerMap { get; set; }

    public IdeaFinancialAPISettings__c settings { get; set; }


    public IdeaFinancialBL(String oppId){

//        settings = [
//                SELECT Id, BrokerId__c, ApiPassword__c, ApiUserId__c,
//                        StagingBrokerId__c, Is_Staging__c
//                FROM IdeaFinancialAPISettings__c LIMIT 1
//        ];
        settings = IdeaFinancialAPISettings__c.getOrgDefaults();

        this.oppId = oppId;
        this.ideaFinancialFunder = [SELECT Id FROM Funder__c WHERE Name='Idea Financial'];
        this.funderId = this.ideaFinancialFunder.Id;

        this.opportunity = [SELECT Id, AccountId, IdeaFinancialApplicationID__c,
                Owner.FirstName, Owner.LastName, Owner.Email, Owner.Phone,
        (SELECT Id, API_Submission_Error__c, API_Submission_Status__c,
                Approved_Date__c, Approval_Numbers__c, Bank_Status__c,
                Declined_Reason__c, Internal_Status__c, Notes_M__c,
                TimeApproved__c, Try_To_Get_Offers__c
        FROM Submissions__r WHERE Funder__c =: this.funderId)
        FROM Opportunity WHERE Id = :oppId];

        this.appId = String.isNotBlank(opportunity.IdeaFinancialApplicationID__c) ? opportunity.IdeaFinancialApplicationID__c : '';
//        this.tryToGetOffers = true;
        this.ideaFinancialSubmission = !this.opportunity.Submissions__r.isEmpty() ? this.opportunity.Submissions__r[0] : null;

        this.account = [SELECT Id, Legal_Name__c, DBA_Name__c, SSN_1__c, Entity_Type__c, Fed_Tax_ID__c,
                Date_Business_Established__c, Legal_Address__c, Residence_Address_1__c, Legal_State__c,
                State_1__c, Legal_City__c, Legal_Zip__c, City_State_Zip_Code_1__c, Zip_1__c, Stated_Gross_Sales__c,
                Full_Name_1__c, Last_Name_1__c, Email__c, Mobile_Phone_1__c, Percent_of_Ownership_1__c,
                Date_of_Birth_1__c, Requested_Amount_of_Funds__c, Use_of_Funds__c
        FROM Account WHERE Id = :opportunity.AccountId];
        this.offerList = new List<Offer__c>();
        this.offerMap = new Map<String, Offer__c>([
                SELECT Id, Status__c, ExternalId__c
                FROM Offer__c
                WHERE Opportunity__c = :oppId AND Funder__c = :funderId
        ]);
    }

    public IdeaFinancialAPI.SendApplicationRequest generateSendAppRequest(Account account){

        IdeaFinancialAPI.SendApplicationRequest request = new IdeaFinancialAPI.SendApplicationRequest();
        request.Header = generateIFHeader(null);
        request.Agent = generateIFAgent();
        request.Business = generateIFBusiness(account);
        request.Owners = generateIFOwnerList(account);
        request.ApplicationData = generateIFApplicationData(account);

        return request;
    }

    public IdeaFinancialAPI.GetOfferDetailsRequest generateGetOfferDetailsRequest(){

        if(String.isBlank(this.appId)){
            String msg = 'No Application Id. Can not ask for Offers without app id.';
            throw new IllegalArgumentException(msg);
        }

        IdeaFinancialAPI.GetOfferDetailsRequest request = new IdeaFinancialAPI.GetOfferDetailsRequest();
        request.Header = generateIFHeader(this.appId);
        request.Agent = generateIFAgent();
        return request;
    }

    public IdeaFinancialAPI.OfferAcceptanceRequest generateOfferAcceptanceRequest(String offerId){

        IdeaFinancialAPI.OfferAcceptanceRequest request = new IdeaFinancialAPI.OfferAcceptanceRequest();
        request.Header = generateIFHeader();
        request.Acceptance = new List<IdeaFinancialAPI.OfferAcceptance>();

        IdeaFinancialAPI.OfferAcceptance offerAcceptance = generateAcceptedOffer(offerId);
        request.Acceptance.add(offerAcceptance);

        return request;
    }

        // public Decimal FinalRate { get; set; } // Must be between offer.interestRate and offer.maxRate.
        // public Decimal FinalFee { get; set; } // Must be between offer.minFee and offer.drawFee.
        // public Decimal FinalAmount { get; set; } // Must be between offer.minAmount and offer.amount.
    private IdeaFinancialAPI.OfferAcceptance generateAcceptedOffer(String offerId) {

        IdeaFinancialAPI.OfferAcceptance offerAcceptance = new IdeaFinancialAPI.OfferAcceptance();
        Offer__c offer = offerMap.get(offerId);
        offerAcceptance.ApplicationId = appId;
//        offerAcceptance.OfferId = offerId;
        offerAcceptance.OfferId = offer.ExternalId__c;
        offerAcceptance.Status = offer.Status__c;
//        offerAcceptance.Reason = ''; // From a list of values
//        offerAcceptance.CompetitorName = ''; // name of the competitor who’s offer was chosen
        if(true){
            offerAcceptance.FinalRate = 0;
            offerAcceptance.FinalFee = 0;
            offerAcceptance.FinalAmount = 0;
        }
        return offerAcceptance;
    }

    public IdeaFinancialAPI.Header generateIFHeader(){

        IdeaFinancialAPI.Header header = new IdeaFinancialAPI.Header();
        header.BrokerId = settings.BrokerId__c;
        if(settings.Is_Staging__c){
            header.BrokerId = settings.StagingBrokerId__c;
        }
        header.ApiUserId = settings.ApiUserId__c;
        header.ApiPassword = settings.ApiPassword__c;

        return header;
    }

    public IdeaFinancialAPI.Header generateIFHeader(String appId){

        IdeaFinancialAPI.Header header = generateIFHeader();
        if(String.isNotBlank(appId)){
            header.ApplicationID = appId;
        } else {
            header.RequestId = ''; // null;
            header.RequestDate = ''; // null;
            header.IsTestLead = true;
        }
        return header;
    }

    // TODO: Hardcoded
    public IdeaFinancialAPI.Agent generateIFAgent(){

        IdeaFinancialAPI.Agent agent = new IdeaFinancialAPI.Agent();
//        agent.FirstName = 'fName';
//        agent.LastName = 'lName';
//        agent.Email = 'email33@gmaill.com';
//        agent.Phone = '0555555555';

        agent.FirstName = this.opportunity.Owner.FirstName;
        agent.LastName = this.opportunity.Owner.LastName;
        agent.Email = this.opportunity.Owner.Email;
        agent.Phone = this.opportunity.Owner.Phone;

        return agent;
    }

    public IdeaFinancialAPI.Business generateIFBusiness(Account account){

        IdeaFinancialAPI.Business business = new IdeaFinancialAPI.Business();
        business.Name = account.Legal_Name__c;
        business.DBA = account.DBA_Name__c;
        business.LegalEntityType = account.Entity_Type__c;
        business.TaxID = String.isNotBlank(account.Fed_Tax_ID__c) ? account.Fed_Tax_ID__c.replaceAll('-', '') : '123456789';
        business.NAICS = '31334'; //  null; TODO:
        business.InceptionDate = account.Date_Business_Established__c;
        business.SelfReportedIndustry = 'General Industry';
        business.Address = generateIFAddress(account, true);
        business.Phone = '0544444444'; //  null; TODO:
        business.SelfReportedCashFlow = generateIFSelfReportedCashFlow(account);
        return business;
    }

    public IdeaFinancialAPI.Address generateIFAddress(Account account, Boolean isBusinessAddress){

        IdeaFinancialAPI.Address address = new IdeaFinancialAPI.Address();
        address.Address1 = isBusinessAddress? account.Legal_Address__c : account.Residence_Address_1__c;
        address.Address2 = null;
        address.State = isBusinessAddress? account.Legal_State__c : account.State_1__c;
        address.City = isBusinessAddress? account.Legal_City__c : account.City_State_Zip_Code_1__c;
        address.Zip = isBusinessAddress? account.Legal_Zip__c : account.Zip_1__c;
        return address;
    }

    public IdeaFinancialAPI.SelfReportedCashFlow generateIFSelfReportedCashFlow(Account account){

        IdeaFinancialAPI.SelfReportedCashFlow cashFlow = new IdeaFinancialAPI.SelfReportedCashFlow();
        cashFlow.AnnualRevenue = account.Stated_Gross_Sales__c.intValue();
        cashFlow.MonthlyAverageBankBalance = 12565.36; // TODO
        cashFlow.MonthlyAverageCreditCardVolume = 2658.54; // TODO
        return cashFlow;
    }

    public List<IdeaFinancialAPI.Owner> generateIFOwnerList(Account account){

        List<IdeaFinancialAPI.Owner> ownerList = new List<IdeaFinancialAPI.Owner>();
        IdeaFinancialAPI.Owner owner = generateIFOwner(account);
        ownerList.add(owner);
        return ownerList;
    }

    public IdeaFinancialAPI.Owner generateIFOwner(Account account){

        IdeaFinancialAPI.Owner owner = new IdeaFinancialAPI.Owner();
        owner.FirstName = account.Full_Name_1__c;
        owner.LastName = account.Last_Name_1__c;
        owner.Email = account.Email__c;
        String mPhone = account.Mobile_Phone_1__c.replaceAll(' ', '');
        mPhone = mPhone.replaceAll('-' , '');
        mPhone = mPhone.replace('(', '');
        mPhone = mPhone.replace(')', '');
        owner.AlternatePhone = mPhone;
        owner.SSN = account.SSN_1__c.replaceAll('-', '');
        owner.FICO = 750; // TODO
        owner.percentageOfOwnership = 40; // TODO // account.Percent_of_Ownership_1__c != null ? account.Percent_of_Ownership_1__c.intValue() : 0;
        owner.DateOfBirth = account.Date_of_Birth_1__c;
        owner.HomeAddress = generateIFAddress(account, false);
        return owner;
    }

    public IdeaFinancialAPI.ApplicationData generateIFApplicationData(Account account){

        IdeaFinancialAPI.ApplicationData data = new IdeaFinancialAPI.ApplicationData();
        data.RequestedLoanAmount = account.Requested_Amount_of_Funds__c != null ? Decimal.valueOf(account.Requested_Amount_of_Funds__c) : 0;
        data.UseOfFunds = 'Personal business loan'; // account.Use_of_Funds__c; //TODO
        data.StatedCreditHistory = 1; // TODO
        data.FilterID = '868836'; // TODO
//        data.StatedCreditHistory = 0;
//        data.FilterID = ''; // reserved, do not send!!
        return data;
    }

    public String getApplicationId(IdeaFinancialAPI.SendApplicationResponse response){

        System.debug('17');
        if(response.Status == 'Success' && String.isNotBlank(response.applicationID)){
            System.debug('18');
            this.appId = response.applicationID;
            System.debug('Application Received ID: ' + appId);
        } else if(response.IsSuccessful == false
                && String.isNotBlank(response.errorCode)
                && String.isNotBlank(response.message)){
            System.debug(response.errorCode + ' ' + response.message);
        }
        return appId;
    }

    public void uploadFiles(String oppId){
        if(ideaFinancialSubmission == null){
            String msg = 'Submission was not found';
            throw new IllegalArgumentException(msg);
        }
        ideaFinancialSubmission.Try_To_Get_Offers__c = true;
        update ideaFinancialSubmission;
        System.debug('Upload Files');
        System.enqueueJob(new IdeaFinancialBL.UploadFiles(oppId));
    }

    public String handleGetOfferDetailsResponse(IdeaFinancialAPI.GetOfferDetailsResponse response){

        System.debug('handleGetOfferDetailsResponse');

        String message = '';
        // In other cases update: ideaFinancialSubmission
        ideaFinancialSubmission = ideaFinancialSubmission != null ? ideaFinancialSubmission :
        [SELECT Id, API_Submission_Error__c, API_Submission_Status__c,
                Approved_Date__c, Approval_Numbers__c, Bank_Status__c, Declined_Reason__c, Internal_Status__c,
                Notes_M__c, TimeApproved__c, Try_To_Get_Offers__c, Funder__c, Opportunity__c
        FROM Submissions__c WHERE Funder__c =: this.funderId AND Opportunity__c = :this.oppId LIMIT 1
        ];
        // In the example Offers the status was 'Application created'
        if(/*response.Status == 'Approved' &&*/ response.Offers != null && !response.Offers.isEmpty()){
            System.debug('There is offers');
            System.debug('Status == Approved');
            System.debug('response.Offers');
            System.debug(response.Offers);

            for(IdeaFinancialAPI.Offer resOffer : response.Offers){
                System.debug('Inside Offer Loop');
                Offer__c offer = new Offer__c();
//                IdeaFinancialAPI.OfferDetail detail = new IdeaFinancialAPI.OfferDetail();
                IdeaFinancialAPI.OfferDetail detail = resOffer.details != null && !resOffer.details.isEmpty() ? resOffer.details[0] : new IdeaFinancialAPI.OfferDetail();
//                detail = resOffer.details[0].productType == 'Term' ? resOffer.details[0] : resOffer.details[0]; // ?
                Decimal numOfPayments = detail.paymentFrequency == 'Monthly' ? detail.term :
                        detail.paymentFrequency == 'Weekly' ? Math.round(detail.term * 30 / 7) :
                        detail.paymentFrequency == 'Bi_Weekly' ? Math.round(detail.term * 30 / 14) : 12;
//                        detail.paymentFrequency == 'Bi_Weekly' ? Math.round(detail.term * 30 / 7) * 2 : 0;
                offer.Opportunity__c = oppId;
                offer.ExternalId__c = resOffer.id;
                offer.Funder__c = funderId;
                // TODO: Maybe I will not get the status from the response and it will be the default
                offer.Status__c = resOffer.status; // 1 status option is not in the SF picklist: 'Expired'
                offer.Amount_Advanced__c = detail.amount;
                offer.Product_Type__c = detail.productType == 'Term' ? 'Term Loan' : 'Line of Credit';
                offer.Type__c = detail.paymentFrequency; // Type in SF is more like frequency
                offer.Term__c = detail.term;
                offer.Number_of_Payments__c = numOfPayments;
                // TODO: Map the returned fields
            //      "originationFee" : null,
            //      "offerTier" : "",
            //      "offerDate" : null,
            //      "minFee" : null,
            //      "minAmount" : null,
            //      "maxRate" : null,
            //      "maintenanceFee" : 0.0000,
            //      "interestRate" : 23.00,
            //      "drawFee" : 0.0000,
                offer.Payback_Amount__c = 20;
//                offer.Payback_Amount__c = resOffer.details[0].maintenanceFee; // Only one field can have value:  Payback Amt OR Rate

                System.debug('Offer: ' + offer);
                offerList.add(offer);
                System.debug(offerList);
//                tryToGetOffers = false;
                message = 'Offers Received';
            }
        System.debug('Message - ' + message);
        System.debug(offerList.size());
            if(!offerList.isEmpty()){
                insert offerList;
                System.debug('offerList');
                System.debug(offerList);
                ideaFinancialSubmission.Try_To_Get_Offers__c = false;
                update ideaFinancialSubmission;
            }
        } else if(response.IsSuccessful == false
                && String.isNotBlank(response.errorCode)
                && String.isNotBlank(response.message)){
            message = response.errorCode + ' ' + response.message;
            System.debug('Got to the else if');
        } else {
            System.debug('Got to the else');
            message = 'Got to the else';
        }
        System.debug('No Offers Yet - ' + response.Status);
        /////////////////////
        // TODO: Make sure update Offers and Submission and opp
//        System.debug(msg);
//        if(msg == 'Offers Received'){
//            System.debug('No Offers - Try again later');
//        } else {
//            System.debug('Offers received - Do not set Schedulable again');
//            //bl.opportunity.Submissions__r[0]. = false;
//            update bl.opportunity;
//            if(bl.offerList != null && !bl.offerList.isEmpty()){
//                update bl.offerList;
//            }
//        }
        ///////////////////
        return message;
    }

    public with sharing class GetOffersForIdeaSubmissions implements Queueable, Database.AllowsCallouts {

        public void execute(QueueableContext context) {

            Datetime dt = Datetime.now().addDays(-14);

            System.debug('Get Offers For Submissions: execute');
            for (Submissions__c submission : [
                    SELECT Id, Name, Opportunity__c
                    FROM Submissions__c
                    WHERE Funder__r.Name = 'Idea Financial'
                    AND Try_To_Get_Offers__c = TRUE
                    AND Opportunity__r.IdeaFinancialApplicationID__c != NULL
                    AND CreatedDate > :dt
            ]) {
                System.debug('Get Offers For Submission: ' + submission.Name);
                System.enqueueJob(new GetOffersQueueable(submission.Opportunity__c));
            }
        }
    }

    public with sharing class OffersManager {

        public void getOffers() {

            Datetime dt = Datetime.now().addDays(-14);

            System.debug('Get Offers For Submissions: execute');
            for (Submissions__c submission : [
                    SELECT Id, Name, Opportunity__c
                    FROM Submissions__c
                    WHERE Funder__r.Name = 'Idea Financial'
                    AND Try_To_Get_Offers__c = TRUE
                    AND Opportunity__r.IdeaFinancialApplicationID__c != NULL
                    AND CreatedDate > :dt
            ]) {
                System.debug('Get Offers For Submission: ' + submission.Name);
                System.enqueueJob(new GetOffersQueueable(submission.Opportunity__c));
            }
        }
    }

    public with sharing class GetOffersQueueable implements Queueable, Database.AllowsCallouts {

        IdeaFinancialBL bl { get; set; }
        IdeaFinancialGetOffersCallout callout { get; set; }

        public GetOffersQueueable(String oppId){
            System.debug('Get Offers Queueable ctr');
            this.bl = new IdeaFinancialBL(oppId);
            callout = new IdeaFinancialGetOffersCallout();
        }

        public void execute(QueueableContext context) {

            System.debug('Get Offers Queueable. execute for Opp: ' + bl.oppId);
//            try{
                IdeaFinancialAPI.GetOfferDetailsRequest request = bl.generateGetOfferDetailsRequest();
                IdeaFinancialAPI.GetOfferDetailsResponse response = callout.execute(request);
                String msg = bl.handleGetOfferDetailsResponse(response);
                System.debug('Message: ' + msg);
//            } catch (Exception ex) {
//                System.debug(ex.getMessage());
//            }
        }
    }

    public with sharing class UploadFiles implements Queueable, Database.AllowsCallouts {

        String oppId { get; set; }
        Opportunity opp { get; set; }
        IdeaFinancialUploadFilesCallout callout { get; set; }

        public UploadFiles(String oppId){
            this.oppId = oppId;
            this.callout = new IdeaFinancialUploadFilesCallout();
            for(Opportunity opportunity : [
                    SELECT Id, IdeaFinancialFileUploaded__c, IdeaFinancialFileUploadMessage__c
                    FROM Opportunity
                    WHERE Id = :oppId LIMIT 1
            ]){
                opp = opportunity;
            }
        }

        public void execute(QueueableContext context) {

            System.debug('IdeaFinancialUploadFiles - Queueable - execute');
            try{
                HttpResponse res = callout.execute(oppId);
                if(opp != null){
                    opp.IdeaFinancialFileUploadMessage__c = res.getBody();
    //                if(res.getStatusCode() == 200)
                    if(res.getBody() == 'Process Succeeded'){
                        opp.IdeaFinancialFileUploaded__c = true;
                    }
                    update opp;
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
    }
}

//public void setScheduleJob2GetOffers(Integer minutes2add) {
//        System.debug('Submit_Funder_Using_Internal_API__c Step 4.1: Set Schedulable called');
//        // Time Setting:
//        Datetime now = Datetime.now();
//        Integer minutes = now.minute() + minutes2add;
//        Integer hours = minutes <= 59 ? now.hour() : now.hour() + 1; // Make sure there is not an error above 12 or 24
//        minutes = (now.minute() + minutes2add) <= 59 ? minutes : (minutes - 59);
//        String hour = String.valueOf(hours);
//        String minute = String.valueOf(minutes);
//        String second = String.valueOf(now.second());
//        String scheduleTime = second + ' ' + minute + ' ' + hour + ' * * ?';
//        System.debug('scheduleTime: ' + scheduleTime);
//
//        String jobName = 'Get Offers ' + now;
////        System.schedule(jobName , scheduleTime, new IdeaFinancialGetOffersSchedulable(this));
//        System.debug('Submit_Funder_Using_Internal_API__c Step 4.1: Schedule Job Has Been Set: ' + jobName);
//    }