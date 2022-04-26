public without sharing class ApplicationFormRedirectController {

    private DocuSign_Settings__c docusignSettings {get; set;}
    private String redirectUrl {get; set;}

    public ApplicationFormRedirectController() {

        docusignSettings = DocuSign_Settings__c.getOrgDefaults();
        String emcHost = docusignSettings.EMC_Host__c;
        String lendfullyHost = docusignSettings.Lendfully_Host__c;
        String emcApplicationFormPath = docusignSettings.EMC_Application_Form_Path__c;
        String lendfullyApplicationFormPath = docusignSettings.Lendfully_Application_Form_Path__c;
        String emcPowerformId = docusignSettings.DocuSign_Powerform_Id__c;


        String currentPowerFormId = ApexPages.currentPage().getParameters().get('pf');
        if(currentPowerFormId != null && currentPowerFormId == emcPowerformId) {
            redirectUrl = emcHost + emcApplicationFormPath;
        } else {
            redirectUrl = lendfullyHost + lendfullyApplicationFormPath;
        }

        String url = ApexPages.currentPage().getUrl();
        if(String.isNotBlank(url) && url.contains('?')) {
            redirectUrl += '?' + url.substringAfter('?');
        }
        if(currentPowerFormId != null && currentPowerFormId == emcPowerformId) {
            redirectUrl += redirectUrl.contains('?') ? '&' :'?';
            redirectUrl += 'emcsite=1';
        }

    }

    public PageReference redirect() {
        PageReference redirect = new PageReference(redirectUrl);
        redirect.setRedirect(true);
        return redirect;
    }

}