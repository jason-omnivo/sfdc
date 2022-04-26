/**
 @Test Class: ContentVersionTriggerTest
 **/
public without sharing class ContentVersionTriggerHandler {

    public void handleIsAfterInsert(Map<Id, ContentVersion> contentVersionMap) {
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> contentDocumentLinkIdSet = new Set<Id>();
        Set<Id> reportContentDocumentLinkIdSet = new Set<Id>();
//        system.debug('ContentVersionTrigger');

        for(ContentVersion contentVersion : [SELECT Id, ContentDocumentId, FileExtension FROM ContentVersion WHERE Id IN :contentVersionMap.keySet()]) {
            if (contentVersion.FileExtension.toLowerCase() == 'pdf') {
                contentDocumentIdSet.add(contentVersion.ContentDocumentId);
            }
        }

        if(contentDocumentIdSet.isEmpty()) {
            return;
        }

        for(ContentDocumentLink contentDocumentLink : [SELECT Id, LinkedEntity.Type FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIdSet]) {
            system.debug(contentDocumentLink.LinkedEntity.Type);

            if (contentDocumentLink.LinkedEntity.Type == 'dsfs__DocuSign_Status__c') {
                contentDocumentLinkIdSet.add(contentDocumentLink.Id);
            } else if(contentDocumentLink.LinkedEntity.Type == 'LASERCA__Personal_Credit_Report__c') {
                reportContentDocumentLinkIdSet.add(contentDocumentLink.Id);
            }
        }
        system.debug(reportContentDocumentLinkIdSet);

        if (!contentDocumentLinkIdSet.isEmpty()) {
            BoxFutureClass.uploadContentVersionList2Box(contentDocumentLinkIdSet);
        }
        if (!reportContentDocumentLinkIdSet.isEmpty()) {
            BoxFutureClass.uploadContentVersionReportListToBox(reportContentDocumentLinkIdSet);
        }
    }

}