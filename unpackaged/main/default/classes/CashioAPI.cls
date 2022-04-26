@RestResource(urlMapping='/Cashio/*')
global with sharing class CashioAPI{
    global class CashioAPIResponse{
        Boolean success;
        String error_message;
    }

    static List<String> ccList = new List<String>(); //'zev@zevie.com'
    
    @HttpPost
    global static CashioAPIResponse createLead() {

        //Prepare the email templates
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'info@cashio.com'];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
        for(EmailTemplate template : [Select Id, DeveloperName, Subject, Body, HtmlValue From EmailTemplate 
                                      Where DeveloperName IN ('Cashio_Automated_Admin_Notification_Email', 
                                                              'Cashio_Automated_Merchant_Confirmation_Email',
                                                              'Cashio_Automated_Merchant_Confirmation_Email_HTML',
                                                              'Cashio_Lender_not_found_in_SFDC')]){
            emailTemplateMap.put(template.DeveloperName, template);
        }

        //Get the jsonData from the POST
        String jsonData = RestContext.request.requestBody.tostring();
        System.debug('jsonData - ' + jsonData);
        System.debug('RestContext.request - ' + RestContext.request);

        for(String key : RestContext.request.params.keyset()){
            System.debug('key - ' + key);
        }
        System.debug('RestContext.response - ' + RestContext.response);

        System.debug('RestContext.request.params - ' + RestContext.request.params);
        CashioLead data = CashioLead.parse(jsonData);
        String name = data.name;

        Integer startLoc = name.indexOf(' ');
        Integer endLoc = name.lastIndexOf(' ');

        String firstName = '';
        String lastName = '';

        if (startLoc >= 0) {
            firstName = name.substring(0, endLoc);
            lastName = name.substring(endLoc + 1, name.length());
        }
        if(firstName != null) firstName = firstName.capitalize();
        if(lastName != null) lastName = lastName.capitalize();
        if(data.business_name != null) data.business_name = data.business_name.capitalize();

        System.debug(firstName);
        System.debug(lastName);

        if(lastName == '' || lastName == null){
            lastName = name;
        }
        System.debug(firstName);
        System.debug(lastName);


        //Need to check if record already exists (sent via the api)

        Account acc = new Account(  Name = data.business_name + ' (Cashio)',
                                    State_Cashio__c = data.state,
                                    Industry_Cashio__c = data.industry,
                                    Established_Cashio__c = data.months_in_business,
                                    AnnualRevenue = data.annual_sales,
                                    Credit_Score_Cashio__c = data.credit_score,
                                    Full_Name_1__c = firstName,
                                    Last_Name_1__c = lastName,
                                    Phone = data.phone,
                                    Email__c = data.email,
                                    DBA_Name__c = data.business_name,
                                    Cashio_Submission_Id__c = data.submission_id);
        
        upsert acc Cashio_Submission_Id__c;



        Opportunity opp = new Opportunity(AccountId = acc.Id,
                                          StageName = 'Cashio - Applied',
                                          CloseDate = Date.today(),
                                          Name = data.business_name + ' (Cashio) Submitted ' + String.valueOf(Date.today()),
                                          Cashio_Submission_Id__c = data.submission_id,
                                          UTM_Source__c = data.utm_source,
                                          UTM_Medium__c = data.utm_medium,
                                          UTM_Campaign__c = data.utm_campaign);
        upsert opp Cashio_Submission_Id__c;

        if(data.action == 'create'){
            Contact con = new Contact(AccountId = acc.Id,
                                      FirstName = firstName,
                                      LastName = lastName,
                                      Email = data.email,
                                      Phone = data.phone);

           

            insert con;

            OpportunityContactRole oppContactRole = new OpportunityContactRole(OpportunityId = opp.Id,
                                                                    ContactId = con.Id,
                                                                    IsPrimary = true,
                                                                    Role = 'Business Owner');
            insert oppContactRole;
        }


        Set<String> cashioFunderIdSet = new Set<String>();
        for(CashioLead.Lenders lender : data.lenders){
            if(lender.id != null){
                cashioFunderIdSet.add(String.valueOf(lender.id));
            }
        }

        Map<String, Funder__c> cashioIdToFunderMap = new Map<String, Funder__c>();
        for(Funder__c funder : [Select Id, Name, Contact_Name__c, Contact_Email__c, Cashio_ID__c, Funder_Login_URL__c, Funder_Login_Notes__c, Requires_Manual_Input__c, Merchant_App_URL__c, Merchant_Instructions__c, Logo_URL__c
                                From Funder__c Where Cashio_ID__c IN :cashioFunderIdSet
                                Order By Requires_Manual_Input__c DESC]){
            cashioIdToFunderMap.put(funder.Cashio_ID__c, funder);
        }

        //Create Submissions based on the Cashio ID
        List<Submissions__c> submissionList = new List<Submissions__c>();
        for(CashioLead.Lenders lender : data.lenders){
            if(lender.id != null && cashioIdToFunderMap.containskey(String.valueOf(lender.id))){
                Funder__c funder = cashioIdToFunderMap.get(String.valueOf(lender.id));
                Submissions__c newSubmission = new Submissions__c(Opportunity__c = opp.Id,
                                                                Funder__c = funder.Id,
                                                                Funder_Email__c = funder.Contact_Email__c,
                                                                Cashio_Unique_Id__c = lender.id + ' - ' + opp.Id);
                //Default to Received if funder requires manual input
                newSubmission.Bank_Status__c = (funder.Requires_Manual_Input__c) ? 'Received' : 'Underwriting';

                submissionList.add(newSubmission);
            }else{
                //Email Zev because the funder couldn't be found.
                
                if(emailTemplateMap.containsKey('Cashio_Lender_not_found_in_SFDC')){
                    EmailTemplate template = emailTemplateMap.get('Cashio_Lender_not_found_in_SFDC');
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    //Set info@cashio.com as OWEA
                    if (owea.size() > 0){
                        mail.setOrgWideEmailAddressId(owea[0].Id);
                    }
                    String emailSubject = String.valueOf(template.Subject);
                    String emailBody = String.valueOf(template.Body);
                    
                    emailBody = emailBody.replace('{!LENDER_NAME}', lender.name);
                    emailBody = emailBody.replace('{!LENDER_ID}', String.valueOf(lender.id));
                    emailBody = emailBody.replace('{!POST_DETAILS}', jsonData);

                    mail.setPlainTextBody(emailBody);
                    mail.setSubject(emailSubject);
                    List<String> targets = new List<String>();
                    //targets.addAll(ccList);
                    targets.add('zev@zevie.com');
                    mail.setToAddresses(targets);
                    emailsToSend.add(mail);
                }
            }
        }

        if(submissionList.size() > 0) upsert submissionList Cashio_Unique_Id__c;



        //**********************************************************************
        // == Automated Funder Email ==
        // Subject: New Lead Cashio - Name of Business (Opportunity)
        //**********************************************************************

        //Emailed via workflow rules

        //**********************************************************************
        // == Automated Admin Notification Email ==
        // Send "Automated Admin Notification Email"
        // Subject: New lead {Business Name} Applied with {No. Lenders} Lenders
        //**********************************************************************
        if(emailTemplateMap.containsKey('Cashio_Automated_Admin_Notification_Email')){
            EmailTemplate template = emailTemplateMap.get('Cashio_Automated_Admin_Notification_Email');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            
            //Set info@cashio.com as OWEA
            if (owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            String emailSubject = String.valueOf(template.Subject);
            String emailBody = String.valueOf(template.Body);
            String lenderDetails = '';


            emailSubject = emailSubject.replace('{!BUSINESS_NAME}', data.business_name);
            emailSubject = emailSubject.replace('{!LENDER_COUNT}', String.valueOf(data.lenders.size()));
            
            Integer counter = 1;

            lenderDetails += 'The following is a new lead that just now applied with:' + '\n\n';
            
            // Process first the ones that require Manual Input
            for(CashioLead.Lenders lender : data.lenders){
                if(cashioIdToFunderMap.containsKey(String.valueOf(lender.id))
                    && cashioIdToFunderMap.get(String.valueOf(lender.id)).Requires_Manual_Input__c){
                    Funder__c funder = cashioIdToFunderMap.get(String.valueOf(lender.id));
                    lenderDetails += counter + '. ' + lender.name + '\n';
                    lenderDetails += 'Please input this merchant\'s details into the portal asap: \n';
                    lenderDetails += 'Link to lender portal: ' + funder.Funder_Login_URL__c + '\n';
                    lenderDetails += 'Instructions: ' + funder.Funder_Login_Notes__c + ' \n';
                    lenderDetails += '\n';
                    counter++;
                }
            }
            // Process ones that does not Require Manual Input
            for(CashioLead.Lenders lender : data.lenders){
                if(cashioIdToFunderMap.containsKey(String.valueOf(lender.id))
                    && !cashioIdToFunderMap.get(String.valueOf(lender.id)).Requires_Manual_Input__c){
                    Funder__c funder = cashioIdToFunderMap.get(String.valueOf(lender.id));
                    lenderDetails += counter + '. ' + lender.name + ' (no action is required)\n\n';
                    counter++;
                }
            }

            emailBody = emailBody.replace('{!LENDER_DETAILS}', lenderDetails);
            emailBody = emailBody.replace('{!INDUSTRY}', data.industry);
            emailBody = emailBody.replace('{!STATE_CASHIO}', data.state);
            emailBody = emailBody.replace('{!ESTABLISHED_CASHIO}', data.months_in_business);
            emailBody = emailBody.replace('{!ANNUAL_REVENUE}', Decimal.valueOf(data.annual_sales).format());
            emailBody = emailBody.replace('{!CREDIT_SCORE_CASHIO}', data.credit_score);
            
            emailBody = emailBody.replace('{!FULL_NAME}', firstName + ' ' + lastName);
            emailBody = emailBody.replace('{!BUSINESS_NAME}', data.business_name);
            emailBody = emailBody.replace('{!BUSINESS_PHONE}', data.phone);
            emailBody = emailBody.replace('{!BUSINESS_EMAIL}', data.email);
            
            mail.setPlainTextBody(emailBody);
            mail.setSubject(emailSubject);
            List<String> targets = new List<String>();
            targets.addAll(ccList);
            targets.add('info@cashio.com');
            mail.setToAddresses(targets);
            emailsToSend.add(mail);
        }



        //**********************************************************************
        // == Automated Merchant Confirmation Email ==
        // Subject: Funding Application for {!BUSINESS_NAME}
        //**********************************************************************

        if(emailTemplateMap.containsKey('Cashio_Automated_Merchant_Confirmation_Email_HTML')){
            EmailTemplate template = emailTemplateMap.get('Cashio_Automated_Merchant_Confirmation_Email_HTML');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
            
            //Set info@cashio.com as OWEA
            if (owea.size() > 0){
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            String emailSubject = String.valueOf(template.Subject);
            String emailBody = String.valueOf(template.HtmlValue);
            String lenderDetails = '';


            emailSubject = emailSubject.replace('{!BUSINESS_NAME}', data.business_name);
            
            //Integer counter = 1;

            for(CashioLead.Lenders lender : data.lenders){
                if(cashioIdToFunderMap.containsKey(String.valueOf(lender.id))){
                    Funder__c funder = cashioIdToFunderMap.get(String.valueOf(lender.id));
                    lenderDetails += '<tr>'; 
                    lenderDetails += '     <td style="border-radius: 10px; background-color: white; padding: 5px; text-align: center; width: 135px;">'; 
                    lenderDetails += '        <img src="' + funder.Logo_URL__c + '" width="125px" height="35px" />'; 
                    lenderDetails += '     </td>'; 
                    
                    lenderDetails += '  <td style="text-align:left; font-size: 15px;">'; 
                    if(funder.Merchant_App_URL__c == null){
                        //lenderDetails += '    <span>You&apos;ll receive a link shortly with instructions on completing your application and getting approved for funding.</span>';
                        lenderDetails += '    <span>A loan specialist will contact you shortly to complete your loan application.</span>';
                    }else{
                        lenderDetails += '    <a href="' + funder.Merchant_App_URL__c + '" style="text-decoration: none  !important;">'; 
                        lenderDetails += '     <div style="border-radius: 10px; background-color: #6CA35E; padding: 5px; text-align: center; width: 150px; color:white; font-size:15px;">'; 
                        lenderDetails += '        Complete Application'; 
                        lenderDetails += '     </div>'; 
                        lenderDetails += '     </a>'; 
                        lenderDetails += '     <div>'; 
                        lenderDetails += '        <a href="' + funder.Merchant_App_URL__c + '" style="color:black;">Complete your application</a> and pre-approval process.'; 
                        lenderDetails += '     </div>'; 
                    }
                    lenderDetails += '  </td>'; 
                    lenderDetails += '</tr>'; 
                    lenderDetails += '<tr><td></td><td></td></tr>'; 
                    

                    //lenderDetails += counter + '. ' + funder.Name.replace(' (Cashio)', '') + ' - ' + blankValue(funder.Merchant_Instructions__c) + '\n';
                    //if(funder.Merchant_App_URL__c != null){
                    //    lenderDetails += 'Application Link\n';
                    //    lenderDetails += blankValue(funder.Merchant_App_URL__c) + '\n';
                    //}
                    //lenderDetails += '\n';
                    //counter++;
                }
            }
            
            emailBody = emailBody.replace('{!LENDER_COUNT}', String.valueOf(data.lenders.size()));
            emailBody = emailBody.replace('{!LENDER_DETAILS}', lenderDetails);
            emailBody = emailBody.replace('{!FULL_NAME}', firstName + ' ' + lastName);

            mail.sethtmlbody(emailBody);
            mail.setSubject(emailSubject);
            List<String> targets = new List<String>();
            targets.addAll(ccList);
            targets.add(data.email);
            mail.setToAddresses(targets);
            emailsToSend.add(mail);
        }


        //**********************************************************************
        // == Automated Funder Reminder Email ==
        // Subject: "Name of Lender contact" whats the status with “Name of Lead”
        // Sent via time-based workflow rules
        //**********************************************************************

        Messaging.reserveSingleEmailCapacity(10);
        Messaging.sendEmail(emailsToSend, false);
        
        CashioAPIResponse cAPIResponse = new CashioAPIResponse();
        cAPIResponse.success = true;
        return cAPIResponse;
    }

    //private static String blankValue(String str){
    //    if(str == null || str == ''){
    //        str = '';
    //    }
    //    return str;
    //}
}