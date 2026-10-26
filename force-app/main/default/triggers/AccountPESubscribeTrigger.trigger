trigger AccountPESubscribeTrigger on Account_PE__e (after insert) {
   
    list<Contact>newcontacts=new list<Contact>();
    for (Account_PE__e event : Trigger.new){
        if (event.Account_Id__c != null) {
            Contact con         =new Contact();
            con.lastName        =event.Account_Id__c+event.Account_Name__c;
            con.AccountId       =event.Account_Id__c;
            newcontacts.add(con);
        }
    }
    // Perform the update only if there are accounts to update
    if (!newcontacts.isEmpty()) {
       // try {
            insert newcontacts;
        //} catch (DmlException e) {
          //  System.debug('Error updating accounts: ' + e.getMessage());
        //}
    }
}