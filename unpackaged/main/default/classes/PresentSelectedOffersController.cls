public with sharing class PresentSelectedOffersController {
    public List<Offer__c> 		offers {get; set;}
    public List<ValidationObj> 	validations {get; set;}
    public Boolean 				emailSuccess {get; set;}
    public Boolean 				editEmailSuccess {get; set;}
    public Boolean 				isEditPage {get; set;}
    public Opportunity 			opp {get; set;}
    public Message				emailMsg {get;set;}
    
    //Apex Object to expose fields for PresentAndEditOffers VF Page
    public Class Message{
        public Message(){
            toAddresses = New List<String>();
            ccAddresses = New List<String>();
            bccAddresses = New List<String>();
        }
        public String				fromAddress {get;set;}
        public List<String>			toAddresses {get;set;}
        public String				to{get;set;}
        public List<String>	 	    ccAddresses {get;set;}
        public String				cc{get;set;}
        public List<String>			bccAddresses {get;set;}
        public String				bcc{get;set;}
        public String				subject {get;set;}
        public String 				htmlBody {get;set;}   
        private String				convertListToString(List<String> addresses){
            String response = '';
            for(String s : addresses){
                if(s != NULL){
                    response += s + ',';
                }
            }
            if(response.indexOf(',') > -1){
                response = response.substring(0, response.length() - 1);
            }
            return response;
        }
        private String[]			convertStringToList(String addressInput){
            String[] addressList;
            addressInput = addressInput.replaceAll(';', ',');
            addressInput = addressInput.replaceAll(' ', '');
            System.debug(addressInput);
            System.debug(New List<String>(addressInput.split(',', 0)));
            if(addressInput.length() > 0){
                addressList = addressInput.split(',', -1);
            }
            else{
                return null;
            }
            if(addressList.size() > 0){
                return addressList;
            }
            else{
                return null;
            }
        }
    }

    public PresentSelectedOffersController() {
        isEditPage = false;
        String ids = apexpages.currentpage().getparameters().get('ids');
        if(apexpages.currentpage().getparameters().get('isEditPage') != NULL){
            if(apexpages.currentpage().getparameters().get('isEditPage') == 'true'){
                isEditPage = true;
            }
        }
        //emailMsg exposes the calucated fields to the PesentAndEditSelectOffers VF Page
        emailMsg = new Message();
        List<Id> offerIds = new List<Id>();
        for(String temp : ids.split(',')){
            offerIds.add(Id.valueOf(temp));
        }

        offers = [SELECT Id, Name, Type__c, Amount_Advanced__c, Payback_Amount__c, Factor_Rate__c, Daily_Payment__c,
                    Number_of_Payments__c, Weeks__c, Term__c, Lender_Fees__c, PSF_Charged__c, Net_Funded__c, Merchant_Net__c, Commission__c,
                    Position__c,
                    Opportunity__r.Account.Email__c, Opportunity__r.Id, Opportunity__r.Account.Full_Name_1__c, Status__c,
                    Opportunity__r.Account.Last_Name_1__c, Additional_Funding__c, Opportunity__r.Owner.Name,
                    Opportunity__r.Owner.Phone, Opportunity__r.Owner.Email, Opportunity__r.Account.Name,
                    Opportunity__r.Final_Stips__c,
                    Opportunity__r.ISO__c,
                    Opportunity__r.ISO__r.Name,
                    Opportunity__r.ISO__r.Contact_Email__c,
                    Opportunity__r.ISO__r.Copy_Merchant_on_Approvals__c,
                  	Opportunity__r.ISO__r.Owner.email
                    FROM Offer__c
                    WHERE Id IN :offerIds];
        
        emailSuccess = true;
        validations = new List<ValidationObj>();
        for(Offer__c offer : offers){
            if(opp == null) opp = offer.Opportunity__r;
            if(offer.Amount_Advanced__c == null) validations.add(new ValidationObj(offer, 'Enter an advance amount.'));
            if(offer.Position__c == null) validations.add(new ValidationObj(offer, 'Enter a Position.'));
            if(offer.Payback_Amount__c == null) validations.add(new ValidationObj(offer, 'Enter a payback amount.'));
            if(offer.Daily_Payment__c == null) validations.add(new ValidationObj(offer, 'Enter a payment amount.'));
            if(offer.Number_of_Payments__c == null) validations.add(new ValidationObj(offer, 'Enter number of payments.'));
            if(offer.Lender_Fees__c == null) validations.add(new ValidationObj(offer, 'Enter the Lender fees.'));
            if(offer.PSF_Charged__c == null) validations.add(new ValidationObj(offer, 'Enter the PSF.'));
            if(offer.Commission__c == null) validations.add(new ValidationObj(offer, 'Enter the Commission on the Funder.'));
           /* if(offer.Type__c == 'Daily'){
                if(offer.Term__c == null) validations.add(new ValidationObj(offer, 'Enter amount of months.'));
            }*/
            if(offer.Term__c == null) validations.add(new ValidationObj(offer, 'Enter amount of months.'));
            if(isEditPage == true){
                if(opp.ISO__c == null){
                    validations.add(new ValidationObj(offer, 'Opportunity must be related to a Partner.'));
                }
            }
            if(validations.size() > 0) emailSuccess = false;
        }
    }

    public List<Offer__c> getSelectedOffers(){
        return offers;
    }

    public PageReference execute(){
        if(validations.size() > 0){
            System.debug(validations);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,validateData());
            ApexPages.addMessage(myMsg);
        } else {
            prepareOffersEmail();
            System.debug(isEditPage);
            System.debug(editEmailSuccess);
            if(isEditPage == false){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Email sent!');
            	ApexPages.addMessage(myMsg);
            }
            else if(editEmailSuccess == true){
                System.debug(getParentPage());
                PageReference OppPage = new PageReference(getParentPage());
                OppPage.setRedirect(true);
                return OppPage;
                
            }
            
        }
        return null;
    }

    private String validateData(){
        String msg = 'The following offers have some missing values.';
        for(ValidationObj v : validations){
            msg += v.offer.name + ' - ' + v.validationMessage + ' ';
        }
        return msg;
    }

    public List<ValidationObj> getValidations(){
        return validations;
    }

    public String getParentPage(){
        return Url.getSalesforceBaseUrl().toExternalForm() +'/'+ String.valueOf(offers[0].Opportunity__r.Id);
    }

    public PageReference prepareOffersEmail(){
        
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage(); 
            
        EmailTemplate template;
        String offerOptionsHTML = '';
        Integer optionCount = 1;
        List<Decimal> advanceAmounts = new List<Decimal>();
        if(opp.ISO__c != null){
            template = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Cashio_Selected_Offers_to_Merchant'];
        }else{
            template = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Present_Selected_Offers_V2'];
        }
        //Set offer template for existing EMC Clients
        for(Offer__c offer :offers){
            String term = '';
            String additionalFunding = '';
			
            string paymentAmountLine = '$' + offer.Daily_Payment__c.format();
            if(offer.Type__c == 'Daily'){
                term = offer.Term__c.format();
                paymentAmountLine += ' will be the automatic payment deducted daily from your business bank account (Monday to Friday - not on weekends or bank holidays)';
            }else if(offer.Type__c == 'Weekly'){
                term = offer.Term__c.format(); //Todo - Might need to be changed later but not being used currently as of 1/26/18
                paymentAmountLine += ' will be the automatic payment deducted weekly from your business bank account';
            } else if(offer.Type__c == 'Bi-monthly') {
                paymentAmountLine += ' will be the automatic payment deducted twice a month from your business bank account';
            } else if(offer.Type__c == 'Monthly') {
                paymentAmountLine += ' will be the automatic payment deducted once a month from your business bank account';
            }
            paymentAmountLine += '<br/><br/>';
            if(offer.Additional_Funding__c != null){
                additionalFunding = offer.Additional_Funding__c.format();
            }
            offerOptionsHTML += '<p><div style="font-weight:bold; text-decoration: underline;">Funding Option #'+ String.valueOf(optionCount) + '</div><br/>';
            offerOptionsHTML += '$' + offer.Amount_Advanced__c.format() + ' deposited** in your business checking account<br/><br/>';
            offerOptionsHTML += '$' + offer.Payback_Amount__c.format() + ' total repayment amount<br/><br/>';
            //offerOptionsHTML += '$' + offer.Daily_Payment__c.format() + ' will be the automatic payment deducted daily from your business bank account (Monday to Friday - not on weekends or bank holidays)<br/><br/>';
            offerOptionsHTML += paymentAmountLine;
            offerOptionsHTML += '$' + offer.PSF_Charged__c.format() + ' Origination Fee (This amount will be debited from your bank account after you receive funding)<br/><br/>';
            offerOptionsHTML += '$' + offer.Lender_Fees__c.format() + ' Processing fee (this will be held-back from the funding amount) <br/><br/>';
            offerOptionsHTML += offer.Number_of_Payments__c + ' payments (Total of approximately ' + term + ' months until paid off)<br/><br/>';
            offerOptionsHTML += 'When balance reaches $' + additionalFunding + ' (50%), you will be eligible* to receive additional funding <br/><br/></p>';
            offerOptionsHTML += '<p><div style="font-weight:bold; text-decoration: underline;">This offer is based on this deal funding as a ' + offer.Position__c  + ' position offer.</div><br/>';
            //if (offer.Net_Funded__c != null) offerOptionsHTML += 'Net Funded: $ ' + offer.Net_Funded__c.format() + '<br/></p>';
            optionCount++;
            offer.Status__c = 'Presented';
            advanceAmounts.add(offer.Amount_Advanced__c);
        }

        // Sets the paramaters of the email
        String subject = '';
        if(template.subject.indexOf('{!Account.Full_Name_1__c}') > -1){
            subject = template.subject.replace('{!Account.Full_Name_1__c}', offers[0].Opportunity__r.Account.Full_Name_1__c);
        }
        
        if(template.subject.indexOf('{!Account.Name}') > -1){
            subject = template.subject.replace('{!Account.Name}', offers[0].Opportunity__r.Account.Name);
        }
        email.setSubject(subject);
        
        advanceAmounts.sort();
        Decimal highestAmt = advanceAmounts.get(advanceAmounts.size()-1);
        String htmlBody = template.HTMLValue;
        htmlBody = htmlBody.replace('<![CDATA[', '');
        htmlBody = htmlBody.replace(']]>', '');
        if(offers[0].Opportunity__r.ISO__r.Name != null){
            if(htmlBody.indexOf('{!ISO__c.Name}') > -1){
                htmlBody = htmlBody.replace('{!ISO__c.Name}', offers[0].Opportunity__r.ISO__r.Name);
            }
            else if(htmlBody.indexOf('{!Opportunity.ISO__c}') > -1){
                htmlBody = htmlBody.replace('{!Opportunity.ISO__c}', offers[0].Opportunity__r.ISO__r.Name);
            }
        }
        htmlBody = htmlBody.replace('{!Account.Name}', offers[0].Opportunity__r.Account.Name);
        htmlBody = htmlBody.replace('{!Highest_Amount}','<b>$' + highestAmt.format() + '</b>');
        htmlBody = htmlBody.replace('{!Offer_Options}', offerOptionsHTML);
        htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', offers[0].Opportunity__r.Owner.Name);
        if(offers[0].Opportunity__r.Final_Stips__c != null){
            htmlBody = htmlBody.replace('{!Opportunity.Final_Stips__c}', offers[0].Opportunity__r.Final_Stips__c.replace('\n', '<br />'));
        }else{
            htmlBody = htmlBody.replace('{!Opportunity.Final_Stips__c}', '');
        }
        if(offers[0].Opportunity__r.Owner.Phone != null){
            htmlBody = htmlBody.replace('{!Opportunity.OwnerPhone}', offers[0].Opportunity__r.Owner.Phone);
        }
        if(offers[0].Opportunity__r.Account.Full_Name_1__c != null) htmlBody = htmlBody.replace('{!Account.Full_Name_1__c}', offers[0].Opportunity__r.Account.Full_Name_1__c);
        if(offers[0].Opportunity__r.Account.Last_Name_1__c != null) htmlBody = htmlBody.replace('{!Account.Last_Name_1__c}', offers[0].Opportunity__r.Account.Last_Name_1__c);
        email.setHtmlBody(htmlBody);
		//emailMsg.htmlBody = htmlBody;
        //Sends it to the merchant only 
        if((opp.ISO__c != null && opp.ISO__r.Copy_Merchant_on_Approvals__c) || opp.ISO__c == null){
            //Sends the email to the merchant (Account Email And Opportunity Owner Email.)
            email.setToAddresses( new List<String>{offers[0].Opportunity__r.Account.Email__c});            
            email.setBccAddresses(new List<String>{offers[0].Opportunity__r.Owner.Email});
            emailList.add(email);
            //emailMsg.toAddresses.add(offers[0].Opportunity__r.Account.Email__c);
            //emailMsg.bccAddresses.add(offers[0].Opportunity__r.Owner.Email);
        }


        if(opp.ISO__c != null){
            template = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'Cashio_Selected_Offers_to_ISO'];
            
            offerOptionsHTML = '';
            optionCount = 1;
            advanceAmounts = new List<Decimal>();


            //Prepare the table options
            offerOptionsHTML += '<table style="width: 600px; border-collapse: collapse; font-size:1.08em;" border="0" cellspacing="0px" cellpadding="0px">';
            offerOptionsHTML += '    <tbody>';
            
            for(Offer__c offer :offers){
                offerOptionsHTML += '    <tr><td colspan="2"><div style="font-weight:bold; font-size:18px;">Funding Option No. '+ String.valueOf(optionCount) + '</div></td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2">&nbsp;<br /></td></tr>';
                offerOptionsHTML += '    <tr><td style="width:100px;"><strong>$' + offer.Amount_Advanced__c.format() + '</strong></td><td><strong>Advance Amount</strong></td></tr>';
                offerOptionsHTML += '    <tr><td>$' + offer.Payback_Amount__c.format() + '</td><td>Repayment Amount</td></tr>';
                offerOptionsHTML += '    <tr><td>' + offer.Factor_Rate__c.format() + '</td><td>Factor Rate</td></tr>';
                
                if(offer.Type__c == 'Daily'){
                    offerOptionsHTML += '    <tr><td>$' + offer.Daily_Payment__c.format() + '</td><td>Daily Payment</td></tr>';
                    offerOptionsHTML += '    <tr><td colspan="2"><em>Monday to Friday, excluding weekends or bank holidays</em></td></tr>';
                    offerOptionsHTML += '    <tr><td>&nbsp;</td><td>&nbsp;</td></tr>';
                    offerOptionsHTML += '    <tr><td>' + offer.Number_of_Payments__c.format() + '</td><td>Total Payments</td></tr>';
                    offerOptionsHTML += '    <tr><td>' + offer.Term__c.format() + '</td><td>Month Term</td></tr>';
                }else if(offer.Type__c == 'Weekly'){
                    offerOptionsHTML += '    <tr><td>$' + offer.Daily_Payment__c.format() + '</td><td>Weekly Payment</td></tr>';
                    offerOptionsHTML += '    <tr><td>' + offer.Number_of_Payments__c.format() + '</td><td>Total Payments</td></tr>';
                    offerOptionsHTML += '    <tr><td>' + offer.Term__c.format() + '</td><td>Month Term</td></tr>';
                }
                offerOptionsHTML += '    <tr><td>$' + offer.Lender_Fees__c.format() + '</td><td>Origination Fee</td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2"><em>Held back from the funding amount</em></td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2">&nbsp;</td></tr>';
                offerOptionsHTML += '    <tr><td><strong>$' + offer.Merchant_Net__c.format() + '</strong></td><td><strong>Merchant Net</strong></td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2">=========================</td></tr>';
                offerOptionsHTML += '    <tr><td><span style="font-weight:bold; font-size:18px;"><strong>$' + offer.Commission__c.format() + '</strong></span></td><td><strong>Your Commission</strong></td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2">&nbsp;<br /></td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2"><span style="font-weight:bold; text-decoration: underline;">This offer is based on this deal funding as a ' + offer.Position__c  + ' position offer.</span></td></tr>';
                offerOptionsHTML += '    <tr><td colspan="2">&nbsp;<br /></td></tr>';
                


                //Version 1
                //offerOptionsHTML += '<p><div style="font-weight:bold; font-size:18px;">Funding Option No.'+ String.valueOf(optionCount) + '</div><br/>';
                //offerOptionsHTML += '<table style="height: 252px; width: 450px; border-collapse: collapse;" border="0" cellspacing="0px" cellpadding="0px">';
                //offerOptionsHTML += '    <tbody>';
                //offerOptionsHTML += '    <tr><td><strong>$' + offer.Amount_Advanced__c.format() + '</strong></td><td><strong>Advance Amount</strong></td></tr>';
                //offerOptionsHTML += '    <tr><td>$' + offer.Payback_Amount__c.format() + '</td><td>Repayment Amount</td></tr>';
                //offerOptionsHTML += '    <tr><td>' + offer.Factor_Rate__c.format() + '</td><td>Factor Rate</td></tr>';
                //if(offer.Type__c == 'Daily'){
                //    offerOptionsHTML += '    <tr><td>$' + offer.Daily_Payment__c.format() + '</td><td>Daily Payment</td></tr>';
                //    offerOptionsHTML += '    <tr><td colspan="2"><em>Monday to Friday, excluding weekends or bank holidays</em></td></tr>';
                //    offerOptionsHTML += '    <tr><td>&nbsp;</td><td>&nbsp;</td></tr>';
                //    offerOptionsHTML += '    <tr><td>$' + offer.Number_of_Payments__c.format() + '</td><td>Total Payments</td></tr>';
                //    offerOptionsHTML += '    <tr><td>' + offer.Term__c.format() + ' Mo</td><td>Term</td></tr>';
                //}else if(offer.Type__c == 'Weekly'){
                //    offerOptionsHTML += '    <tr><td>$' + offer.Daily_Payment__c.format() + '</td><td>Weekly Payment</td></tr>';
                //    offerOptionsHTML += '    <tr><td>$' + offer.Number_of_Payments__c.format() + '</td><td>Total Payments</td></tr>';
                //    offerOptionsHTML += '    <tr><td>' + offer.Term__c.format() + '</td><td>Week Term</td></tr>';
                //}
                //offerOptionsHTML += '    <tr><td>$' + offer.Lender_Fees__c.format() + '</td><td>Processing Fee</td></tr>';
                //offerOptionsHTML += '    <tr><td colspan="2"><em>Held back from the funding amount</em></td></tr>';
                //offerOptionsHTML += '    <tr><td>&nbsp;</td><td>&nbsp;</td></tr>';
                //offerOptionsHTML += '    <tr><td><strong>$' + offer.Merchant_Net__c.format() + '</strong></td><td><strong>Merchant Net</strong></td></tr>';
                //offerOptionsHTML += '    <tr><td colspan="2">=============================</td></tr>';
                //offerOptionsHTML += '    <tr><td><span style="font-weight:bold; font-size:18px;"><strong>$' + offer.Commission__c.format() + '</strong></span></td><td><strong>Your Commission</strong></td></tr>';
                //offerOptionsHTML += '    </tbody>';
                //offerOptionsHTML += '</table>';

                //offerOptionsHTML += 'Advance Amount: <span style="font-weight:bold;">$' + offer.Amount_Advanced__c.format() + '</span><br/>';
                //offerOptionsHTML += 'Repayment Amount: $' + offer.Payback_Amount__c.format() + '<br/>';
                //offerOptionsHTML += 'Factor rate: ' + offer.Factor_Rate__c.format() + '<br/>';
                //offerOptionsHTML += 'Daily Payment: $' + offer.Daily_Payment__c.format() + '<br/>';

                //offerOptionsHTML += '<span style="font-style: italic;">&nbsp;&nbsp;&nbsp;Monday to Friday, excluding weekends or bank holidays</span><br/>';
                //offerOptionsHTML += 'Payments: $' + offer.Number_of_Payments__c.format() + '<br/>';
                //offerOptionsHTML += 'Term: ' + offer.Term__c.format() + ' Months<br/>';
                //offerOptionsHTML += 'Processing fee: $' + offer.Lender_Fees__c.format() + '<br/>';
                
                //offerOptionsHTML += '<span style="font-style: italic;">&nbsp;&nbsp;&nbsp;Held back from the funding amount</span><br/>';
                //offerOptionsHTML += 'Merchant Net: $' + offer.Merchant_Net__c.format() + '<br/>';
                //offerOptionsHTML += 'Your Commission: <span style="font-weight:bold;">$' + offer.Commission__c.format() + '</span><br/>';
                optionCount++;
                offer.Status__c = 'Presented';
                advanceAmounts.add(offer.Amount_Advanced__c);
            }
            offerOptionsHTML += '    </tbody>';
            offerOptionsHTML += '</table>';

            // Sets the paramaters of the email
            email2.setSubject(template.subject.replace('{!Account.Name}', offers[0].Opportunity__r.Account.Name));
            emailMsg.subject = template.subject.replace('{!Account.Name}', offers[0].Opportunity__r.Account.Name);
            advanceAmounts.sort();
            highestAmt = advanceAmounts.get(advanceAmounts.size()-1);
            htmlBody = template.HTMLValue;
            htmlBody = htmlBody.replace('<![CDATA[', '');
            htmlBody = htmlBody.replace(']]>', '');
            if(offers[0].Opportunity__r.ISO__r.Name != null){
                if(htmlBody.indexOf('{!ISO__c.Name}') > -1){
                    htmlBody = htmlBody.replace('{!ISO__c.Name}', offers[0].Opportunity__r.ISO__r.Name);
                }
                else if(htmlBody.indexOf('{!Opportunity.ISO__c}') > -1){
                    htmlBody = htmlBody.replace('{!Opportunity.ISO__c}', offers[0].Opportunity__r.ISO__r.Name);
                }
            }
            htmlBody = htmlBody.replace('{!Account.Name}', offers[0].Opportunity__r.Account.Name);
            htmlBody = htmlBody.replace('{!Highest_Amount}','<b>$' + highestAmt.format() + '</b>');
            htmlBody = htmlBody.replace('{!Offer_Options}', offerOptionsHTML);
            htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', offers[0].Opportunity__r.Owner.Name);
            if(offers[0].Opportunity__r.Final_Stips__c != null){
                htmlBody = htmlBody.replace('{!Opportunity.Final_Stips__c}', offers[0].Opportunity__r.Final_Stips__c.replace('\n', '<br />'));
            }else{
                htmlBody = htmlBody.replace('{!Opportunity.Final_Stips__c}', '');
            }
            if(offers[0].Opportunity__r.Owner.Phone != null){
                htmlBody = htmlBody.replace('{!Opportunity.OwnerPhone}', offers[0].Opportunity__r.Owner.Phone);
            }
            if(offers[0].Opportunity__r.Account.Full_Name_1__c != null) htmlBody = htmlBody.replace('{!Account.Full_Name_1__c}', offers[0].Opportunity__r.Account.Full_Name_1__c);
            if(offers[0].Opportunity__r.Account.Last_Name_1__c != null) htmlBody = htmlBody.replace('{!Account.Last_Name_1__c}', offers[0].Opportunity__r.Account.Last_Name_1__c);
            email2.setHtmlBody(htmlBody);
            email2.setToAddresses( new List<String>{offers[0].Opportunity__r.ISO__r.Contact_Email__c});
            email2.setBccAddresses(new List<String>{offers[0].Opportunity__r.Owner.Email});
            emailMsg.htmlBody = htmlBody;
            emailMsg.toAddresses.add(offers[0].Opportunity__r.ISO__r.Contact_Email__c);
            emailMsg.bccAddresses.add(offers[0].Opportunity__r.Owner.Email);
            emailList.add(email2);
        }
        if(opp.ISO__c != null){
            for(OrgWideEmailAddress owa : [select id, Address, DisplayName From OrgWideEmailAddress Where Address = 'info@cashio.com']){
                email.setOrgWideEmailAddressId(owa.id);
                email2.setOrgWideEmailAddressId(owa.id);
                
            }
        }
        if(!isEditPage){
            sendOffersEmail(emailList);
        }
        else{
            emailMsg.fromAddress = offers[0].Opportunity__r.ISO__r.Owner.email;// System.UserInfo.getUserEmail();
            emailMsg.to = emailMsg.convertListToString(emailMsg.toAddresses);
        	emailMsg.cc = emailMsg.convertListToString(emailMsg.ccAddresses);
        	emailMsg.bcc = emailMsg.convertListToString(emailMsg.bccAddresses);
        }
        return null;
    }
    
    public PageReference sendOffersEmail(Messaging.SingleEmailMessage[] emailList){
        Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
        ApexPages.Message myMsg;
        update offers;
        if(isEditPage == true){
            String emailErrors = '';
            for(Messaging.SendEmailResult rr:r){
                if(!rr.isSuccess()){
                    for(Messaging.SendEmailError error : rr.getErrors()){
                        emailErrors += error.getMessage() + ' ';
                    }
                }
            }
            if(emailErrors.length() > 0){
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error(s) Sending Email: ' + emailErrors);
                ApexPages.addMessage(myMsg);
                return null;
            }
            else{
                editEmailSuccess = true;
                myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Email Sent Successfully!');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
        }
 
        /*
        EmailTemplate template = [SELECT Id, Body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :emailTemplateName];

        String optionsHTML = '';
        Integer optionCount = 1;

        List<Decimal> advanceAmounts = new List<Decimal>();

        for(Offer__c offer :offers){
            optionsHTML += '<p><div style="font-weight:bold; text-decoration: underline;">Funding Option #'+ String.valueOf(optionCount) + '</div><br/>';
            optionsHTML += '$' + offer.Amount_Advanced__c.format() + ' deposited** in your business checking account<br/><br/>';
            optionsHTML += '$' + offer.Payback_Amount__c.format() + ' total repayment amount<br/><br/>';
            optionsHTML += '$' + offer.Daily_Payment__c.format() + ' will be the automatic payment deducted daily from your business bank account (Monday to Friday - not on weekends or bank holidays)<br/><br/>';
            optionsHTML += '$' + offer.PSF_Charged__c.format() + ' Origination Fee (This amount will be debited from your bank account after you receive funding)<br/><br/>';
            optionsHTML += '$' + offer.Lender_Fees__c.format() + ' Processing fee (this will be held-back from the funding amount) <br/><br/>';
            optionsHTML += offer.Number_of_Payments__c + ' payments (Total of approximately ' + offer.Term__c + ' months until paid off)<br/><br/>';
            optionsHTML += 'When balance reaches $' + offer.Additional_Funding__c.format() + ' (50%), you will be eligible* to receive additional funding <br/><br/></p>';
            //if (offer.Net_Funded__c != null) optionsHTML += 'Net Funded: $ ' + offer.Net_Funded__c.format() + '<br/></p>';
            optionCount++;
            offer.Status__c = 'Presented';
            advanceAmounts.add(offer.Amount_Advanced__c);
        }


        String[] toAddresses = new List<String>();
        toAddresses.add(offers[0].Opportunity__r.Account.Email__c);
        email.setToAddresses( toAddresses );

        String[] bccAddresses = new List<String>();
        bccAddresses.add(offers[0].Opportunity__r.Owner.Email);
        email.setBccAddresses(bccAddresses);

        // Sets the paramaters of the email
        String subject = template.subject.replace('{!Account.Full_Name_1__c}', offers[0].Opportunity__r.Account.Full_Name_1__c);
        email.setSubject(subject);
        
        advanceAmounts.sort();
        Decimal highestAmt = advanceAmounts.get(advanceAmounts.size()-1);
        String ownerName = offers[0].Opportunity__r.Owner.Name;
        String onwerPhone = offers[0].Opportunity__r.Owner.Phone;
        String accountName = offers[0].Opportunity__r.Account.Name;

        String htmlBody = template.HTMLValue;
        htmlBody = htmlBody.replace('<![CDATA[', '');
        htmlBody = htmlBody.replace('{!Account.Name}', accountName);
        htmlBody = htmlBody.replace('{!Highest_Amount}','<b>$' + highestAmt.format() + '</b>');
        htmlBody = htmlBody.replace('{!Offer_Options}', optionsHTML);
        htmlBody = htmlBody.replace('{!Opportunity.OwnerFullName}', ownerName);
        htmlBody = htmlBody.replace('{!Opportunity.OwnerPhone}', onwerPhone);
        if(offers[0].Opportunity__r.Account.Full_Name_1__c != null) htmlBody = htmlBody.replace('{!Account.Full_Name_1__c}', offers[0].Opportunity__r.Account.Full_Name_1__c);
        if(offers[0].Opportunity__r.Account.Last_Name_1__c != null) htmlBody = htmlBody.replace('{!Account.Last_Name_1__c}', offers[0].Opportunity__r.Account.Last_Name_1__c);
        htmlBody = htmlBody.replace(']]>', '');

        //String imageURL='/servlet/servlet.FileDownload?file=';
        //List<Document> documentList=[select name from document where Name='EMC Logo'];
        //if(documentList.size()>0) imageURL = imageURL + documentList[0].Id;
        
        //htmlBody = '<img src="http://i59.tinypic.com/2a68hn8.jpg"/><br/>' + htmlBody;
        email.setHtmlBody( htmlBody );
        */

        // Sends the email
        emailSuccess = true;
        
        return null;
    }
    
    public PageReference sendEditedOffersEmail(){
        ApexPages.Message myMsg;
        try{
            Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage(); 
            String[] toAddresses = emailMsg.convertStringToList(emailMsg.to);
            String[] ccAddresses = emailMsg.convertStringToList(emailMsg.cc);
            String[] bccAddresses = emailMsg.convertStringToList(emailMsg.bcc);
            System.debug(emailMsg.to);
            System.debug(emailMsg.convertStringToList(emailMsg.to));
            if(toAddresses != NULL && toAddresses.size() > 0){
                email.setToAddresses(toAddresses); 
			}
            if(ccAddresses != NULL && ccAddresses.size() > 0){
                email.setCcAddresses(ccAddresses);
            }
            if(bccAddresses != NULL && bccAddresses.size() > 0){
				email.setBccAddresses(bccAddresses);
            }
            email.setSubject(emailMsg.subject);
            email.setHtmlBody(emailMsg.htmlBody);
            System.debug(email);
            emailList.add(email);
            sendOffersEmail(emailList);
            PageReference OppPage = new PageReference(getParentPage());
                OppPage.setRedirect(true);
                return OppPage;
        }
        catch(Exception e){
            system.debug(e.getMessage());
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error(s) Sending Email: ' + e.getMessage());
            ApexPages.addMessage(myMsg);
        }
        return null;
    }

    public class ValidationObj{
        public String validationMessage {get; set;}
        public Offer__c offer{get; set;}
        public ValidationObj(Offer__c offer, String msg){
            this.offer = offer;
            this.validationMessage = msg;
        }
    }

}