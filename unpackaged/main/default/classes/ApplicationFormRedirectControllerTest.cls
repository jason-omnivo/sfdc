@IsTest
public with sharing class ApplicationFormRedirectControllerTest {

    @TestSetup
    public static void setup() {
        TestDataGenerator.createDocuSignSettings();
    }

    @IsTest
    public static void test() {

        String powerformId = DocuSign_Settings__c.getOrgDefaults().DocuSign_Powerform_Id__c;
        PageReference pageRef = Page.ApplicationFormRedirect;
        pageRef.getParameters().put('pf', powerformId);
        Test.setCurrentPage(pageRef);

        ApplicationFormRedirectController controller = new ApplicationFormRedirectController();

        controller.redirect();
    }

}