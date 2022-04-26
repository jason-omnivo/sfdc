trigger PrimaryContactCopy on Opportunity(after insert, after update) {

 if(!ContactCopyUtil.isRecursive)

    ContactCopyUtil.copyFrom(Trigger.newmap.keyset());
 }