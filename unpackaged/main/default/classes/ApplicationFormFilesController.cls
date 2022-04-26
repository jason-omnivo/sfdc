/***********************************************************************************************
* Author: Techila Global Services Pvt Ltd.
* Class Name: ApplicationFormFilesController
* Created Date: 15/01/2020
* Description: class used to handle upload document in box.
************************************************************************************************/

public class ApplicationFormFilesController {

   /* public string fileInputTitle1 {get; set;}
    public Blob fileInputVersionData1 {get; set;}
    public string fileInputTitle2 {get; set;}
    public Blob fileInputVersionData2 {get; set;}
    public string fileInputTitle3 {get; set;}
    public Blob fileInputVersionData3 {get; set;}*/
    public string monthName1 {get; set;}
    public string monthName2 {get; set;}
    public string monthName3 {get; set;}
    public string monthName4 {get; set;}
    public string monthName5 {get; set;}
    public string monthName6 {get; set;}
    public string monthName7 {get; set;}
    public string monthName8 {get; set;}
    public string monthName9 {get; set;}
    public string tname {get; set;}
    public List<String> bankStatementName{get; set;}
        
    public id accoundRecordId; 

    //added by pratap
    public string boxParentFolder{set;get;}
    public Box_OAuth_Object__c objBoxOAuthSetting{set;get;}
   
    public Map<Integer,String> monthNameMap {get; set;}
    public sObject objLinkedEntity { get; set; }

    public Boolean isEmcSite { get; set; }
    
    public ApplicationFormFilesController(){

        isEmcSite = false;
        string emcSite = ApexPages.currentPage().getParameters().get('emcsite');
        if(String.isNotBlank(emcSite) && emcSite == '1'){
            isEmcSite = true;
        }

        system.debug('Test Inside');
        if(ApexPages.currentPage().getParameters().get('id') != null){
            system.debug('2.1');
            accoundRecordId = id.valueOf(ApexPages.currentPage().getParameters().get('id'));
        }else if(ApexPages.currentPage().getParameters().get('envelopeId') != null){
            system.debug('3.1');
            String envelopeId = ApexPages.currentPage().getParameters().get('envelopeId');
            system.debug('3.2');
            system.debug(envelopeId);
            List<dsfs__DocuSign_Status__c> docusignStatusList = [SELECT Id, dsfs__Opportunity__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c =: envelopeId];
            system.debug('3.3');
            system.debug(docusignStatusList);
            if(docusignStatusList.size()>0){
                system.debug('3.4');
                //oppRecordId=[SELECT Id FROM Opportunity WHERE Id =: docusignStatusList[0].dsfs__Opportunity__c].accountId;
                accoundRecordId = [SELECT accountId FROM Opportunity WHERE Id =: docusignStatusList[0].dsfs__Opportunity__c].accountId;
                system.debug([SELECT accountId FROM Opportunity WHERE Id =: docusignStatusList[0].dsfs__Opportunity__c]);
                system.debug(accoundRecordId);
                system.debug('3.5');
            }
        }
        System.debug('accoundRecordId '+accoundRecordId);

        //this is used to display last 3 month in vf page for upload bank statements.
        monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February',3=>'March',
            4=>'April',
            5=>'May',
            6=>'June',
            7=>'July',
            8=>'August',
            9=>'September',
            10=>'October',
            11=>'November',
            12=>'December'
            };
            monthName1=monthNameMap.get(system.today().addMonths(-1).month())+'-'+system.today().addMonths(-1).year();
            monthName2=monthNameMap.get(system.today().addMonths(-2).month())+'-'+system.today().addMonths(-2).year();
            monthName3=monthNameMap.get(system.today().addMonths(-3).month())+'-'+system.today().addMonths(-3).year();
            monthName4=monthNameMap.get(system.today().addMonths(-4).month())+'-'+system.today().addMonths(-4).year();
            monthName5=monthNameMap.get(system.today().addMonths(-5).month())+'-'+system.today().addMonths(-5).year();
            monthName6=monthNameMap.get(system.today().addMonths(-6).month())+'-'+system.today().addMonths(-6).year();
            monthName7=monthNameMap.get(system.today().addMonths(-7).month())+'-'+system.today().addMonths(-7).year();
            monthName8=monthNameMap.get(system.today().addMonths(-8).month())+'-'+system.today().addMonths(-8).year();
            monthName9=monthNameMap.get(system.today().addMonths(-9).month())+'-'+system.today().addMonths(-9).year();
            bankStatementName = new List<String>();
            bankStatementName.add(monthName1);
            bankStatementName.add(monthName2);
            bankStatementName.add(monthName3);
            bankStatementName.add(monthName4);
            bankStatementName.add(monthName5);
            bankStatementName.add(monthName6);
            bankStatementName.add(monthName7);
            bankStatementName.add(monthName8);
            bankStatementName.add(monthName9);


