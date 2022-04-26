@isTest
public class TestDataGenerator {
    
    public static List<Account> createAccountList(Integer count) {
    	
    	List<Account> accountList = New List<Account>();
    	for(integer i = 0; i < count; i++){
            accountList.add(New Account(Name = 'Test Account ' + i,
                                               DBA_Name__c = 'DBA ' + i,
                                               Industry__c = 'Attorneys',
                                               Industry_Cashio__c = 'Attorneys',
                                               Industry_As_stated_on_application__c = 'Attorneys',
                                               Industry_Type__c = 'Attorneys',
                                               Date_Business_Established__c = Date.today(),
                                               Partner_1_Credit_Score__c  = 700,
                                               Percent_of_Ownership_1__c = .5));
            
        }
        insert accountList;
        
        return accountList;
    	
    }

    public static List<Account> createAccountListForCreditReport(Integer count) {

        List<Account> accountList = New List<Account>();
        for(integer i = 0; i < count; i++){
            accountList.add(New Account(Name = '123123 ' + i,
                    DBA_Name__c = '123123 ' + i,
                    Industry__c = 'Attorneys',
                    Industry_Cashio__c = 'Attorneys',
                    Industry_As_stated_on_application__c = 'Attorneys',
                    Industry_Type__c = 'Attorneys',
                    Date_Business_Established__c = Date.today(),
                    Partner_1_Credit_Score__c  = 700,
                    Full_Name_1__c = 'Nicole',
                    Last_Name_1__c = 'Testcase',
                    Residence_Address_1__c = '8315 Bunker Hill Rd',
                    City_State_Zip_Code_1__c = 'ANTHILL',
                    State_1__c = 'MO',
                    Zip_1__c = '65488',
                    Date_of_Birth_1__c = Date.today().addYears(-15))
            );

        }
        insert accountList;

        return accountList;

    }
    
    public static List<Contact> createContactList(List<Account> accountList) {
    	
    	List<Contact> contactList = New List<Contact>();
        
        for(integer i = 0; i < accountList.size(); i++){
            contactList.add(New Contact(FirstName='Test ' + i,
                                                LastName='LastName ' + i,
                                                AccountId=accountList[i].Id));
        }
        insert contactList;
        
        return contactList;
        
    }
    
    public static List<Opportunity> createOpportunityList(List<Account> accountList) {

    	List<Opportunity> oppList = New List<Opportunity>();
        for(integer i = 0; i < accountList.size(); i++){
            oppList.add(New Opportunity(Name='Test Opp ' + i,
                                                StageName='Application In',
                                                CloseDate=Date.today().addDays(i),
                                                AccountId=accountList[i].Id));
        }
        insert oppList;

        return oppList;

    }

    public static List<Opportunity> createOpportunityList(Integer count, String accountId) {

    	List<Opportunity> oppList = New List<Opportunity>();
        for(integer i = 0; i < count; i++){
            oppList.add(New Opportunity(Name='Test Opp ' + i,
                                                StageName='Application In',
                                                CloseDate=Date.today().addDays(i),
                                                AccountId=accountId));
        }
        insert oppList;

        return oppList;

    }

    public static List<Funder__c> createFunderlist(Integer count) {
    	
    	List<Funder__c> funderList = New List<Funder__c>();
    	for(integer i = 0; i < count; i++){
            funderList.add(New Funder__c(Name='Test Funder ' + i));
        }
        insert(funderList);
        
        return funderList;
        
    }

    // Doesn't work because required fields are missing : TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey
//    public static List<User> createUserList(Integer count){
//
//        List<User> users = New List<User>();
//        for(integer i = 0; i < count; i++){
//            users.add(New User(LastName = 'Test User ' + i,
//                    Alias = 'Ali ' + i,
//                    Email = 'test' + i + '@gmaill.com',
//                    Username = 'MyName' + i + '@gmaill.com',
//                    CommunityNickname = 'MyNickname' + i));
//
//        }
//        insert users;
//
//        return users;
//    }
    
     public static List<Submissions__c> createSubmissionList(List<Opportunity> oppList, List<Funder__c> funderList) {
     	
     	return createSubmissionList(oppList, funderList, 'Approved');
     	
     }
     
    public static List<Submissions__c> createSubmissionList(List<Opportunity> oppList, List<Funder__c> funderList, String bankStatus) {
    	
    	List<Submissions__c> submissionList = New List<Submissions__c>();
        for(integer i = 0; i < oppList.size(); i++){
            submissionList.add(New Submissions__c(
            	Opportunity__c = oppList[i].Id,
            	Funder__c = funderList[i].id,
                Bank_Status__c = bankStatus
            ));
        }
		insert submissionList;
		
		return submissionList;
		
    }

