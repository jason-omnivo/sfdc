trigger DocSignAttachmentTrigger on Attachment (after insert) {
    BoxAuthUtility.uploadFilesInBoxForAttachment(Trigger.newMap.keyset());
}