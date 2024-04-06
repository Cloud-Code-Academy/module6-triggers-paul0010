trigger AccountTrigger on Account (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        //Query List of Accounts after insert to be able to use the ShippingAddress.
        List<Account> afterAccsInsert = [
            SELECT Id, Type, ShippingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Phone, Website, Fax
            FROM Account 
            WHERE Id IN :Trigger.new
            ];
        //List of Accounts to update and Contacts to insert.
        List<Account> updateAccs = new List<Account>();
        List<Contact> insertConts = new List<Contact>();
        //Loop through Accounts before insert.
        for (Account acc : afterAccsInsert) {
            //If Account Type is null add the value of 'Prospect'.
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
            //If ShippingAddress is not empty copy its values to the BillingAddress.
            if (acc.ShippingAddress != null) {
                acc.BillingStreet = acc.ShippingStreet;
                acc.BillingCity = acc.ShippingCity;
                acc.BillingState = acc.ShippingState;
                acc.BillingPostalCode = acc.ShippingPostalCode;
                acc.BillingCountry = acc.ShippingCountry;
            }
            //If Account Phone, Website and Fax are not empty update the Rating to 'Hot'.
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
            updateAccs.add(acc);
            //Create a related Contact for each inserted Account.
            Contact cont = new Contact( LastName = 'DefaultContact', Email = 'default@email.com', AccountId = acc.Id);
            insertConts.add(cont);
        }
        //Update Accounts and insert Contacts.
        update updateAccs;
        insert insertConts;
    }
}