    public static Box_OAuth_Object__c createBoxOAuthObject() {

        Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Auth_Endpoint__c = '';
        boxAuthObj.Auth_Token__c = '1234567890';
        boxAuthObj.Refresh_Token__c = '1234567890';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = '12345';
        boxAuthObj.Client_Secret__c  = '12345';
        insert boxAuthObj;
        return boxAuthObj;

    }

    public static dsfs__DocuSign_Status__c createDocuSignStatus(Account account, Opportunity opp) {

        dsfs__DocuSign_Status__c docuSignStatus = New dsfs__DocuSign_Status__c();
        docuSignStatus.dsfs__DocuSign_Envelope_ID__c = '123';
        docuSignStatus.dsfs__Sender__c = 'test';
        docuSignStatus.dsfs__Sender_Email__c = 'test@test.com';
        docuSignStatus.dsfs__Subject__c = 'test';
        docuSignStatus.dsfs__Envelope_Status__c = 'Completed';
        docuSignStatus.dsfs__Company__c = account.Id;
        docuSignStatus.dsfs__Opportunity__c = opp.Id;

        insert docuSignStatus;

        return docuSignStatus;

    }


    public static ContentVersion createContentVersion(String fileName) {

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Test',
                PathOnClient = fileName,
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );
        insert contentVersion;
        return contentVersion;
    }

    public static ContentVersion createContentVersion() {

        return createContentVersion('Test.jpg');

    }

    public static ContentVersion createContentVersion(String fileName, String contentDocumentId) {

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Test',
                PathOnClient = fileName,
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                ContentDocumentId = contentDocumentId
        );
        insert contentVersion;
        return contentVersion;
    }


    public static ContentDocumentLink createContentDocumentLink(string recordId, string documentId) {

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = documentId;
        cdl.shareType = 'V';
        insert cdl;
        return cdl;
    }

    public static List<Lead> createLead(Integer amount) {

        List<Lead> leadList = new List<Lead>();

        for(Integer i = 0; i < amount; i++) {
            Lead lead = new Lead();
            lead.Company = 'Test';
            lead.FirstName = 'Test';
            lead.LastName = 'Test';
            lead.Email = 'test@test.com';
            leadList.add(lead);
        }

        insert leadList;
        return leadList;

    }

    public static LASERCA__Personal_Credit_Report__c createPersonalCreditReport(Opportunity opportunity) {
        LASERCA__Personal_Credit_Report__c personalCreditReport = new LASERCA__Personal_Credit_Report__c();
        personalCreditReport.LASERCA__Opportunity__c = opportunity.Id;

        insert personalCreditReport;
        return personalCreditReport;
    }

    public static DocuSign_Settings__c createDocuSignSettings() {

        DocuSign_Settings__c docusignSettings = new DocuSign_Settings__c();
        docusignSettings.DocuSign_Lendfully_Powerform_Id__c = '123';
        docusignSettings.DocuSign_Lendfully_URL__c = 'https://test.com';
        docusignSettings.DocuSign_Powerform_Id__c = '1234';
        docusignSettings.DocuSign_URL__c = 'https://test.com';
        docusignSettings.EMC_Host__c = 'https://test1.com';
        docusignSettings.Lendfully_Host__c = 'https://test2.com';
        docusignSettings.Test_EMC__c = false;

        insert docusignSettings;

        return docusignSettings;

    }
