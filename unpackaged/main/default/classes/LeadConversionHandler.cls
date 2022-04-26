/* The Handler will  update 'Description' Field of Opportunity Object that gets created after Lead Conversion
 *  by the Description field of Lead.
 *
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0               Ajay Singh Solanki                 19/06/2013                         Initial Draft
 */  

public with sharing class LeadConversionHandler {
    
    
    /* The method will update 'Description' Field of Opportunity Object that gets created after Lead Conversion
     * by the Description field of Lead.
     */
    public void mapFieldsToOpportunity_Account_Contact(List<Lead> pListNewLeads, Map<Id, Lead> oldLeadMap){
        //Map will contain Opportunity Id and Lead record related to that Opportunity.
        Map<Id, Lead> mapIdOpportunityWithLead = new Map<Id, Lead>();
        
        //Map will contain Account Id and Lead record related to that Account.
        Map<Id, Lead> mapIdAccountWithLead = new Map<Id, Lead>();
        
        //Map will contain Contact Id and Lead record related to that Account.
        Map<Id, Lead> mapIdContactWithLead = new Map<Id, Lead>();
        
        //List will contain Opportunities whose Description field gets Updated.
        List<Opportunity> lstIdOfOpportunityToUpdate = new List<Opportunity>();
        
        //List will contain Accounts  whose Description field gets Updated.
        List<Account> lstIdOfAccountToUpdate = new List<Account>();
        
        //List will contain Contacts  whose Description field gets Updated.
        List<Contact> lstIdOfContactToUpdate = new List<Contact>();
        
        for(Lead leadRecord : pListNewLeads){
            //Checking if the Lead is Converted and has Opportunity.
            if(leadRecord.IsConverted && !oldLeadMap.get(leadRecord.Id).IsConverted){
                mapIdAccountWithLead.put(leadRecord.ConvertedAccountId, leadRecord);
                mapIdContactWithLead.put(leadRecord.ConvertedContactId, leadRecord);
                if(leadRecord.ConvertedOpportunityId <> null)
                    mapIdOpportunityWithLead.put(leadRecord.ConvertedOpportunityId, leadRecord);                    
            }//End if.
        }//End for.
        for(Opportunity opportunityRecord : [Select Id,
                                                                                Description
                                                                    From Opportunity
                                                                    Where Id IN : mapIdOpportunityWithLead.keySet()]){
            opportunityRecord.Description = mapIdOpportunityWithLead.get(opportunityRecord.Id).Description;    //assigning Lead Description field value.  
            opportunityRecord.Annual_Revenue__c = mapIdOpportunityWithLead.get(opportunityRecord.Id).AnnualRevenue; //assigning Lead Annual Revenue field value.
            lstIdOfOpportunityToUpdate.add(opportunityRecord);         //adding opportunityRecord into the List that gets Updated.
        }//End for.
        
        for(Account accountRecord :  [Select Id,
                                                                     Description
                                                         From Account
                                                         Where Id IN : mapIdAccountWithLead.keySet()]){
            accountRecord.Description = mapIdAccountWithLead.get(accountRecord.Id).Description;         //assigning Lead Description field value.
            accountRecord.AccountSource = mapIdAccountWithLead.get(accountRecord.Id).LeadSource ;   //assigning Lead Source field value.
            accountRecord.Email__c = mapIdAccountWithLead.get(accountRecord.Id).Email;                      //assigning Email field value.
            lstIdOfAccountToUpdate.add(accountRecord);         //adding accountRecord  into the List that gets Updated.
        }//End for.    
        
        for(Contact contactRecord :  [Select Id,
                                                                     ReferredBy__c
                                                         From Contact
                                                         Where Id IN : mapIdContactWithLead.keySet()]){
            contactRecord.ReferredBy__c = mapIdContactWithLead.get(contactRecord.Id).Referred_By__c ;    //assigning Lead Referred By field value.
            lstIdOfContactToUpdate.add(contactRecord);         //adding contactRecord  into the List that gets Updated.
        }//End for.    
        
        
        if(!lstIdOfOpportunityToUpdate.isEmpty())
            update(lstIdOfOpportunityToUpdate);                                 //updating the List.
            
        if(!lstIdOfAccountToUpdate.isEmpty()){
            if(Schema.sObjectType.Account.isUpdateable()){
                update(lstIdOfAccountToUpdate);                                       //updating the List.
            }
        }
        if(!lstIdOfContactToUpdate.isEmpty()){
            if(Schema.sObjectType.Contact.isUpdateable()){
                update(lstIdOfContactToUpdate);                                       //updating the List.
            }
        }
    }//End mapFieldsToOpportunity_Account_Contact method.

}//End LeadConversionHandler.