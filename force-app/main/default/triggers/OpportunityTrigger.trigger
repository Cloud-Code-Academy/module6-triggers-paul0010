trigger OpportunityTrigger on Opportunity (before delete, before update){
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        //Get Account Ids from Opportunities.
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity oppAccountIds : Trigger.new) {
            accountIds.add(oppAccountIds.AccountId);
        }
        //Get CEO Contacts from Account Ids
        List<Contact> ceoContacts = [
            SELECT Id, Title, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds AND Title = 'CEO'
        ];
        //Map Account Id with Contact.
        Map<Id,Contact> primaryContacts = new Map<Id,Contact>();
        for (Contact ceoContact : ceoContacts) {
            primaryContacts.put(ceoContact.AccountId, ceoContact);
        }
        //Loop through each Opportunity before is updated
        for (Opportunity beforeOppUpdate : Trigger.new) {
            //Prevent Opportunity update if Amount is less than 5000.
            if (beforeOppUpdate.Amount < 5000) {
                beforeOppUpdate.addError('Opportunity amount must be greater than 5000');
            } 
            //Populate Primary Contact on Opportunity.
            if (beforeOppUpdate.AccountId != null) {
                beforeOppUpdate.Primary_Contact__c = primaryContacts.get(beforeOppUpdate.AccountId).Id;
            }
        }
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        // Query Opportunities to get Account.Industry
        List<Opportunity> beforeOppsDelete = [
            SELECT Id, StageName, Account.Industry
            FROM Opportunity
            WHERE Id IN :Trigger.old
        ];
        //Loop through each Opportunity before is deleted.
        for (Opportunity beforeOppDelete : beforeOppsDelete) {
            if (beforeOppDelete.StageName == 'Closed Won' && beforeOppDelete.Account.Industry == 'Banking') {
                //Prevent Opportunity delete if is Close Won and the related Account Industry is Banking.
                Trigger.oldMap.Get(beforeOppDelete.Id).addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
}