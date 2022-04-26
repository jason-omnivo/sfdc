@isTest
public class registrationControllerTest {
    
    @isTest(SeeAllData=true)
    static void testMethod1(){

        Lead lead =   new Lead();
        lead.Company = 'JohnMiller';
        lead.FirstName = 'John';
        lead.LastName = 'Mike';
        lead.Status = 'Open';
        lead.Desired_Amount__c = '$50,00,00';
        lead.Financing_Type__c = 'Credit Line' ;
        lead.Phone = '4521478965';
        lead.Email = 'john@gmail.com';
        lead.Annual_Sales__c=5000;
        lead.Use_of_Funds__c = 'Working Capital';
        lead.Annual_Gross_Sales__c = 1;
//        insert lead;
        
       
        registrationController rcObj=new registrationController();
        rcObj.amountNeeded='$1mm to $10mm';
        rcObj.financingType='Credit Line';
        rcObj.companyName='cn';
        rcObj.financType='Sole Proprietor';
        rcObj.firstName='fn';
        rcObj.lastName='ln';
        rcObj.phone='45654656';
        rcObj.cellPhone='5645645';
        rcObj.email='a@aa.com';
        rcObj.annualSales='56';
         rcObj.lead=lead; 
        
        //vars for account tab 2
        rcObj.dbaName='db name';
        rcObj.billingAddress='address';
        rcObj.businessCity='city';
        rcObj.businessState='up';
        rcObj.businessZip='44544';

//        rcObj.propertyType='Owned';
        rcObj.propertyType='Own';
        rcObj.industry='Accounting Services';
        rcObj.useofFunds='Working Capital';
        rcObj.whenFunding='Right away';
        rcObj.federalTaxId='3333333';
        rcObj.businessStartDate=date.today();
        
        //vars for account for tab 3
        rcObj.firstname1='fn';
        rcObj.lastname1='ln';
        rcObj.dateofBirth=system.today();
//        rcObj.socialSecurityNumber='54634546';
        rcObj.socialSecurityNumber='999-99-9999';
        rcObj.homeAddress='dfgdf';
        rcObj.homePropertyType='Own';
        rcObj.siteHostname = '';
        
        
        rcObj.getAmount();
        rcObj.getFinancing();
        rcObj.getUse();
        rcObj.getEntities();
        rcObj.getBusinessType();
        rcObj.getBusinessIndustry();
        rcObj.getTitles();
        rcObj.getHomeType();
        rcObj.getWhenLikeFunding();
        
        
        rcObj.saveData();
        rcObj.doLeadCall();
        rcObj.doConvertLeadCall();
        rcObj.doUpdateAccountCall();
        rcObj.updateAccount(rcObj.lead);
        rcObj.doUpdateAccount(rcObj.lead);
        rcObj.updateAccountSaleVale(rcObj.lead);
    }


    @isTest(SeeAllData=true)
    static void testOppWithoutLead(){

        List<Account> accountList =  TestDataGenerator.createAccountList(1);

        List<Opportunity> oppList = TestDataGenerator.createOpportunityList(accountList);

        // Uses seeAllData
        List<User> users = [SELECT Id, User_External_Id__c FROM User LIMIT 1];
        //List<User> users = TestDataGenerator.createUserList(1);

        PageReference pageRef = Page.ApplicationFormRedirect;
        pageRef.getParameters().put('oid', oppList[0].Id);
        pageRef.getParameters().put('emcsite', '1');
        pageRef.getParameters().put('uid', users[0].User_External_Id__c);
        Test.setCurrentPage(pageRef);

        registrationController rcObj = new registrationController();
        rcObj.amountNeeded='$1mm to $10mm';
        rcObj.financingType='Credit Line';
        rcObj.companyName='cn';
        rcObj.financType='Corporation';
        rcObj.firstName='fn';
        rcObj.lastName='ln';
        rcObj.phone='45654656';
        rcObj.cellPhone='5645645';
        rcObj.email='a@aa.com';
        rcObj.annualSales='56';

        //vars for account tab 2
        rcObj.dbaName='db name';
        rcObj.billingAddress='address';
        rcObj.businessCity='city';
        rcObj.businessState='up';
        rcObj.businessZip='44544';

//        rcObj.propertyType='Owned';
        rcObj.propertyType='Own';
        rcObj.industry='Accounting Services';
        rcObj.useofFunds='Working Capital';
        rcObj.whenFunding='Right away';
        rcObj.federalTaxId='3333333';
        rcObj.businessStartDate=date.today();
        rcObj.siteHostname = '';
        rcObj.doLeadCall();
        rcObj.doConvertLeadCall();
        rcObj.doUpdateAccountCall();
    }

    @isTest(SeeAllData=true)
    static void testExistsLead(){

        List<Lead> leadList = TestDataGenerator.createLead(1);

        PageReference pageRef = Page.ApplicationFormRedirect;
        pageRef.getParameters().put('lid', leadList[0].Id);
        Test.setCurrentPage(pageRef);

        registrationController rcObj = new registrationController();

    }

    @isTest(SeeAllData=true)
    static void testConvertedLead(){

        List<Lead> leadList = TestDataGenerator.createLead(1);

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leadList[0].Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        PageReference pageRef = Page.ApplicationFormRedirect;
        pageRef.getParameters().put('lid', leadList[0].Id);
        Test.setCurrentPage(pageRef);

        registrationController rcObj = new registrationController();

    }

}