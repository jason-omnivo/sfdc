public with sharing class IdeaFinancialAPI {

    public class SendApplicationRequest{
        public Header Header { get; set; } // required
        public Agent Agent { get; set; } // required
        public Business Business { get; set; } // required
        public List<Owner> Owners { get; set; } // required
        public ApplicationData ApplicationData { get; set; } // required
    }

    public class SendApplicationResponse{
        public Boolean IsSuccessful { get; set; }
        // In case of Success status == 200
        public String applicationID { get; set; }
        public List<Offer> Offers { get; set; } // reserved, do not use
        public ContactInformation ContactInformation { get; set; }
        public String PersonalizedUrl { get; set; } // reserved, do not use
        // In case of Error status == 400 for data mistake OR Error status == 401 for Authentication mistake
        public String message { get; set; } // error description
        public String errorCode { get; set; }
        // This field is not written in the document but came back in a successful response:
        public String Status { get; set; }
    }

    public class GetOfferDetailsRequest {
        public Header Header { get; set; } // required
        public Agent Agent { get; set; } // required
    }

    public class GetOfferDetailsResponse{
        // Was not in the response
        public Boolean IsSuccessful { get; set; }
        // In the Document this list is inside Offer, but in the response I've got it was in the main response Obj.
        public List<CheckoutRequirement> CheckoutRequirements { get; set; } // In the response I've got it came empty.

        // In case of Success status == 200
        public String Status { get; set; }
        public List<Offer> Offers { get; set; } // reserved, do not use
        public String declinedReason { get; set; }
        public String applicationType { get; set; }
        public AccountManager accountManager { get; set; }
        // In case of Error status == 400 for data mistake OR Error status == 401 for Authentication mistake
        public String message { get; set; } // error description
        public String errorCode { get; set; }
    }

    public class OfferAcceptanceRequest {
        public Header Header { get; set; } // required
        public List<OfferAcceptance> Acceptance { get; set; } // required
    }

    public class UploadFilesRequest {
        public String oppId { get; set; } // required
        public Boolean sandbox { get; set; } // required
    }

    public class OfferAcceptanceResponse{
        public Boolean IsSuccessful { get; set; }
        // In case of Success status == 200
        public List<Result> Results { get; set; }
        public String Status { get; set; }
        // In case of Error status == 400 for data mistake OR Error status == 401 for Authentication mistake
        public String message { get; set; } // error description
        public String errorCode { get; set; }
    }

    public class Header {
        public String RequestId { get; set; } // max 30 characters, Id of the request for the reference
        public String RequestDate { get; set; } // date of the request, ISO format: "2018-05-21T18:14:30.9803708Z"
        public String BrokerId { get; set; } // Id of the broker - required
        public String ApiUserId { get; set; } // your API USER ID - required
        public String ApiPassword { get; set; } // your API PASSWORD - required
        public Boolean IsTestLead { get; set; } // indicates test lead
        // For Get Offer Details:
        public String ApplicationID { get; set; } // your API PASSWORD - required
    }

    public class Agent {
        public String FirstName { get; set; } // required
        public String LastName { get; set; } // required
        public String Email { get; set; } // required
        public String Phone { get; set; } // 10 characters
    }

    public class Business {
        public String Name { get; set; } // legal business name - required
        public String DBA { get; set; } // doing business as
        public String LegalEntityType { get; set; } // entity type - required
        public String TaxID { get; set; } // 9 characters, business tax ID - required
        public String Phone { get; set; } // 10 characters, business phone number - required
        public String NAICS { get; set; } // 6 characters, business primary NAICS code - required
        public Datetime InceptionDate { get; set; } // business start date - required
        public String SelfReportedIndustry { get; set; } // always send: "General Industry" - required
        public Address Address { get; set; } // business address - required
        public SelfReportedCashFlow SelfReportedCashFlow { get; set; }
    }

    public class Address {
        public String Address1 { get; set; } // line 1 of address - required
        public String Address2 { get; set; }
        public String City { get; set; } // required
        public String State { get; set; } // 2 letters abbreviation - required
        public String Zip { get; set; } // 10 characters - required
    }

    public class SelfReportedCashFlow {
        public Integer AnnualRevenue { get; set; } // business annual revenue in whole dollars - required
        public Decimal MonthlyAverageBankBalance { get; set; } // business monthly average bank balance
        public Decimal MonthlyAverageCreditCardVolume { get; set; } // business monthly average credit card volume
    }

    public class Owner {
        public String FirstName { get; set; } // required
        public String LastName { get; set; } // required
        public String Email { get; set; } // required
        public Address HomeAddress { get; set; } // required
        public Datetime DateOfBirth { get; set; } // business start date - required
        public String AlternatePhone { get; set; } // 10 characters - required
        public String SSN { get; set; } // 9 characters, owner’s SSN - required
        public Integer FICO { get; set; } // owner’s FICO score
        // Send App req. Only
        public Integer PercentageOfOwnership { get; set; } // between 0 and 100, owner’s ownership percentage - required
    }

    public class ApplicationData {
        public Decimal RequestedLoanAmount { get; set; } // line of credit requested amount - required
        public Integer StatedCreditHistory { get; set; } // values: 1: Excellent (720+) 2: Good (680-719) 3: Fair (640-679) 4: Poor (<640)
        public String FilterID { get; set; } // reserved, do not send!!
        public String UseOfFunds { get; set; } // intended use of funds
    }

    public class AccountManager {
        public String phone { get; set; }
        public String name { get; set; }
        public String email { get; set; }
    }

    public class ContactInformation {
        public String Name { get; set; } // full name
        public String Email { get; set; }
        public String WorkPhone { get; set; }
        public String WorkPhoneExtension { get; set; }
        public String Fax { get; set; }
    }

    public class Offer {
        public String id { get; set; }
        public String status { get; set; }
        public List<OfferDetail> details { get; set; }
        // Was not in the response I've got. I was outside in the response Obj.
//        public List<CheckoutRequirement> checkoutRequirements { get; set; }
        // Maybe redounded
//        public String WorkPhoneExtension { get; set; }
//        public String Fax { get; set; }
    }

    public class OfferDetail {
        public Integer term { get; set; }
        public String productType { get; set; }
        public String paymentFrequency { get; set; } // Weekly, Bi-Weekly, Monthly]
        public Decimal originationFee { get; set; }
        public String offerTier { get; set; }
        public Datetime offerDate { get; set; }
        public Decimal maintenanceFee { get; set; }
        public Decimal interestRate { get; set; }
        public Decimal maxRate { get; set; }
        public Decimal drawFee { get; set; }
        public Decimal minFee { get; set; }
        public Decimal amount { get; set; }
        public Decimal minAmount { get; set; }
    }

    public class CheckoutRequirement {
        public Boolean requirementCompleted { get; set; }
        public String Name { get; set; }
    }

    public class OfferAcceptance {
        //Note: Only send one ‘Accepted’ offer per lead.
        // Do not send ‘Rejected’ status for other offers within the same lead.
        // If no offers are accepted, send ‘Rejected’ status and do not send OfferId. The Lead will be rejected entirely.
        public String ApplicationId { get; set; }
        public String OfferId { get; set; } // required if Status is 'Accepted'
        public String Status { get; set; } // 'Accepted', 'Rejected', 'Expired'
        public String Reason { get; set; } // From a list of values
        public String CompetitorName { get; set; } // name of the competitor who’s offer was chosen
        // only accepted and required for Term Loan product.
        public Decimal FinalRate { get; set; } // Must be between offer.interestRate and offer.maxRate.
        public Decimal FinalFee { get; set; } // Must be between offer.minFee and offer.drawFee.
        public Decimal FinalAmount { get; set; } // Must be between offer.minAmount and offer.amount.
    }

    public class Result {
        public String ApplicationId { get; set; }
        public Boolean IsSuccessful { get; set; }
        public String Error { get; set; } // required if Status is 'Accepted'
    }

    public class Utils {

        public IdeaFinancialAPISettings__c settings { get; set; }
        public Boolean isStaging { get; set; }
        public Boolean isRunningSandbox {
            get {
                if(isRunningSandbox == null)
                    isRunningSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
                return isRunningSandbox;
            }
            set;
        }

        public Utils(){
            settings = IdeaFinancialAPISettings__c.getOrgDefaults();
            isStaging = settings.Is_Staging__c;
        }

        public String getAccessToken(){
            IdeaFinancialGetTokenCallout callout = new IdeaFinancialGetTokenCallout();
            return callout.execute();
        }

        public String getTokenUrl() {
            String url = 'callout:IdeaFinancialToken';
            if(isRunningSandbox) {
                url += '_test'; // The same url for staging
            }
            String clientId = settings.ClientId__c;
            String clientSecret = settings.ClientSecret__c;
            String username = settings.TokenUserName__c;
            String password = settings.TokenPassword__c; // The same for staging

            //TODO: just for Staging
            if(isStaging){
                clientId = settings.StagingClientId__c;
                clientSecret = settings.StagingClientSecret__c;
                username = settings.StagingTokenUserName__c;
            }

            url += '/services/oauth2/token';
            url += '?grant_type=password';
            url += '&client_id='+ clientId;
            url += '&client_secret='+ clientSecret;
            url += '&username=' + username;
            url += '&password=' + password;
            // TODO: Dev Hard coded shall I use Named Credentials or settings?
//            url += '&username=brokerleads@ideafinancial.com.uatdev';
//            url += '&password=leadsAP1';
//            url += '&username={!$Credential.Username}'; //  Has mistake
//            url += '&password={!$Credential.Password}'; //
            return url;
        }

        public String getIdeaFinancialAPIUrl() {
            String namedCredentialsAPIName = 'callout:IdeaFinancials';
            if(isRunningSandbox) {
                namedCredentialsAPIName += '_test';
            }
            if(isStaging){
                namedCredentialsAPIName = namedCredentialsAPIName.replace('_test', '_staging');
            }
            System.debug(namedCredentialsAPIName);
            return namedCredentialsAPIName;
        }

        public String getSendApplicationUrl() {
            String url = getIdeaFinancialAPIUrl();
            url += '/services/apexrest/api/broker/v3/sendApplication';

            System.debug('url');
            System.debug(url);

            return url;
        }

        public String getOffersDetailsUrl() {
            String url = getIdeaFinancialAPIUrl();
            url += '/services/apexrest/api/broker/v3/getOfferDetails';
            return url;
        }

        public String getOfferAcceptanceUrl() {
            String url = getIdeaFinancialAPIUrl();
            url += '/services/apexrest/api/broker/v3/offerAcceptance';
            return url;
        }

        public String getUploadFilesUrl() {
            return 'https://emc-idea-financial.herokuapp.com/upload_files_to_idea_financial/';
        }
    }
}