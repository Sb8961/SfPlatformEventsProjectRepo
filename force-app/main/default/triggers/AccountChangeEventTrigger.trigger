trigger AccountChangeEventTrigger on AccountChangeEvent (after insert) {
    List<Contact> insertcon = new List<Contact>();
    List<Error_Logger__c> errorLogs = new List<Error_Logger__c>();

    for (AccountChangeEvent event : Trigger.new) {
        try {
            EventBus.ChangeEventHeader header = event.ChangeEventHeader;
            if (header.changeType == 'UPDATE') {
                Contact con = new Contact();
                //con.FirstName = 'XYZ';
                con.LastName = 'XYZ';
                insertcon.add(con);
            }
        } catch (Exception e) {
            Error_Logger__c  errorLog = new Error_Logger__c();
            errorLog.Error_Description__c = e.getMessage(); 
            errorLogs.add(errorLog);
        }
    }
    if (!insertcon.isEmpty()){
        insert insertcon;
    }

    if (!errorLogs.isEmpty()) {
        insert errorLogs;
    }
}