/***********************************************************************************************
* Author: Techila Global Services Pvt Ltd.
* Class Name: ApplicationFormFilesController
* Created Date: 15/01/2020
* Description: class used to handle ApplicationForm data accept lead and convert to account and oppertunity
************************************************************************************************/

public without sharing class registrationController {

    public Lead lead { get; set; }
    public Account accountObj { get; set; }
    public Boolean flag { get; set; }
    public Boolean oppWithoutLead { get; set; }

    public String existsOppId { get; set; }
    public String existsAccountId { get; set; }

    //vars for lead tab1
    public String amountNeeded { get; set; }
    public String financingType { get; set; }
    public String companyName { get; set; }
    public String financType { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String phone { get; set; }
    public String cellPhone { get; set; }
    public String email { get; set; }
    public String annualSales { get; set; }

    //vars for account tab 2
    public String dbaName { get; set; }
    public String billingAddress { get; set; }
    public String businessCity { get; set; }
    public String businessState { get; set; }
    public String businessZip { get; set; }
    public String propertyType { get; set; }
    public String industry { get; set; }
    public String useofFunds { get; set; }
    public String whenFunding { get; set; }
    public String federalTaxId { get; set; }
    public Date businessStartDate { get; set; }

    //vars for account for tab 3
    public String firstname1 { get; set; }
    public String lastname1 { get; set; }
    public Date dateofBirth { get; set; }
    public String socialSecurityNumber { get; set; }
    public String homeAddress { get; set; }
    public String homeCity { get; set; }
    public String homeState { get; set; }
    public String homeZip { get; set; }
    public String homePropertyType { get; set; }

    public String convertedAccountId { get; set; }
    public String convertedOppId { get; set; }

    public String docuSignUrlForRedirect { get; set; }
    private string userId { get; set; }

    public String siteHostname { get; set; }
    public Boolean isEmcSite { get; set; }

    public List<SelectOption> stateOptionList { get; set; }

    public registrationController() {
        flag = false;
        lead = new Lead();
        accountObj = new Account();
        convertedAccountId = '';
        oppWithoutLead = false;

        loadStates();
        loadLeadIfExists();
        loadAccountAndOpportunityIfExists();

        string userExternalId = ApexPages.currentPage().getParameters().get('uid');
        for (User user : [SELECT Id FROM User WHERE User_External_Id__c = :userExternalId]) {
            Log.add('User>>> ' + user);
            userId = user.Id;
        }
// Amit
        isEmcSite = false;
        string emcsite = ApexPages.currentPage().getParameters().get('emcsite');
        if(String.isNotBlank(emcsite) && emcsite == '1'){
            isEmcSite = true;
        }
    }
    private void loadStates() {
        stateOptionList = new List<SelectOption>();
        stateOptionList.add(new SelectOption('', ''));
        stateOptionList.add(new SelectOption('AL','Alabama'));
        stateOptionList.add(new SelectOption('AK','Alaska'));
        stateOptionList.add(new SelectOption('AZ','Arizona'));
        stateOptionList.add(new SelectOption('AR','Arkansas'));
        stateOptionList.add(new SelectOption('CA','California'));
        stateOptionList.add(new SelectOption('CO','Colorado'));
        stateOptionList.add(new SelectOption('CT','Connecticut'));
        stateOptionList.add(new SelectOption('DE','Delaware'));
        stateOptionList.add(new SelectOption('DC','District of Columbia'));
        stateOptionList.add(new SelectOption('FL','Florida'));
        stateOptionList.add(new SelectOption('GA','Georgia'));
        stateOptionList.add(new SelectOption('HI','Hawaii'));
        stateOptionList.add(new SelectOption('ID','Idaho'));
        stateOptionList.add(new SelectOption('IL','Illinois'));
        stateOptionList.add(new SelectOption('IN','Indiana'));
        stateOptionList.add(new SelectOption('IA','Iowa'));
        stateOptionList.add(new SelectOption('KS','Kansas'));
        stateOptionList.add(new SelectOption('KY','Kentucky'));
        stateOptionList.add(new SelectOption('LA','Louisiana'));
        stateOptionList.add(new SelectOption('ME','Maine'));
        stateOptionList.add(new SelectOption('MD','Maryland'));
        stateOptionList.add(new SelectOption('MA','Massachusetts'));
        stateOptionList.add(new SelectOption('MI','Michigan'));
        stateOptionList.add(new SelectOption('MN','Minnesota'));
        stateOptionList.add(new SelectOption('MS','Mississippi'));
        stateOptionList.add(new SelectOption('MO','Missouri'));
        stateOptionList.add(new SelectOption('MT','Montana'));
        stateOptionList.add(new SelectOption('NE','Nebraska'));
        stateOptionList.add(new SelectOption('NV','Nevada'));
        stateOptionList.add(new SelectOption('NH','New Hampshire'));
        stateOptionList.add(new SelectOption('NJ','New Jersey'));
        stateOptionList.add(new SelectOption('NM','New Mexico'));
        stateOptionList.add(new SelectOption('NY','New York'));
        stateOptionList.add(new SelectOption('NC','North Carolina'));
        stateOptionList.add(new SelectOption('ND','North Dakota'));
        stateOptionList.add(new SelectOption('OH','Ohio'));
        stateOptionList.add(new SelectOption('OK','Oklahoma'));
        stateOptionList.add(new SelectOption('OR','Oregon'));
        stateOptionList.add(new SelectOption('PA','Pennsylvania'));
        stateOptionList.add(new SelectOption('RI','Rhode Island'));
        stateOptionList.add(new SelectOption('SC','South Carolina'));
        stateOptionList.add(new SelectOption('SD','South Dakota'));
        stateOptionList.add(new SelectOption('TN','Tennessee'));
        stateOptionList.add(new SelectOption('TX','Texas'));
        stateOptionList.add(new SelectOption('UT','Utah'));
        stateOptionList.add(new SelectOption('VT','Vermont'));
        stateOptionList.add(new SelectOption('VA','Virginia'));
        stateOptionList.add(new SelectOption('WA','Washington'));
        stateOptionList.add(new SelectOption('WV','West Virginia'));
        stateOptionList.add(new SelectOption('WI','Wisconsin'));
        stateOptionList.add(new SelectOption('WY','Wyoming'));
    }

    private void loadLeadIfExists() {
        Log.add('Load Lead If Exists');
        string leadId = ApexPages.currentPage().getParameters().get('lid');
        if(String.isNotBlank(leadId)) {
            Log.add('Load exists');
            for (Lead existsLead : [SELECT Id, Funding_Credit_Needed__c, Financing_Type__c, Entity_Type__c, Company, FirstName, IsEmcForm__c,
                    LastName, Phone, Cell_Phone__c, Email, Annual_Gross_Sales__c, ConvertedAccountId, ConvertedOpportunityId
            FROM Lead WHERE Id = :leadId]) {
                Log.add('Existing Lead: ' + existsLead);
                lead = existsLead;
                flag = true;
                amountNeeded = lead.Funding_Credit_Needed__c;
                financingType = lead.Financing_Type__c;
                financType = lead.Entity_Type__c;
                companyName = lead.Company;
                firstName = lead.FirstName;
                lastName = lead.LastName;
                phone = lead.Phone;
//                cellPhone = lead.Cell_Phone__c;
                email = lead.Email;
                annualSales = '' + lead.Annual_Gross_Sales__c;
            }
        }
    }

    private void loadAccountAndOpportunityIfExists() {
        Log.add('Load Account and Opportunity if Exists');
        string oppId = ApexPages.currentPage().getParameters().get('oid');
        if(String.isNotBlank(oppId)) {
            for( Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId]) {
                Log.add('Opportunity Exists: ' + opp.Id);
                Log.add('Account Exists: ' + opp.AccountId);
                oppWithoutLead = true;
                existsOppId = opp.Id;
                existsAccountId = opp.AccountId;
            }
            if(String.isBlank(existsOppId) || String.isBlank(existsAccountId)) {
                Log.add('Opportunity or Account is missing');
                return;
            }
            for(Account account : [SELECT Id, Name, Legal_Name__c, Full_Name_1__c, Last_Name_1__c, Funding_Credit_Needed__c,
                    Financing_Type__c, Entity_Type__c, Phone, Mobile_Phone_1__c,Date_of_Birth_1__c, SSN_1__c,
                    Residence_Address_1__c, Email__c, City_State_Zip_Code_1__c, State_1__c, Zip_1__c, Home_Property_Type__c,
                    Legal_Address__c, Legal_City__c, Legal_State__c, Legal_Zip__c, Leased_Owned_Picklist__c, Use_of_Funds__c,
                    Industry__c, Fed_Tax_ID__c, When_Like_Funding__c, Date_Business_Established__c, DBA_Name__c, Stated_Gross_Sales__c
            FROM Account WHERE Id = :existsAccountId]) {
                Log.add('Account from Opp>>> ' + account);
                accountObj = account;
                convertedAccountId = account.Id;


                annualSales = '$' + account.Stated_Gross_Sales__c;
                companyName = account.Legal_Name__c;
                firstName = account.Full_Name_1__c;
                lastName = account.Last_Name_1__c;
//                amountNeeded = account.Funding_Credit_Needed__c;
//                financingType = account.Financing_Type__c;
                financType = account.Entity_Type__c;
                phone = account.Phone;
                cellPhone = account.Mobile_Phone_1__c;
                email = account.Email__c;

                dbaName = account.DBA_Name__c;
                companyName = account.Legal_Name__c;
                billingAddress = account.Legal_Address__c;
                businessCity = account.Legal_City__c;
                businessState = account.Legal_State__c;
                businessZip = account.Legal_Zip__c;
                propertyType = account.Leased_Owned_Picklist__c;
                useofFunds = account.Use_of_Funds__c;
                industry = account.Industry__c;
                federalTaxId = account.Fed_Tax_ID__c;
                whenFunding = account.When_Like_Funding__c;
//              businessStartDate = account.Date_Business_Established__c;


                firstname1 = account.Full_Name_1__c;
                lastname1 = account.Last_Name_1__c;
//                dateofBirth = account.Date_of_Birth_1__c;
                socialSecurityNumber = account.SSN_1__c;
                homeAddress = account.Residence_Address_1__c;
                homeCity = account.City_State_Zip_Code_1__c;
                homeState = account.State_1__c;
                homeZip = account.Zip_1__c;
                homePropertyType = account.Home_Property_Type__c;
                cellPhone = account.Mobile_Phone_1__c;

            }
        } else if (String.isNotBlank(lead.ConvertedAccountId)) {
            for(Account account : [SELECT Id, Name, Legal_Name__c, Full_Name_1__c, Last_Name_1__c, Funding_Credit_Needed__c,
                    Financing_Type__c, Entity_Type__c, Phone, Mobile_Phone_1__c,Date_of_Birth_1__c, SSN_1__c,
                    Residence_Address_1__c, Email__c, City_State_Zip_Code_1__c, State_1__c, Zip_1__c, Home_Property_Type__c,
                    Legal_Address__c, Legal_City__c, Legal_State__c, Legal_Zip__c, Leased_Owned_Picklist__c, Use_of_Funds__c,
                    Industry__c, Fed_Tax_ID__c, When_Like_Funding__c, Date_Business_Established__c, DBA_Name__c
            FROM Account WHERE Id = :lead.ConvertedAccountId]) {
                Log.add('Account from Lead>>> ' + account);
                accountObj = account;
                convertedAccountId = account.Id;

//                acc.Stated_Gross_Sales__c = d;
//                companyName = account.Legal_Name__c;
//                firstName = account.Full_Name_1__c;
//                lastName = account.Last_Name_1__c;
//                amountNeeded = account.Funding_Credit_Needed__c;
//                financingType = account.Financing_Type__c;
//                financType = account.Entity_Type__c;
//                phone = account.Phone;
//                cellPhone = account.Mobile_Phone_1__c;
//                email = account.Email__c;

                dbaName = account.DBA_Name__c;
                companyName = account.Legal_Name__c;
                billingAddress = account.Legal_Address__c;
                businessCity = account.Legal_City__c;
                businessState = account.Legal_State__c;
                businessZip = account.Legal_Zip__c;
                propertyType = account.Leased_Owned_Picklist__c;
                useofFunds = account.Use_of_Funds__c;
                industry = account.Industry__c;
                federalTaxId = account.Fed_Tax_ID__c;
                whenFunding = account.When_Like_Funding__c;
//                businessStartDate = account.Date_Business_Established__c;


                firstname1 = account.Full_Name_1__c;
                lastname1 = account.Last_Name_1__c;
//                dateofBirth = account.Date_of_Birth_1__c;
                socialSecurityNumber = account.SSN_1__c;
                homeAddress = account.Residence_Address_1__c;
                homeCity = account.City_State_Zip_Code_1__c;
                homeState = account.State_1__c;
                homeZip = account.Zip_1__c;
                homePropertyType = account.Home_Property_Type__c;
                cellPhone = account.Mobile_Phone_1__c;

            }
        }

    }

    //use to fill dropdown on Amount of Funding / Credit Needed
    public List<SelectOption> getAmount() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));

        options.add(new SelectOption('$10k to $50k', '$10k to $50k'));
        options.add(new SelectOption('$50k to $150k', '$50k to $150k'));
        options.add(new SelectOption('$150k to $300k', '$150k to $300k'));
        options.add(new SelectOption('$300k to $600k', '$300k to $600k'));
        options.add(new SelectOption('$600k to $1mm', '$600k to $1mm'));
        options.add(new SelectOption('$1mm to $10mm', '$1mm to $10mm'));
        return options;
    }

    //use to fill dropdown on Financing Type
    public List<SelectOption> getFinancing() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Credit Line', 'Credit Line'));
        options.add(new SelectOption('Term Loan', 'Term Loan'));
        options.add(new SelectOption('Not Sure Yet', 'Not Sure Yet'));
        return options;
    }

    //use to fill  Use of Funds
    public List<SelectOption> getUse() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Working Capital', 'Working Capital'));
        options.add(new SelectOption('Equipment', 'Equipment'));
        options.add(new SelectOption('Inventory', 'Inventory'));
        options.add(new SelectOption('Refinance / Consolidation', 'Refinancing / Consolidation'));
        options.add(new SelectOption('Pay Bills', 'Pay Bills'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }

    //use to fill Type of Entity
    public List<SelectOption> getEntities() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Sole Proprietor', 'Sole Proprietor'));
        options.add(new SelectOption('Corporation', 'Corporation'));
        options.add(new SelectOption('Partnership', 'Partnership'));
        options.add(new SelectOption('LLC', 'LLC'));
        options.add(new SelectOption('Non-Profit', 'Non-Profit'));
        return options;
    }

    //use to fill Type of Entity  Business Industry
    public List<SelectOption> getBusinessType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Own', 'Own'));
        options.add(new SelectOption('Rent', 'Rent'));
        return options;
    }

    //use to fill Type of home type
    public List<SelectOption> getHomeType() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Own', 'Own'));
        options.add(new SelectOption('Rent', 'Rent'));
        return options;
    }

    //use to fill When would you like the Funding / Credit Line? *
    public List<SelectOption> getWhenLikeFunding() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Right away', 'Right away'));
        options.add(new SelectOption('1-2 weeks', '1-2 weeks'));
        options.add(new SelectOption('2-4 weeks', '2-4 weeks'));
        options.add(new SelectOption('Not sure yet', 'Not sure yet'));
        return options;
    }

    //use to fill BusinessIndustry
    public List<SelectOption> getBusinessIndustry() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Advertising & Marketing', 'Advertising & Marketing'));
        options.add(new SelectOption('Agriculture / Farming', 'Agriculture / Farming'));
        options.add(new SelectOption('Automotive Repair & Parts', 'Automotive Repair & Parts'));
        options.add(new SelectOption('Auto Sales', 'Auto Sales'));
        options.add(new SelectOption('Construction (Commercial or Residential)', 'Construction (Commercial or Residential)'));
        options.add(new SelectOption('e-Commerce', 'e-Commerce'));
        options.add(new SelectOption('Education', 'Education'));
        options.add(new SelectOption('Engineering', 'Engineering'));
        options.add(new SelectOption('Financial Services', 'Financial Services'));
        options.add(new SelectOption('Food & Beverage', 'Food & Beverage'));
        options.add(new SelectOption('Health Care', 'Health Care'));
        options.add(new SelectOption('Hospitality', 'Hospitality'));
        options.add(new SelectOption('Insurance', 'Insurance'));
        options.add(new SelectOption('Logistics', 'Logistics'));
        options.add(new SelectOption('Manufacturing', 'Manufacturing'));
        options.add(new SelectOption('Real Estate', 'Real Estate'));
        options.add(new SelectOption('Retail Store', 'Retail Store'));
        options.add(new SelectOption('Technology & Software', 'Technology & Software'));
        options.add(new SelectOption('Telecommunications', 'Telecommunications'));
        options.add(new SelectOption('Transportation (not trucking)', 'Transportation (not trucking)'));
        options.add(new SelectOption('Trucking', 'Trucking'));
        options.add(new SelectOption('Wholesale & Distribution', 'Wholesale & Distribution'));
        options.add(new SelectOption('Other or not listed here', 'Other or not listed here'));
        return options;
    }

    //use to fill Type of user type
    public List<SelectOption> getTitles() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.add(new SelectOption('Owner', 'Owner'));
        options.add(new SelectOption('CEO', 'CEO'));
        options.add(new SelectOption('CFO', 'CFO'));
        options.add(new SelectOption('President', 'President'));
        options.add(new SelectOption('Managing Member', 'Managing Member'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }

    //saveData is Used to create Lead this is run only ones
    public void saveData() {
        Log.add('Save Data called : Creates new Lead');
        flag = true;
        lead.Funding_Credit_Needed__c = amountNeeded;
        lead.Financing_Type__c = financingType;
        //lead.Entity_Type__c = financType;
        lead.Company = companyName;
        lead.FirstName = firstName;
        lead.LastName = lastName;
        lead.Phone = phone;
        //lead.Cell_Phone__c = cellPhone;
        lead.Email = email;
        lead.Form_Step_1__c = true;

        RecordTypeInfo leadLayoutMainRecordTypeInfo = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Lead_Layout_Main');
        if(leadLayoutMainRecordTypeInfo != null) {
            lead.RecordTypeId = leadLayoutMainRecordTypeInfo.getRecordTypeId();
        }

        if (String.isNotBlank(userId))
            lead.OwnerId = userId;
        if (!Test.isRunningTest()) {

            if (string.valueOf(annualSales).Contains('$')) {
                annualSales = annualSales.replace('$', '');
            }
            if (string.valueOf(annualSales).Contains(',')) {
                annualSales = annualSales.replace(',', '');
            }
            Decimal d = Decimal.valueOf(!String.isEmpty(annualSales) ? annualSales : '0');
            d = d.setScale(8, RoundingMode.HALF_EVEN);
            lead.Annual_Gross_Sales__c = d;
        } else {
            lead.Annual_Gross_Sales__c = 0;
        }

        if (DocuSign_Settings__c.getOrgDefaults().Test_EMC__c || (string.isNotBlank(siteHostname) && siteHostname.contains('emcfinancial.com')) || isEmcSite){
            lead.IsEmcForm__c = true;
        }

        Log.add('EMC Form>>> ' + DocuSign_Settings__c.getOrgDefaults().Test_EMC__c);
//        Log.add('EMC Form>>> ' + ApexPages.currentPage().getUrl().contains('emc'));
        Boolean emcSite = String.isNotBlank(siteHostname) && siteHostname.contains('emcfinancial.com');
        Log.add('EMC Form>>> ' + emcSite);
        Log.add('EMC Form>>> ' + isEmcSite);

        Log.add('Lead to Insert>>> ' + lead);

        try {
            system.debug('lead: ' + lead);
            insert lead;
            Log.add('Inserted Lead ID>>> ' + lead.Id);
            system.debug('lead save....');
        } catch (Exception e) {
            Log.add(e);
            system.debug('lead not save....' + e.getMessage());
            UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }

    //Used to update Lead every time user use back button to chnage field value.
    public void updateLead(Lead leadObj) {
        Log.add('Update Lead called');
        Log.add('Existing lead>>> ' + leadObj);
        System.debug('###############Update Lead###############');
        Lead nlead = [select id,Annual_Gross_Sales__c,IsConverted,ConvertedAccountId, IsEmcForm__c from Lead where id = :leadObj.Id];
        Log.add('Lead found>>> ' + nlead);
        if (!nlead.IsConverted) {
            if (!Test.isRunningTest()) {
                Log.add('ConvertedAcc>>> ' + nlead.ConvertedAccountId);
                convertedAccountId = nlead.ConvertedAccountId;
                if (string.valueOf(annualSales).Contains('$')) {
                    annualSales = annualSales.replace('$', '');
                }
                if (string.valueOf(annualSales).Contains(',')) {
                    annualSales = annualSales.replace(',', '');
                }
                Decimal d = Decimal.valueOf(!String.isEmpty(annualSales) ? annualSales : '0');
                d = d.setScale(8, RoundingMode.HALF_EVEN);
                nlead.Annual_Gross_Sales__c = d;

                nlead.Funding_Credit_Needed__c = amountNeeded;
                nlead.Financing_Type__c = financingType;
                //nlead.Entity_Type__c = financType;
                nlead.Company = companyName;
                nlead.FirstName = firstName;
                nlead.LastName = lastName;
                nlead.Phone = phone;
                //nlead.Cell_Phone__c = cellPhone;
                nlead.Email = email;
                nlead.Form_Step_1__c = true;

            } else {
                nlead.Annual_Gross_Sales__c = 0;
            }

            Log.add('Lead to update>>> ' + nlead);

            try {
                update nlead;
                Log.add('Lead Updated');
                system.debug('lead update....');
            } catch (Exception e) {
                Log.add(e);
                system.debug('lead not update....' + e.getMessage());
            }
        } else {
            Log.add('Lead was already converted: Update Account');
            updateAccountSaleVale(lead);
        }

    }
    //Used to update Lead every or account
    public void doLeadCall() {
        Log.add('Tab#1:');
        try{
            if(oppWithoutLead) {
                Log.add('Opportunity without Lead.');
                updateAccountSaleVale();
            } else if (flag == false) {
                Log.add('Creates new Lead');
                saveData();
            } else {
//                Log.add('flag: '+ flag + ' convertedAccId: ' + convertedAccountId);
                system.debug('flag>>> ' + flag);
                system.debug('convertedAccountId>>> ' + convertedAccountId);
                if (convertedAccountId == '' || convertedAccountId == null) {
                    Log.add('Lead was created but not converted. Updates existing Lead');
                    system.debug('call updatelead');
                    updateLead(lead);
                } else {
                    Log.add('Lead was converted. Update Account');
                    system.debug('call updateAccountSaleVale');
                    updateAccountSaleVale(lead);
                }
            }
        } catch (Exception e){
            Log.add(e);
        } finally {
            Log.insertLog();
        }
    }
    //Used to convert lead to account and opportunity and update if already converted.
    public void doConvertLeadCall() {
        Log.add('Tab#2:');
        try{
            if(oppWithoutLead) {
                Log.add('Opp without Lead.');
                updateAccount();
            } else if (convertedAccountId == '' || convertedAccountId == null) {
                Log.add('Lead was not converted. Convert Lead');
                doConvertLead(lead);
            } else {
                Log.add('Lead was converted. Update Account');
                updateAccount(lead);
            }
        } catch (Exception e) {
            Log.add(e);
        } finally {
            Log.insertLog();
        }
    }

    //use to update account/Opportunity when user move back from tab3 to tab1 and update lead.
    public void updateAccountSaleVale(Lead leadObj) {
        Log.add('UpdateAccountSalevale called. Lead exists.');
        Log.add('Existing Lead>>> ' + leadObj);
        Lead nlead = [select id,IsConverted,ConvertedAccountId,ConvertedOpportunityId, IsEmcForm__c from Lead where id = :leadObj.Id];
        Log.add('Lead found>>> ' + nlead);
        if (isEmcSite){
            nlead.IsEmcForm__c = true;
        }
        //Identify Account converted from a lead
        if (nlead.IsConverted) {
            Log.add('Lead is Converted');
            Opportunity opp = [SELECT Id,Desired_Amount_Web__c,Use_of_Funds__c,When_Like_Funding__c FROM Opportunity WHERE Opportunity.Id = :nlead.ConvertedOpportunityId];
            Log.add('Converted Opp found>>> ' + opp);
            convertedOppId = opp.Id;
            if (opp != null) {
                opp.Desired_Amount_Web__c = amountNeeded;
                opp.Use_of_Funds__c = useofFunds;
                opp.When_Like_Funding__c = whenFunding;
                try {
                    Log.add('Opp to Update>>> ' + opp);
                    update nlead;
                    update opp;
                    Log.add('Opportunity Updated');
                    system.debug('Opportunity updated');
                } catch (Exception e) {
                    Log.add(e);
                    system.debug('Opportunity Error...' + e.getMessage());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                }
            }

            Account acc = [SELECT Id,Name,Legal_Name__c,Entity_Type__c,Stated_Gross_Sales__c,Funding_Credit_Needed__c,Financing_Type__c,Full_Name_1__c,Last_Name_1__c,Company_Phone__c,Phone,Cell_Phone__c,Mobile_Phone_1__c,Email__c FROM Account WHERE Account.Id = :nlead.ConvertedAccountId];
            Log.add('Converted Acc found>>> ' + acc);
            if (string.valueOf(annualSales).Contains('$')) {
                annualSales = annualSales.replace('$', '');
            }
            if (string.valueOf(annualSales).Contains(',')) {
                annualSales = annualSales.replace(',', '');
            }
            Decimal d = Decimal.valueOf(!String.isEmpty(annualSales) ? annualSales : '0');
            d = d.setScale(8, RoundingMode.HALF_EVEN);
            acc.Stated_Gross_Sales__c = d;
            acc.Name = companyName;
            acc.Legal_Name__c = companyName;
            acc.Full_Name_1__c = firstName;
            acc.Last_Name_1__c = lastName;
            acc.Funding_Credit_Needed__c = amountNeeded;
            acc.Financing_Type__c = financingType;
            acc.Entity_Type__c = financType;
            //ToDo - Check why not updated
            acc.Phone = phone;
            acc.Company_Phone__c = phone;
            acc.Cell_Phone__c = cellPhone;
            acc.Mobile_Phone_1__c = cellPhone;
            acc.Email__c = email;
            //acc.Stated_Gross_Sales__c           = nlead.Annual_Gross_Sales__c;

            Log.add('Account to Update>>> ' + acc);

            try {
                update acc;
                Log.add('Account Updated');
            } catch (Exception e) {
                Log.add(e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }
        }
    }

    public void updateAccountSaleVale() {
        Log.add('updateAccountSaleVale called: Update Account (No Lead)');
        //Identify Account converted from a lead
        if (oppWithoutLead) {
            Opportunity opp = [SELECT Id,Desired_Amount_Web__c,Use_of_Funds__c,When_Like_Funding__c FROM Opportunity WHERE Opportunity.Id = :existsOppId];
            if (opp != null) {
                opp.Desired_Amount_Web__c = amountNeeded;
                opp.Use_of_Funds__c = useofFunds;
                opp.When_Like_Funding__c = whenFunding;

                Log.add('Opp to Update>>> ' + opp);

                try {
                    update opp;
                    Log.add('Opportunity updated');
                } catch (Exception e) {
                    Log.add(e);
                    system.debug('Opportunity Error...' + e.getMessage());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                }
            }

            Account acc = [SELECT Id,Name,Legal_Name__c,Entity_Type__c,Stated_Gross_Sales__c,Funding_Credit_Needed__c,Financing_Type__c,Full_Name_1__c,Last_Name_1__c,Company_Phone__c,Phone,Cell_Phone__c,Mobile_Phone_1__c,Email__c FROM Account WHERE Account.Id = :existsAccountId];
            if (string.valueOf(annualSales).Contains('$')) {
                annualSales = annualSales.replace('$', '');
            }
            if (string.valueOf(annualSales).Contains(',')) {
                annualSales = annualSales.replace(',', '');
            }
            Decimal d = Decimal.valueOf(!String.isEmpty(annualSales) ? annualSales : '0');
            d = d.setScale(8, RoundingMode.HALF_EVEN);
            acc.Stated_Gross_Sales__c = d;
            acc.Name = companyName;
            acc.Legal_Name__c = companyName;
            acc.Full_Name_1__c = firstName;
            acc.Last_Name_1__c = lastName;
            acc.Funding_Credit_Needed__c = amountNeeded;
            acc.Financing_Type__c = financingType;
            acc.Entity_Type__c = financType;

            acc.Phone = phone;
            acc.Company_Phone__c = phone;
            acc.Cell_Phone__c = cellPhone;
            acc.Mobile_Phone_1__c = cellPhone;
            acc.Email__c = email;
            //acc.Stated_Gross_Sales__c           = nlead.Annual_Gross_Sales__c;

            Log.add('Account to Update>>> ' + acc);

            try {
                update acc;
                Log.add('Account updated');
            } catch (Exception e) {
                Log.add(e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }
        }
    }

    public void doConvertLead(Lead leadObj) {
        Log.add('doConvertLead called');
        System.debug('convert lead called');
        Log.add('Existing Lead>>> ' + leadObj);
        Lead nlead = [select id,Annual_Gross_Sales__c,IsConverted,ConvertedAccountId,ConvertedOpportunityId, Converted_Opportunity__c from Lead where id = :leadObj.Id];
        //Identify Account converted from a lead
        Opportunity opp = null;
        if (nlead != null && !nlead.IsConverted) {
            Log.add('Lead found>>> ' + nlead);
            if (convertedAccountId == '' || convertedAccountId == null) {
                Database.LeadConvert lc = new database.LeadConvert();
                lc.setLeadId(leadObj.Id);
                if (String.isNotBlank(userId))
                    lc.setOwnerId(userId);
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                System.debug('converted');
            }
            nlead = [select id,Entity_Type__c,Annual_Gross_Sales__c,Funding_Credit_Needed__c,Financing_Type__c,IsConverted,ConvertedAccountId,ConvertedOpportunityId from Lead where id = :leadObj.Id];
            Log.add('Converted Lead found>>> ' + nlead);
            convertedAccountId = nlead.ConvertedAccountId;
            System.debug('converted Acc Id' + convertedAccountId);
            Log.add('Converted Acc Id>>> ' + nlead.ConvertedAccountId);
            //Identify Account converted from a lead
            if (nlead != null && nlead.IsConverted) {
                opp = [SELECT Id,Desired_Amount_Web__c,Use_of_Funds__c,When_Like_Funding__c FROM Opportunity WHERE Opportunity.Id = :nlead.ConvertedOpportunityId];
                Log.add('Converted Opp found>>> ' + opp);
                convertedOppId = opp.Id;
                Log.add('Converted Opp Id>>> ' + nlead.ConvertedOpportunityId);
                if (opp != null) {
                    opp.Desired_Amount_Web__c = amountNeeded;
                    opp.Use_of_Funds__c = useofFunds;
                    opp.When_Like_Funding__c = whenFunding;
                    if(lead != null && String.isNotBlank(lead.Id)) {
                        opp.Converted_Lead_Record__c = lead.Id;
                    }

                    Log.add('Opp to update>>> ' + opp);

                    try {
                        update opp;
                        Log.add('Opportunity updated');
                        system.debug('Opportunity updated');
                    } catch (Exception e) {
                        Log.add(e);
                        system.debug('Opportunity Error...' + e.getMessage());
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                        UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                    }
                }

                Account acc = [SELECT Id,Name,DBA_Name__c,Legal_Name__c,Legal_Address__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Leased_Owned_Picklist__c,Use_of_Funds__c,Industry__c,Fed_Tax_ID__c,When_Like_Funding__c,Date_Business_Established__c FROM Account WHERE Account.Id = :nlead.ConvertedAccountId];
                if (dbaName.length() == 0) {
                    dbaName = '';
                }
                if (acc != null) {
                    Log.add('Converted Acc found>>> ' + acc);
                    acc.Name = companyName;
                    acc.DBA_Name__c = dbaName;
                    acc.Legal_Name__c = companyName;
                    acc.Legal_Address__c = billingAddress;
                    acc.Legal_City__c = businessCity;
                    acc.Legal_State__c = businessState;
                    acc.Legal_Zip__c = businessZip;
                    acc.Leased_Owned_Picklist__c = propertyType;
                    acc.Use_of_Funds__c = useofFunds;
                    acc.Industry__c = industry;
                    acc.Fed_Tax_ID__c = federalTaxId;
                    acc.When_Like_Funding__c = whenFunding;
                    acc.Date_Business_Established__c = businessStartDate;
                    //acc.Business_Description__c         = businessDescription;
                    acc.Stated_Gross_Sales__c = nlead.Annual_Gross_Sales__c;
                    //acc.Entity_Type__c = nlead.Entity_Type__c;
                    acc.Entity_Type__c = financType;
                    acc.Funding_Credit_Needed__c = nlead.Funding_Credit_Needed__c;
                    acc.Financing_Type__c = nlead.Financing_Type__c;
                    system.debug('Account value assign 1');

                    Log.add('Account to update>>> ' + acc);

                    try {
                        update acc;
                        Log.add('Account updated');
                        system.debug('Account value updated 1 time');
                    } catch (Exception e) {
                        Log.add(e);
                        system.debug('Failed update Account: ' + e.getMessage());
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                        UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                    }

                    /*    box.Toolkit boxToolkit = new box.Toolkit();
                    String oppFolderId = boxToolkit.createFolderForRecordId(opp.Id,null, true);
                    boxToolkit.commitChanges();
                    System.debug('mostRecentError: ' + boxToolkit.mostRecentError);
                    System.debug('oppFolderId: ' + oppFolderId);*/

                }

                nlead.Form_Step_2__c = true;
                nlead.Converted_Opportunity__c = nlead.ConvertedOpportunityId;

                Log.add('Lead to Update>>> ' + nlead);

                try {
                    update nlead;
                    Log.add('Lead Updated');
                    system.debug('Lead updated - Step 2');
                } catch (Exception e) {
                    Log.add(e);
                    system.debug('Opportunity Error...' + e.getMessage());
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }

            } else {
                Log.add('Update Account');
                updateAccount(lead);
            }
            System.debug('doConvertLead end');
        } else {
            Log.add('Lead was converted. Update Account');
            updateAccount(lead);
        }
    }
    //this code is used to update Account information.
    public void updateAccount(Lead leadObj) {
        Log.add('UpdateAccount called from existing Lead');
        Log.add('Existing Lead>>> ' + LeadObj);
        System.debug('inside update...account');
        Lead nlead = [select id,Entity_Type__c,Annual_Gross_Sales__c,Funding_Credit_Needed__c,Financing_Type__c,IsConverted,ConvertedAccountId,ConvertedOpportunityId from Lead where id = :leadObj.Id];
        //Identify Account converted from a lead
        if (nlead != null && nlead.IsConverted) {
            Log.add('Existing converted Lead found>>> ' + nlead);
            Opportunity opp = [SELECT Id,Desired_Amount_Web__c,Use_of_Funds__c,When_Like_Funding__c FROM Opportunity WHERE Opportunity.Id = :nlead.ConvertedOpportunityId];
            if (opp != null) {
                Log.add('Existing opp>>> ' + opp);
                opp.Desired_Amount_Web__c = amountNeeded;
                opp.Use_of_Funds__c = useofFunds;
                opp.When_Like_Funding__c = whenFunding;

                Log.add('Opp to Update>>> ' + opp);

                try {
                    update opp;
                    Log.add('Opportunity updated');
                    System.debug('inside opp update...');
                } catch (Exception e) {
                    Log.add(e);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
            }
            Account acc = [SELECT Id,Name,DBA_Name__c,Legal_Name__c,Legal_Address__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Leased_Owned_Picklist__c,Use_of_Funds__c,Industry__c,Fed_Tax_ID__c,When_Like_Funding__c,Date_Business_Established__c FROM Account WHERE Account.Id = :nlead.ConvertedAccountId];
            //Account acc = [SELECT Id FROM Account WHERE Account.Id =: nlead.ConvertedAccountId];
            System.debug('account: ' + acc.id);
            if (dbaName.length() == 0) {
                dbaName = '';
            }
            if (acc != null) {
                Log.add('Existing Account found>>> ' + acc);
                acc.Name = companyName;
                acc.DBA_Name__c = dbaName;
                acc.Legal_Name__c = companyName;
                acc.Legal_Address__c = billingAddress;
                acc.Legal_City__c = businessCity;
                acc.Legal_State__c = businessState;
                acc.Legal_Zip__c = businessZip;
                acc.Leased_Owned_Picklist__c = propertyType;
                acc.Use_of_Funds__c = useofFunds;
                acc.Industry__c = industry;
                acc.Fed_Tax_ID__c = federalTaxId;
                acc.When_Like_Funding__c = whenFunding;
                acc.Date_Business_Established__c = businessStartDate;
                //acc.Business_Description__c         = businessDescription;
//                acc.Entity_Type__c = nlead.Entity_Type__c;
                acc.Entity_Type__c = financingType;
                acc.Stated_Gross_Sales__c = nlead.Annual_Gross_Sales__c;
                acc.Funding_Credit_Needed__c = nlead.Funding_Credit_Needed__c;
                acc.Financing_Type__c = nlead.Financing_Type__c;
                system.debug('Account value assign 2');

                Log.add('Account to Update>>> ' + acc);

                try {
                    update acc;
                    Log.add('Account Updated');
                    system.debug('Account value updated 2 time');
                } catch (Exception e) {
                    Log.add(e);
                    system.debug('Error...' + e.getMessage());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
            }
        }
    }

    public void updateAccount() {
        //Identify Account converted from a lead
        if (oppWithoutLead) {
            Log.add('UpdateAccount called (No Lead).');

            Opportunity opp = [SELECT Id,Desired_Amount_Web__c,Use_of_Funds__c,When_Like_Funding__c FROM Opportunity WHERE Opportunity.Id = :existsOppId];
            if (opp != null) {
                Log.add('Existing opp found>>> ' + opp);
                opp.Desired_Amount_Web__c = amountNeeded;
                opp.Use_of_Funds__c = useofFunds;
                opp.When_Like_Funding__c = whenFunding;

                Log.add('Opp to Update>>> ' + opp);

                try {
                    update opp;
                    Log.add('Opportinity updated');
                    System.debug('inside opp update...');
                } catch (Exception e) {
                    Log.add(e);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
            }

            Account acc = [SELECT Id,Name,DBA_Name__c,Legal_Name__c,Legal_Address__c,Legal_City__c,Legal_State__c,Legal_Zip__c,Leased_Owned_Picklist__c,Use_of_Funds__c,Industry__c,Fed_Tax_ID__c,When_Like_Funding__c,Date_Business_Established__c FROM Account WHERE Account.Id = :existsAccountId];
            //Account acc = [SELECT Id FROM Account WHERE Account.Id =: nlead.ConvertedAccountId];
            System.debug('account: ' + acc.id);
            if (dbaName.length() == 0) {
                dbaName = '';
            }
            if (acc != null) {
                Log.add('Existing acc found>>> ' + acc);
                acc.Name = companyName;
                acc.DBA_Name__c = dbaName;
                acc.Legal_Name__c = companyName;
                acc.Legal_Address__c = billingAddress;
                acc.Legal_City__c = businessCity;
                acc.Legal_State__c = businessState;
                acc.Legal_Zip__c = businessZip;
                acc.Leased_Owned_Picklist__c = propertyType;
                acc.Use_of_Funds__c = useofFunds;
                acc.Industry__c = industry;
                acc.Fed_Tax_ID__c = federalTaxId;
                acc.When_Like_Funding__c = whenFunding;
                acc.Date_Business_Established__c = businessStartDate;
                //acc.Business_Description__c         = businessDescription;
//                acc.Entity_Type__c = nlead.Entity_Type__c;
                acc.Entity_Type__c = financingType;
//                acc.Stated_Gross_Sales__c = nlead.Annual_Gross_Sales__c;
//                acc.Funding_Credit_Needed__c = nlead.Funding_Credit_Needed__c;
//                acc.Financing_Type__c = nlead.Financing_Type__c;
                system.debug('Account value assign 2');

                Log.add('Account to Update>>> ' + acc);

                try {
                    update acc;
                    system.debug('Account value updated 2 time');
                    Log.add('Account updated');
                } catch (Exception e) {
                    Log.add(e);
                    system.debug('Error...' + e.getMessage());
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
            }
        }
    }

    /*public Pagereference doUpdateAccountCall(){
        doUpdateAccount(lead);
        PageReference redirectPage = Page.ApplicationFormFiles;
        redirectPage.setRedirect(true);
        //String encodedOutput = GeneralUtilities.encryptData(accountObj.id);
        redirectPage.getParameters().put('id', accountObj.id);
        return redirectPage;
    }*/


    //update account and then move to docusign page
    public Pagereference doUpdateAccountCall() {

        Log.add('Tab#3:');

        try{

            if(oppWithoutLead) {
                doUpdateAccount();
            } else {
                doUpdateAccount(lead);
            }

            Log.add('doUpdateAccount complete. creates Docusign URL');

            doUpdateOpp();

            docuSignUrlForRedirect = createDocusignURL();

        } catch (Exception e) {
            Log.add(e);
        } finally {
            Log.insertLog();
        }

        //PageReference objPR = new PageReference(docuSignUrl);
//        objPR.setRedirect(true);
        // objPR.setRedirect(false);
        //return objPR;
        return null;
    }

    private void doUpdateOpp() {

        Log.add('doUpdateOpp called. opp ID: ' + convertedOppId);
        Log.add('isEmcSite: ' + isEmcSite);
        Log.add('emc sitename: ' + siteHostname.contains('emcfinancial.com'));
        Log.add('settings: ' + DocuSign_Settings__c.getOrgDefaults().Test_EMC__c);

        for(Opportunity opp : [SELECT id, IsEmcForm__c FROM Opportunity WHERE Id=:convertedOppId]) {
            Log.add('Opp: ' + opp);
            if (opp != null && (DocuSign_Settings__c.getOrgDefaults().Test_EMC__c || siteHostname.contains('emcfinancial.com') || isEmcSite)){
                opp.IsEmcForm__c = true;
                Log.add('Opp to update>>> ' + opp);
                update opp;
            }
        }
    }

//    private void doUpdateLead() {
//
//        Log.add('doUpdateLead called. Lead ID: ' + lead.Id);
//        Log.add('isEmcSite: ' + isEmcSite);
//        Log.add('emc sitename: ' + siteHostname.contains('emcfinancial.com'));
//        Log.add('settings: ' + DocuSign_Settings__c.getOrgDefaults().Test_EMC__c);
//
//        for(Lead l : [SELECT id, IsEmcForm__c FROM Lead WHERE Id=:lead.Id]) {
//            Log.add('Lead: ' + l);
//            if (l != null && (DocuSign_Settings__c.getOrgDefaults().Test_EMC__c || siteHostname.contains('emcfinancial.com') || isEmcSite)){
//                l.IsEmcForm__c = true;
//                Log.add('Lead to update>>> ' + l);
//                update l;
//            }
//        }
//    }

    //for Docusign
    public string createDocusignURL() {

        Log.add('createDocusignURL called');

//        String docusignURL = '';
//        if (siteHostname.contains('emcfinancial.com') &&
//                        DocuSign_Settings__c.getOrgDefaults() != null &&
//                        DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_URL__c != null &&
//                        DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_Powerform_Id__c != null) {
//            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_URL__c + '/Member/PowerFormSigning.aspx?PowerFormId=';
//            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_Powerform_Id__c + '&';
//        }
//        else if (DocuSign_Settings__c.getOrgDefaults() != null && DocuSign_Settings__c.getOrgDefaults().DocuSign_URL__c != null &&
//                DocuSign_Settings__c.getOrgDefaults().DocuSign_Powerform_Id__c != null) {
//            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_URL__c + '/Member/PowerFormSigning.aspx?PowerFormId=';
//            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_Powerform_Id__c + '&';
//        }
//        else {
//            docusignURL = 'https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=68d57b1f-c14c-4774-be29-77bbb4d59f0b&';
//        }

        String docusignURL = '';
        if (DocuSign_Settings__c.getOrgDefaults().Test_EMC__c || siteHostname.contains('emcfinancial.com') || isEmcSite &&
                DocuSign_Settings__c.getOrgDefaults() != null &&
                DocuSign_Settings__c.getOrgDefaults().DocuSign_URL__c != null &&
                DocuSign_Settings__c.getOrgDefaults().DocuSign_Powerform_Id__c != null) {
            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_URL__c + '/Member/PowerFormSigning.aspx?PowerFormId=';
            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_Powerform_Id__c + '&';
        }
        else if (DocuSign_Settings__c.getOrgDefaults() != null && DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_URL__c != null &&
                DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_Powerform_Id__c != null) {
            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_URL__c + '/Member/PowerFormSigning.aspx?PowerFormId=';
            docusignURL += DocuSign_Settings__c.getOrgDefaults().DocuSign_Lendfully_Powerform_Id__c + '&';
        }
        else {
            docusignURL = 'https://demo.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=68d57b1f-c14c-4774-be29-77bbb4d59f0b&';
        }
        Log.add('Url>>> ' + docusignURL);

        if (companyName != null && companyName != '') {
            docusignURL += 'Legal Company Name=' + replaceSpecialChar(companyName) + '&';
        }

        if (dbaName != null && dbaName != '') {
            docusignURL += 'DBA Name=' + replaceSpecialChar(dbaName) + '&';
        }

        if (financType != null && financType != '') {
            if (financType == 'Sole Proprietor') {
                docusignURL += 'SolePro=true&';
            } else if (financType == 'Corporation') {
                docusignURL += 'Corporation=true&';
            } else if (financType == 'Partnership') {
                docusignURL += 'Partnership=true&';
            } else if (financType == 'LLC') {
                docusignURL += 'LLC=true&';
            } else if (financType == 'Non-Profit') {
                docusignURL += 'NonProfit=true&';
            }
        }

        if (billingAddress != null && billingAddress != '') {
            docusignURL += 'Business Address=' + replaceSpecialChar(billingAddress) + '&';
        }

        if (businessCity != null && businessCity != '') {
            docusignURL += 'Business City=' + replaceSpecialChar(businessCity) + '&';
        }

        if (businessState != null && businessState != '') {
            docusignURL += 'Business State=' + replaceSpecialChar(businessState) + '&';
        }

        if (businessZip != null && businessZip != '') {
            docusignURL += 'Business Zip=' + replaceSpecialChar(businessZip) + '&';
        }

        if (phone != null && phone != '') {
            docusignURL += 'Company Phone=' + replaceSpecialChar(phone) + '&';
        }

        if (cellPhone != null && cellPhone != '') {
            docusignURL += 'Cell Phone=' + replaceSpecialChar(cellPhone) + '&';
        }

        if (email != null && email != '') {
            docusignURL += 'Email=' + email + '&';
            docusignURL += 'Merchant_Email=' + email + '&';
        }

        if (annualSales != null && annualSales != '') {
            docusignURL += 'Gross Annual Revenue=' + annualSales + '&';
        }

        if (federalTaxId != null && federalTaxId != '') {
            docusignURL += 'Federal Tax ID=' + federalTaxId + '&';
        }

        if (businessStartDate != null) {
            String businessStartDateString = businessStartDate.month() + '/' + businessStartDate.day() + '/' + businessStartDate.year();
            docusignURL += 'Business Start Date Under Current Ownership=' + businessStartDateString + '&';
        }

        if (propertyType != null && propertyType != '') {
            docusignURL += 'Do you own or rent your business property=' + replaceSpecialChar(propertyType) + '&';
        }

        /*if(email != null && email != ''){
            docusignURL += 'What is your monthly rentmortgage payment='+email+'&';
        }*/

        if (useofFunds != null && useofFunds != '') {
            docusignURL += 'Use of Funds=' + replaceSpecialChar(useofFunds) + '&';
        }

        if (industry != null && industry != '') {
            String industryChanged = industry.replace('&', 'and');
            System.debug('industryChanged ->' + industryChanged);
            docusignURL += 'Description of Business=' + industryChanged + '&';
        }

        String ownerName = '';
        if (firstname1 != null && firstname1 != '') {
            ownerName += firstname1;
        }
        if (lastname1 != null && lastname1 != '') {
            ownerName += ' ' + lastname1;
        }
        if (ownerName != null && ownerName != '') {
            docusignURL += 'Name=' + ownerName.replace('&', '%26') + '&';
            docusignURL += 'Merchant_UserName=' + changeOwnerName(ownerName) + '&';
        }

        if (dateofBirth != null) {
            String dateofBirthString = dateofBirth.month() + '/' + dateofBirth.day() + '/' + dateofBirth.year();
            docusignURL += 'Date of Birth=' + dateofBirthString + '&';
        }

        if (socialSecurityNumber != null && socialSecurityNumber != '') {
            docusignURL += 'SSN=' + socialSecurityNumber + '&';
        }

        if (homeAddress != null && homeAddress != '') {
            docusignURL += 'Home Address No PO Boxes=' + replaceSpecialChar(homeAddress) + '&';
        }
        if (homeCity != null && homeCity != '') {
            docusignURL += 'Home City=' + replaceSpecialChar(homeCity) + '&';
        }

        if (homeState != null && homeState != '') {
            docusignURL += 'Home State=' + replaceSpecialChar(homeState) + '&';
        }

        if (homeZip != null && homeZip != '') {
            docusignURL += 'Home Zip=' + homeZip + '&';
        }

        Log.add('convertedOppId>>> ' + convertedOppId);
        System.debug('convertedOppId ->' + convertedOppId);
        if (convertedOppId != null && convertedOppId != '') {
            docusignURL += 'opportunityId=' + convertedOppId + '&';
        }

        if (convertedAccountId != null && convertedAccountId != '') {
            docusignURL += 'accountId=' + convertedAccountId + '&';
        }

        docusignURL = docusignURL.substring(0, docusignURL.length() - 1);
        System.debug('docusignURL 1->' + docusignURL);

        //docusignURL = docusignURL.replace('%','%25');
        //docusignURL = docusignURL.replace('#', '%23');
        //docusignURL = docusignURL.replace('|','%7C');

        System.debug('docusignURL 2->' + docusignURL);

        Log.add('Docusign URL>>> ' + docusignURL);
        return docusignURL;
    }

    public static String changeOwnerName(String ownerName) {
        if (ownerName.contains('<')) {
            ownerName = ownerName.replace('<', '');
        }
        if (ownerName.contains('>')) {
            ownerName = ownerName.replace('>', '');
        }
        if (ownerName.contains('$')) {
            ownerName = ownerName.replace('$', '');
        }
        if (ownerName.contains('#')) {
            ownerName = ownerName.replace('#', '');
        }
        System.debug('ownerName ->' + ownerName);
        return ownerName;
    }

    public static String replaceSpecialChar(String str) {
        str = str.replace('%', '%25');
        str = str .replace('#', '%23');
        str = str .replace('|', '%7C');
        str = str .replace('&', '%26');
        return str;
    }

    //use to update account from tab3
    public void doUpdateAccount(Lead leadObj) {
        Log.add('doUpdateAccount called');
        Log.add('Existing Lead>>> ' + leadObj);
        System.debug('<<<<<Inside doUpdateAccount>>>>>');
        Lead nlead = [select id,IsConverted,ConvertedAccountId,ConvertedOpportunityId from Lead where id = :leadObj.Id];
        //Identify Account converted from a lead
        if (nlead != null && nlead.IsConverted) {
            Log.add('Existing Lead found>>> ' + nlead);
            Log.add('Account from Lead=>>> ' + nlead.ConvertedAccountId + ' : Opp from Lead=>>>' + nlead.ConvertedOpportunityId);
            convertedOppId = nlead.ConvertedOpportunityId;
            Account acc = [SELECT Id FROM Account WHERE Account.Id = :nlead.ConvertedAccountId];
            if (acc != null) {
                Log.add('Existing Accont found>>> ' + acc);
//                if (firstname.equals(firstname1) && lastname.equals(lastname1)) {
                acc.Full_Name_1__c = firstname1;
                acc.Last_Name_1__c = lastname1;
//                } else {
//                    acc.Full_Name_2__c = firstname1;
//                    acc.Last_Name_2__c = lastname1;
//                }
                acc.Date_of_Birth_1__c = dateofBirth;
                acc.SSN_1__c = socialSecurityNumber;
                acc.Residence_Address_1__c = homeAddress;
                acc.City_State_Zip_Code_1__c = homeCity;
                acc.State_1__c = homeState;
                acc.Zip_1__c = homeZip;
                acc.Home_Property_Type__c = homePropertyType;

                Log.add('Account to Update>>> ' + acc);

                try {
                    update acc;
                    accountObj = acc;
                    Log.add('Account updated');
                } catch (Exception e) {
                    Log.add(e);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
            }

            nlead.Form_Step_3__c = true;
            Log.add('Lead to Update>>> ' + nlead);
            try {
                update nlead;
                system.debug('Lead updated - Step 3');
                Log.add('Lead updated');
            } catch (Exception e) {
                Log.add(e);
                system.debug('Opportunity Error...' + e.getMessage());
                UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }
        }
    }

    public void doUpdateAccount() {

        if (oppWithoutLead) {
            Log.add('doUpdateAccount called (No Lead)');
            Account acc = [SELECT Id FROM Account WHERE Account.Id = :existsAccountId];
            if (acc != null) {
                Log.add('Existing Account found>>> ' + acc);
                acc.Full_Name_1__c = firstname1;
                acc.Last_Name_1__c = lastname1;
                acc.Date_of_Birth_1__c = dateofBirth;
                acc.SSN_1__c = socialSecurityNumber;
                acc.Residence_Address_1__c = homeAddress;
                acc.City_State_Zip_Code_1__c = homeCity;
                acc.State_1__c = homeState;
                acc.Zip_1__c = homeZip;
                acc.Home_Property_Type__c = homePropertyType;

                Log.add('Account to Update>>> ' + acc);

                try {
                    update acc;
                    accountObj = acc;
                    Log.add('Account updated');
                } catch (Exception e) {
                    Log.add(e);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Error in update.'));
                    UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
            }
        }
    }
}