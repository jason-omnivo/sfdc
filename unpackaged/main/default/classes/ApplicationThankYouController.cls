public with sharing class ApplicationThankYouController {

    public Boolean isEmcSite { get; set; }

    public ApplicationThankYouController() {

        isEmcSite = false;
        string emcsite = ApexPages.currentPage().getParameters().get('emcsite');
        if(String.isNotBlank(emcsite) && emcsite == '1'){
            isEmcSite = true;
        }

    }

}