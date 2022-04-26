@isTest(seeAllData=false)
public class OpportunityTriggerTestClass {

    @TestSetup
    static void setup() {
        TestDataGenerator.createBoxOAuthObject();
    }

    public static testmethod void testTrigger(){
        integer count = 5;
        List<ISO__c> liPartnersToInsert = New List<ISO__c>();
        List<User> liUsersToInsert = New List<User>();
        List<Profile> liProfilesToInsert = New List<Profile>([SELECT Id FROM Profile WHERE Name = 'Standard User']);
        List<Opportunity> liOppsToInsert = New List<Opportunity>();
        List<Account> liAccountsToInsert = New List<Account>();
        List<Offer__c> liOffersToInsert = New List<Offer__c>();
        List<Funder__c> liFundersToInsert = New List<Funder__c>();
        List<Contact> liContactsToInsert = New List<Contact>();
        List<Submissions__c> liSubmissionsToInsert = New List<Submissions__c>();
        //create users
        for(integer j=0; j<2; j++){
            liUsersToInsert.add(New User(
                FirstName = 'Test',
                LastName = 'User ' + j,
                Alias = 'test' + j,
                Username = 'test@testxxxxyyyy' + j + '.com',
                Email = 'test@test.com',
                CommunityNickname = 'test' + j,
                localesidkey='en_US',
                emailencodingkey='UTF-8',
                languagelocalekey='en_US',
                TimeZoneSidKey = 'America/New_York',
                ProfileId = liProfilesToInsert[0].Id
            ));
        }
        insert liUsersToInsert;
        //create accounts
        for(integer z=0; z < count; z++){
            liAccountsToInsert.add(New Account(Name = 'Test Account ' + z,
                                               DBA_Name__c = 'DBA ' + z,
                                               Industry__c = 'Attorneys',
                                               Industry_Cashio__c = 'Attorneys',
                                               Industry_As_stated_on_application__c = 'Attorneys',
                                               Industry_Type__c = 'Attorneys',
                                               Date_Business_Established__c = Date.today(),
                                               Partner_1_Credit_Score__c  = 700,
                                               Percent_of_Ownership_1__c = .5));
            
        }
        insert liAccountsToInsert;

        //create contacts
        for(integer q=0; q < count; q++){
            liContactsToInsert.add(New Contact(FirstName='Test ' + q,
                                                LastName='LastName ' + q,
                                                AccountId=liAccountsToInsert[q].Id));
        }
        insert liContactsToInsert;
        
        //create partners
        for(integer i=0; i < count; i++){
            liPartnersToInsert.add(New ISO__c(Name='Test ISO ' + i, 
                                              OwnerID = liUsersToInsert[0].Id));
        }
        for(integer i=0; i < count; i++){
            liPartnersToInsert.add(New ISO__c(Name='Test ISO ' + i + count, 
                                              OwnerID = liUsersToInsert[1].Id));
        }
        insert liPartnersToInsert;
        
        //create opportunities
        for(integer x=0; x < count; x++){
            liOppsToInsert.add(New Opportunity(Name='Test Opp ' + x,
                                                StageName='Application In',
                                                CloseDate=Date.today().addDays(x),
                                                AccountId=liAccountsToInsert[x].Id,
                                                ISO__c = liPartnersToInsert[x].Id,
                                                OwnerId = liUsersToInsert[1].Id));
        }
        insert liOppsToInsert;
        
        //insert funders
        for(integer n=0; n<count; n++){
            liFundersToInsert.add(New Funder__c(Name='Test Funder ' + n));
        }
        insert(liFundersToInsert);
        
        //insert offers
        for( integer y=0; y < count; y++){
            liOffersToInsert.add(New Offer__c(Opportunity__c=liOppsToInsert[y].Id,
                                              Funder__c=liFundersToInsert[y].Id));
        }
        insert liOffersToInsert;
        
        //insert submissions
        for(integer k=0; k<count; k++){
            liSubmissionsToInsert.add(New Submissions__c(
                Opportunity__c = liOppsToInsert[k].Id,
                Bank_Status__c = 'Funded'
            ));
        }
        insert liSubmissionsToInsert;
        System.assertEquals(count * 2, liPartnersToInsert.size());
        System.assertEquals(count, liOppsToInsert.size());
        test.startTest();
        //update opps
        for(Opportunity o : liOppsToInsert){
            o.StageName = 'Approved';
        }
        update liOppsToInsert;
        System.assertEquals(1, [SELECT Id, Approvals__c from ISO__c where Id =: liPartnersToInsert[0].Id].Approvals__c);
        delete liOppsToInsert[0];
        System.assertEquals(0, [SELECT Id, Approvals__c from ISO__c where Id =: liPartnersToInsert[0].Id].Approvals__c);
        undelete liOppsToInsert[0];
        System.assertEquals(1, [SELECT Id, Approvals__c from ISO__c where Id =: liPartnersToInsert[0].Id].Approvals__c);
        //Test re-parenting of ISO__c
        system.debug(liPartnersToInsert);
        liOppsToInsert[0].ISO__c = liOppsToInsert[1].ISO__c;
        update liOppsToInsert;
        system.debug(liPartnersToInsert);
        System.assertEquals(0, [SELECT Id, Approvals__c from ISO__c where Id =: liPartnersToInsert[0].Id].Approvals__c);
        System.assertEquals(2, [SELECT Id, Approvals__c from ISO__c where Id =: liPartnersToInsert[1].Id].Approvals__c);
        liOppsToInsert[0].ISO__c = liPartnersToInsert[Count + 1].Id;
        liOppsToInsert[1].StageName = 'Declined';
        liOppsToInsert[1].Reason_for_Decline__c = 'Fraud';
        liOppsToInsert[2].StageName = 'Closed Lost';
        liOppsToInsert[3].StageName = 'Funded';
        liOppsToInsert[3].Funded_On__c = Date.Today();
        liOppsToInsert[3].Funded_Amount__c = 150.00;
        update liOppsToInsert;
        System.assertEquals(1, [SELECT Declined__c FROM ISO__c WHERE Id =: liOppsToInsert[1].ISO__c Limit 1][0].Declined__c);
        System.assertEquals(1, [SELECT Revive__c FROM ISO__c WHERE Id =: liOppsToInsert[2].ISO__c Limit 1][0].Revive__c);
        System.assertEquals(1, [SELECT Funded__c FROM ISO__c WHERE Id =: liOppsToInsert[3].ISO__c Limit 1][0].Funded__c);
        test.stopTest();
    }
}