@isTest
public class ApplicationFormFilesControllerTest {
    //
    //@isTest
     @isTest(SeeAllData=true)
     static  void testMethod1(){

        Account acc1 = new Account();
        acc1.Name='Account Name';
        acc1.DBA_Name__c='DBA Name';
        insert acc1;
        Opportunity opp=new Opportunity();
		opp.Name='Test Oppty';
		Opp.StageName='Prospecting';
		opp.CloseDate=system.today();
		opp.Accountid=acc1.id;
		insert opp;

        Blob file1 = Blob.valueOf('Test1'.repeat(100));
        Blob file2 = Blob.valueOf('Test2'.repeat(100));
        Blob file3 = Blob.valueOf('Test3'.repeat(100));


        System.currentPageReference().getParameters().put('id', acc1.id);
        ApplicationFormFilesController afcObj= new ApplicationFormFilesController();

        /*afcObj.fileInputTitle1='test1.docx';

afcObj.fileInputVersionData1= file1;

        afcObj.fileInputTitle2='test2.docx';
        afcObj.fileInputVersionData2= file2;

        afcObj.fileInputTitle3='test3.docx';
        afcObj.fileInputVersionData3= file3;

        afcObj.storeFiles();

 dsfs__DocuSign_Status__c docsign = new dsfs__DocuSign_Status__c();
        docsign.dsfs__DocuSign_Envelope_ID__c ='80579003-947B-482F-95B2-ABE6F91AA046';
        docsign.dsfs__Subject__c='Please DocuSign: EMC Funding Application.pdf';
        docsign.dsfs__Opportunity__c=opp.id;
        docsign.dsfs__Company__c=a.id;
        insert docsign;
*/
        afcObj.accoundRecordId=null;
        afcObj.ifAccountIdNull();
    }
    
//     @isTest(SeeAllData=true)
    @isTest
     static void testMethod2(){
        
        Account acc1 = new Account();
        acc1.Name='Account Name';
        acc1.DBA_Name__c='DBA Name';
        insert acc1;
        Opportunity opp=new Opportunity();
		opp.Name='Test Oppty';
		Opp.StageName='Prospecting';
		opp.CloseDate=system.today();
		opp.Accountid=acc1.id;
		insert opp;
        
         dsfs__DocuSign_Status__c docsign = new dsfs__DocuSign_Status__c();
        docsign.dsfs__DocuSign_Envelope_ID__c ='80579003-947B-482F-95B2-ABE6F91AA046';
        docsign.dsfs__Subject__c='Please DocuSign: EMC Funding Application.pdf';
        docsign.dsfs__Opportunity__c=opp.id;
        docsign.dsfs__Company__c=acc1.id;
        insert docsign;
        
                 Box_OAuth_Object__c boxAuthObj = new Box_OAuth_Object__c();
        boxAuthObj.Name = 'EMC App2';
        boxAuthObj.Auth_Endpoint__c = 'https://api.box.com/oauth2/';
        boxAuthObj.Auth_Token__c = 'kT9goswrfLFRb1fUeYBtIbja3hMbg3Da';
        boxAuthObj.Refresh_Token__c = 'kiucGs4Rny0XxfOaoFRXTvNN5pRJX54H55fMvs5yuuBvISeFHSNqRIKilC3KRH60';
        boxAuthObj.Auth_Token_Expires__c = Datetime.now().addSeconds(3600);
        boxAuthObj.Refresh_Token_Expires__c = Datetime.now().addDays(60);
        boxAuthObj.Client_Id__c = 'erhf4g9v1el82jqesfd9dtt2h1vyc14e';
        boxAuthObj.Client_Secret__c  = 'a1qUgMkcPFG1sNGXzpTzZkX0uo6k09wa';
        insert boxAuthObj;

       
        System.currentPageReference().getParameters().put('envelopeId', docsign.dsfs__DocuSign_Envelope_ID__c);
        ApplicationFormFilesController afcObj= new ApplicationFormFilesController();
        
     
 		
         
        afcObj.accoundRecordId=null;
        afcObj.ifAccountIdNull();
    }


}