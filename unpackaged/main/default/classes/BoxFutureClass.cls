global without sharing class BoxFutureClass {
        @future(callout=true)
        public static void createFolder(set<ID> AccIds) {
            Map<String, String> boxFRUPMap = new Map<String, String>();
            for (box__FRUP__c bF : [SELECT box__Folder_ID__c,box__Record_ID__c FROM box__FRUP__c WHERE box__Object_Name__c = 'Account' AND box__Record_ID__c IN :AccIds]) {
                boxFRUPMap.put(bF.box__Record_ID__c, bF.box__Folder_ID__c);
            }
            for (Account acc : [Select id,name from account where id IN :AccIds]) {
                box.Toolkit boxToolkit ;
                if (!boxFRUPMap.containsKey(acc.Id)) {
                    boxToolkit = new box.Toolkit();
                    String accountFolderId = boxToolkit.createFolderForRecordId(acc.Id, null, true);
                    boxToolkit.commitChanges();
                }
            }
        }

        @future(callout=true)
        public static void createFolderForOpp(set<ID> oppIds) {
            Map<String, String> boxFRUPMap = new Map<String, String>();
            for (box__FRUP__c bF : [SELECT box__Folder_ID__c,box__Record_ID__c FROM box__FRUP__c WHERE box__Object_Name__c = 'Opportunities' AND box__Record_ID__c IN :oppIds]) {
                boxFRUPMap.put(bF.box__Record_ID__c, bF.box__Folder_ID__c);
            }

            for (Opportunity opp : [Select id,name from Opportunity where id IN :oppIds]) {
                String oppFolderId = null;
                box.Toolkit boxToolkit = new box.Toolkit();
                if (!boxFRUPMap.containsKey(opp.Id)) {
                    /* oppFolderId = boxToolkit.createFolderForRecordId(opp.Id,null, true);
                boxToolkit.commitChanges();
                System.debug('mostRecentError: ' + boxToolkit.mostRecentError);*/

                    Box_OAuth_Object__c boxAuthObj = [
                            SELECT Auth_Endpoint__c, Auth_Token__c,
                                    Auth_Token_Expires__c, Refresh_Token__c,
                                    Refresh_Token_Expires__c, Client_Id__c, Client_Secret__c
                            FROM Box_OAuth_Object__c
                            ORDER BY Auth_Token_Expires__c DESC
                    ][0];

//                    boxToolkit.createFolderForRecordId
                    String parentFolderId = '2737618028';
                    if(Utils.runningInASandbox()) {
                        parentFolderId = '129815432093';
                    }

                    string folderId = boxToolkit.createFolder(opp.Name, parentFolderId, boxAuthObj.Auth_Token__c);
                    System.debug('folderId: ' + folderId);
                    box__FRUP__c frup = new box__FRUP__c();
                    frup.box__Folder_ID__c = folderId;
                    frup.box__Object_Name__c = 'Opportunity';
                    frup.box__Record_ID__c = opp.Id;
                    insert frup;
                    System.debug('frup: ' + frup);
                }
            }

        }

        @future(callout=true)
        public static void uploadContentVersionList2Box(set<Id> contentDocumentLinkIdList) {
            for (Id cdll : contentDocumentLinkIdList) {

                ContentDocumentLink contentDocumentLink = [SELECT Id, LinkedEntity.Type, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE Id = :cdll];
                List<ContentVersion> contentVersionList =  [SELECT Id, ContentDocumentId, VersionData, VersionNumber FROM ContentVersion
                                WHERE ContentDocumentId = :contentDocumentLink.ContentDocumentId AND IsLatest = true];

                String oppId = '';
                String envelopeStatus = '';
                if(contentDocumentLink.LinkedEntity.Type == 'dsfs__DocuSign_Status__c') {
                    for(dsfs__DocuSign_Status__c docuSignStatus :
                                [SELECT Id, dsfs__Opportunity__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE Id = :contentDocumentLink.LinkedEntityId]) {
                        oppId = docuSignStatus.dsfs__Opportunity__c;
                        envelopeStatus = docuSignStatus.dsfs__Envelope_Status__c;
                        System.debug(oppId);
                    }

                }
                if(envelopeStatus != 'Completed') {
                    return;
                }

                Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Id = :oppId];

                box.Toolkit boxToolkit = new box.Toolkit();
                string folderId = boxToolkit.getFolderIdByRecordId(opp.Id);
                blob uploadContent = null;
                String versionNumber = '';
                for(ContentVersion contentVersion : contentVersionList) {
                    uploadContent = contentVersion.VersionData;
                    versionNumber = contentVersion.VersionNumber;
                }
                string fileName = 'App_' + opp.Name;
                if(String.isNotBlank(versionNumber) && versionNumber != '1') {
                    fileName += ' - v' + versionNumber;
                }
                fileName += '.pdf';

                blob base64EncodeFile = BoxAuthUtility.base64EncodeFileContentForBox(uploadContent, fileName.trim());
                String uploadEndPointURL = 'https://upload.box.com/api/2.0/files/content?parent_id=' + folderId;
                String boundary = '----------------------------foo_bar_baz';

                HttpRequest requestUpload = new HttpRequest();
                requestUpload.setBodyAsBlob(base64EncodeFile);
                requestUpload.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
                requestUpload.setHeader('Content-Length', String.valueof(requestUpload.getBodyAsBlob().size()));

                String accessToken = BoxAuth.authInfo.Auth_Token__c;
                requestUpload.setHeader('Authorization', 'Bearer ' + accessToken.trim());

                requestUpload.setMethod('POST');
                requestUpload.setEndpoint(uploadEndPointURL);
                requestUpload.setTimeout(120000);

                //Send request to Box
                Http hpPutUpload = new Http();
                HttpResponse responseFileUpload;
                String jsonFileResUpload;
                system.debug('requestupload >>' + requestUpload);
                Integer statusCode;

                if (!Test.isRunningTest()) {
                    responseFileUpload = hpPutUpload.send(requestUpload);
                    statusCode = responseFileUpload.getStatusCode();
                }
            }
        }

    @future(callout=true)
        public static void uploadContentVersionReportListToBox(set<Id> reportContentDocumentLinkIdSet) {
            for (Id reportIdLink : reportContentDocumentLinkIdSet) {
                ContentDocumentLink contentDocumentLink =
                    [SELECT Id, LinkedEntity.Type, ContentDocumentId, LinkedEntityId
                     FROM ContentDocumentLink
                     WHERE Id = :reportIdLink];
                List<ContentVersion> contentVersionList =
                    [SELECT Id, ContentDocumentId, VersionData, VersionNumber
                     FROM ContentVersion
                     WHERE ContentDocumentId = :contentDocumentLink.ContentDocumentId
                     AND IsLatest = true];

                String opportunityId = '';

                LASERCA__Personal_Credit_Report__c personalCreditReport =
                    [SELECT Id, LASERCA__Opportunity__c, LASERCA__File_Number__c
                     FROM LASERCA__Personal_Credit_Report__c
                     WHERE Id = :contentDocumentLink.LinkedEntityId];

                opportunityId = personalCreditReport.LASERCA__Opportunity__c;
                Opportunity opportunity =
                    [SELECT Id, Name FROM Opportunity WHERE Id = :opportunityId];

                box.Toolkit boxToolkit = new box.Toolkit();
                String folderId = boxToolkit.getFolderIdByRecordId(opportunity.Id);
                blob uploadContent = null;
                String versionNumber = '';

                for (ContentVersion contentVersion : contentVersionList) {
                    uploadContent = contentVersion.VersionData;
                    versionNumber = contentVersion.VersionNumber;
                }

                String fileName = 'Credit Report - ' + opportunity.Name + ' - ' + personalCreditReport.LASERCA__File_Number__c;

                if (String.isNotBlank(versionNumber) && versionNumber != '1') {
                    fileName += ' - v' + versionNumber;
                }
                fileName += '.pdf';

                blob base64EncodeFile = BoxAuthUtility.base64EncodeFileContentForBox(uploadContent, fileName.trim());
                String uploadEndPointURL = 'https://upload.box.com/api/2.0/files/content?parent_id=' + folderId;
                String boundary = '----------------------------foo_bar_baz';

                HttpRequest requestUpload = new HttpRequest();
                requestUpload.setBodyAsBlob(base64EncodeFile);
                requestUpload.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
                requestUpload.setHeader('Content-Length', String.valueof(requestUpload.getBodyAsBlob().size()));

                String accessToken = BoxAuth.authInfo.Auth_Token__c;
                requestUpload.setHeader('Authorization', 'Bearer ' + accessToken.trim());

                requestUpload.setMethod('POST');
                requestUpload.setEndpoint(uploadEndPointURL);
                requestUpload.setTimeout(120000);

                //Send request to Box
                Http hpPutUpload = new Http();
                HttpResponse responseFileUpload;
//                String jsonFileResUpload;
                Integer statusCode;

                if (!Test.isRunningTest()) {
                    responseFileUpload = hpPutUpload.send(requestUpload);
                    statusCode = responseFileUpload.getStatusCode();
                }
            }
        }
    }