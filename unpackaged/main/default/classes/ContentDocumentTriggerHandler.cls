/**
 @Test Class: ContentVersionTriggerTest
 **/
public without sharing class ContentDocumentTriggerHandler {

    public void handleIsAfterInsert(Map<Id, ContentDocumentLink> contentDocumentLinkMap) {
        Set<Id> oppContentDocumentLinkIdSet = new Set<Id>();
        Set<Id> reportContentDocumentLinkIdSet = new Set<Id>();
//        system.debug('ContentDocumentLinkTrigger');

        for(ContentDocumentLink contentDocumentLink : [
                SELECT Id, LinkedEntity.Type, ContentDocument.FileExtension
                FROM ContentDocumentLink
                WHERE Id IN :ContentDocumentLinkMap.keySet()]) {
            if(contentDocumentLink.ContentDocument.FileExtension.toLowerCase() == 'pdf') {
                system.debug('ContentDocumentTriggerHandler');
                system.debug(contentDocumentLink.LinkedEntity.Type);
                if(contentDocumentLink.LinkedEntity.Type == 'dsfs__DocuSign_Status__c') {
                    oppContentDocumentLinkIdSet.add(contentDocumentLink.Id);
                } else if(contentDocumentLink.LinkedEntity.Type == 'LASERCA__Personal_Credit_Report__c') {
                    reportContentDocumentLinkIdSet.add(contentDocumentLink.Id);
                }
            }
        }

        if (!oppContentDocumentLinkIdSet.isEmpty()) {
            BoxFutureClass.uploadContentVersionList2Box(oppContentDocumentLinkIdSet);
        }
        if (!reportContentDocumentLinkIdSet.isEmpty()) {
            BoxFutureClass.uploadContentVersionReportListToBox(reportContentDocumentLinkIdSet);
        }

    }

}