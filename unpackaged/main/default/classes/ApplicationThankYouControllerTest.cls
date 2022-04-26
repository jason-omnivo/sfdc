@IsTest
private class ApplicationThankYouControllerTest {
    @IsTest
    static void test() {

        PageReference pageReference = Page.ApplicationFormThankYou;
        pageReference.getParameters().put('emcsite','1');
        Test.setCurrentPage(pageReference);
        ApplicationThankYouController applicationThankYouController = new ApplicationThankYouController();

    }
}