        try{
            objBoxOAuthSetting = BoxAuthUtility.authInfo;
            tname=objBoxOAuthSetting.Auth_Token__c;
            system.debug('.Auth_Token__c>>'+objBoxOAuthSetting.Auth_Token__c+' tname :'+tname);
            System.debug(String.isBlank(tname) + ' :' +tname+':');
            System.debug('accoundRecordId '+accoundRecordId);

            if(accoundRecordId!=null){
                string  query ='SELECT Id, Name FROM Opportunity';
                    query += ' WHERE accountid= \''+accoundRecordId+'\'';
                    query +=' ORDER BY createddate DESC LIMIT 1';

            
                objLinkedEntity = Database.Query(query);

                List<String> folderHierarchy = new List<String>();
                folderHierarchy.add('Statements');
                folderHierarchy.add('Opportunities');
                folderHierarchy.add(String.valueOf(objLinkedEntity.get('Name')));
                folderHierarchy.add(String.valueOf('Statements').replace('/',''));
                boxParentFolder = '0';
                for(String folderName : folderHierarchy){
                    boxParentFolder = BoxAuthUtility.getBoxFolderId(folderName,boxParentFolder);
                }  
                system.debug('final boxParentFolder :'+boxParentFolder);

            }
            //code END
        }catch(Exception e){
            UtilityClass.sendErrorMail(String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }  
        if(tname==null || tname==''){
           UtilityClass.sendErrorMail('Box Setting Missing', 'First Connect With Box','User Unable to upload Files', 'Information');  
        }
            
    }

    public void init() {
        if (objLinkedEntity != null) {
            System.debug('objLinkedEntity data');
            System.debug(objLinkedEntity);
            objLinkedEntity.put('Form_Step_4_Application_Sent__c', true);
            update objLinkedEntity;
        }
    }

/* NO loger required this mwthod as we are direrctly sending files to box from page .

    public Pagereference storeFiles(){

        List<ContentVersion> fileInputList = new List<ContentVersion>();
        ContentVersion fileInput;

        if(fileInputVersionData1 != null && !String.isBlank( EncodingUtil.base64Encode(fileInputVersionData1) ) ){
            fileInput = new ContentVersion();
            fileInput.VersionData = fileInputVersionData1;
            fileInput.Title = fileInputTitle1;
            fileInput.PathOnClient = fileInputTitle1;
            fileInputList.add(fileInput);
        }

        if(fileInputVersionData2 != null && !String.isBlank( EncodingUtil.base64Encode(fileInputVersionData2) ) ){
            fileInput = new ContentVersion();
            fileInput.VersionData = fileInputVersionData2;
            fileInput.Title = fileInputTitle2;
            fileInput.PathOnClient = fileInputTitle2;
            fileInputList.add(fileInput);
        }

        if(fileInputVersionData3 != null && !String.isBlank( EncodingUtil.base64Encode(fileInputVersionData3) ) ){
            fileInput = new ContentVersion();
            fileInput.VersionData = fileInputVersionData3;
            fileInput.Title = fileInputTitle3;
            fileInput.PathOnClient = fileInputTitle3;
            fileInputList.add(fileInput);
        }
        
        if(fileInputList.size() > 0){
            insert fileInputList;
        }

        Set<id> cvIdSet = new Set<id>();        
        
        for(ContentVersion objCV : fileInputList){
            cvIdSet.add(objCV.id);
        }        

        fileInputList = new List<ContentVersion>();
        if(cvIdSet.size() > 0){
            fileInputList = [select id, ContentDocumentId from ContentVersion where id in :cvIdSet];        
        }
      
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();

        for(ContentVersion objCv : fileInputList){
            ContentDocumentLink cdlObj = new ContentDocumentLink();
            cdlObj.LinkedEntityId = accoundRecordId;
            cdlObj.ContentDocumentId = objCv.ContentDocumentId;
            cdlObj.Visibility = 'AllUsers';
            cdlObj.ShareType = 'V'; 
            cdlList.add(cdlObj);            
        }
        if(cdlList.size() > 0){
            insert cdlList;
            BoxAuthUtility.uploadFilesInBoxForAll(cvIdSet);
        }

        fileInput = null;
        fileInputList = null;
        fileInputVersionData1 = null;
        fileInputVersionData2 = null;
        fileInputVersionData3 = null;

        PageReference redirectPage = Page.ApplicationFormThankYou;
        redirectPage.setRedirect(true);
        redirectPage.getParameters().put('id', ApexPages.currentPage().getParameters().get('id') );
        return redirectPage;
    }
*/
    public Pagereference ifAccountIdNull(){
        if(accoundRecordId == null){
            PageReference redirectPage = Page.ApplicationForm;
            redirectPage.setRedirect(true);
            return redirectPage;
        }
        else {
            return null;
        }
    }
}