//
//    public static Account createAccount() {
//
//        Account account = New Account(Name = 'Test Account ',
//                DBA_Name__c = 'DBA ',
//                Industry__c = 'Attorneys',
//                Industry_Cashio__c = 'Attorneys',
//                Industry_As_stated_on_application__c = 'Attorneys',
//                Industry_Type__c = 'Attorneys',
//                Date_Business_Established__c = Date.today(),
//                Partner_1_Credit_Score__c  = 700,
//                Percent_of_Ownership_1__c = .5);
//
//        insert account;
//        return account;
//    }
//
//    public static Contact createContact(Account account) {
//
//        Contact contact = New Contact(FirstName='Test ',
//                LastName='LastName ',
//                AccountId=account.Id);
//
//        insert contact;
//        return contact;
//    }
//
//    public static Opportunity createOpportunity(Account account) {
//
//        Opportunity opp = New Opportunity(Name='Test Opp ',
//                StageName='Application In',
//                CloseDate=Date.today(),
//                AccountId=account.Id);
//
//        insert opp;
//        return opp;
//
//    }

    public static IdeaFinancialAPISettings__c createIdeaFinancialSettings(){

        IdeaFinancialAPISettings__c settings = new IdeaFinancialAPISettings__c();
        settings.BrokerId__c = '060160';
        settings.ApiUserId__c = 'emcfinancial';
        settings.ApiPassword__c = 'emcfinancial';
        // Token Settings
        settings.ClientId__c = 'abcd';
        settings.ClientSecret__c = 'abcd';
        settings.TokenUserName__c = 'ss@dd.com';
        settings.TokenPassword__c = '1234';
        settings.Is_Staging__c = false;

        insert settings;
        return settings;
    }

    public static User createUser() {
        User user = new User();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        user.Alias = 'standt';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.LocaleSidKey='en_US';
        user.ProfileId = p.Id;
        user.TimeZoneSidKey='America/Los_Angeles';
        user.UserName='s1standarduser1234@testorg.com';
        user.FirstName = 'fName';
        user.LastName = 'lName';
        user.Email = 'email33@gmaill.com';
        user.Phone = '0555555555';
        insert user;
        return user;
    }

    public static Account createAccount(){
        Account account = new Account();
        account.Name = 'Test Account';
        account.Legal_Name__c = 'TestApp';
        account.DBA_Name__c = 'Test444';
        account.SSN_1__c = '555555555';
        account.Entity_Type__c = 'LLC';
        account.Fed_Tax_ID__c = '822545070';
        account.Date_Business_Established__c = Date.valueOf('2004-04-04T00:00:00.000Z');
        account.Legal_Address__c = '44 Test st.';
        account.Residence_Address_1__c = '44 Test st.';
        account.Legal_State__c = 'NY';
        account.State_1__c = 'NY';
        account.Legal_City__c = 'New York';
        account.City_State_Zip_Code_1__c = 'New York';
        account.Legal_Zip__c = '44444';
        account.Zip_1__c = '44444';
        account.Stated_Gross_Sales__c = 444444;
        account.Full_Name_1__c = 'TestFname';
        account.Last_Name_1__c = 'TestLname';
        account.Email__c = '0544444444@gmail.com';
        account.Mobile_Phone_1__c = '0555555555';
        account.Percent_of_Ownership_1__c = 40;
        account.Date_of_Birth_1__c = Date.valueOf('1975-05-05T00:00:00.000Z');
        account.Requested_Amount_of_Funds__c = '20000';
        account.Use_of_Funds__c = 'Personal business loan';

        insert account;
        return account;
    }

    public static Funder__c createIdeaFinancialFunder(){
        Funder__c funder = new Funder__c();
        funder.Name = 'Idea Financial';
        funder.Submit_Using_Internal_API__c = true;
        insert funder;
        return funder;
    }

    public static Opportunity createOpportunity(String accountId, String ownerId) {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'TestOpp';
        opportunity.StageName ='Application In';
        opportunity.CloseDate=Date.today();
        opportunity.AccountId = accountId;
        opportunity.OwnerId = ownerId;
        insert opportunity;
        return opportunity;
    }

    public static Submissions__c createIdeaFinancialSubmission(String oppId, String funderId) {
        Submissions__c submission = new Submissions__c();
        submission.Opportunity__c = oppId;
        submission.Funder__c = funderId;
        submission.Bank_Status__c = 'Underwriting';
        submission.Internal_Status__c = 'Waiting on Answer';
        insert submission;
        return submission;
    }

    public static Offer__c createIdeaFinancialOffer(String oppId, String funderId) {

        Offer__c offer = new Offer__c();
        offer.Opportunity__c = oppId;
        offer.ExternalId__c = '123456789';
        offer.Funder__c = funderId;
        offer.Amount_Advanced__c = 200000;
        offer.Payback_Amount__c = 20;
        offer.Type__c = 'Weekly';
        offer.Term__c = 18;
        offer.Number_of_Payments__c = 75;
        offer.Status__c = 'Pending';
        insert offer;
        return offer;
    }

    public static LASERCA__Personal_Credit_Report__c createCreditReport(Account account, Opportunity opp) {

        LASERCA__Personal_Credit_Report__c creditReport = new LASERCA__Personal_Credit_Report__c();

        if(account != null) {
            creditReport.LASERCA__Account__c = account.Id;
        }

        if(opp != null) {
            creditReport.LASERCA__Opportunity__c = opp.Id;
        }

        creditReport.LASERCA__Credit_Score_Experian__c = '100';
        creditReport.LASERCA__Credit_Score_Other__c = '200';
        creditReport.FICO_Auto_08__c = '300';

        insert creditReport;

        return creditReport;

    }

    public static LASERCA__Credit_Report_Log__c createCreditReportLog(LASERCA__Personal_Credit_Report__c creditReport) {

        LASERCA__Credit_Report_Log__c creditReportLog = new LASERCA__Credit_Report_Log__c();
        creditReportLog.LASERCA__Personal_Credit_Report__c = creditReport.Id;

        insert creditReportLog;
        return  creditReportLog;

    }


}