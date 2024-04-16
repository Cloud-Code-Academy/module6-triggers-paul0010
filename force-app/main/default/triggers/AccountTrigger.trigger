trigger AccountTrigger on Account (before insert, after insert) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        //Loop through Accounts before insert.
        for (Account acc : Trigger.new) {
            //If Account Type is null add the value of 'Prospect'.
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
            //If ShippingAddress is not empty copy its values to the BillingAddress.
            if (acc.ShippingStreet != null) {
                acc.BillingStreet = acc.ShippingStreet;
            }

            if (acc.ShippingCity != null) {
                acc.BillingCity = acc.ShippingCity;
            }

            if (acc.ShippingState != null) {
                acc.BillingState = acc.ShippingState;
            }

            if (acc.ShippingPostalCode != null) {
                acc.BillingPostalCode = acc.ShippingPostalCode;
            }

            if (acc.ShippingCountry != null) {
                acc.BillingCountry = acc.ShippingCountry;
            }
            //If Account Phone, Website and Fax are not empty update the Rating to 'Hot'.
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        //List of Contacts to insert.
        List<Contact> insertConts = new List<Contact>();
        //Create a related Contact for each inserted Account.
        for (Account acc : Trigger.new) {
        Contact cont = new Contact( LastName = 'DefaultContact', Email = 'default@email.com', AccountId = acc.Id);
        insertConts.add(cont);
        }
        //Insert Contacts
        insert insertConts;
    }
}