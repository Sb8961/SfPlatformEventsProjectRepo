public class AccountClass {

    //for tracking the changes in Account Field
    public static void AccMethod(List<Account>AccList,Map<Id,Account>AccoldMap)
    {
           // Get all Account record type info once
        //Map<Id, Schema.RecordTypeInfo> accRtMap = Schema.SObjectType.Account.getRecordTypeInfosById();
        //List<Change_History__c> listOfChangeHistoryToInsert = new List<Change_History__c>();
        ChangeHistoryController.filterRecordsChangeHistory(AccoldMap,AccList,'Account');
        /*for (Account acc : AccList)
        {
            if(Trigger.isUpdate && (acc.Rating != AccoldMap.get(acc.id).Rating))
            {
                Account oldAcc=AccoldMap.get(acc.id);
                Change_History__c chngObj = ChangeHistoryController.createChangeHistoryRecord(oldAcc,acc,'Rating',acc.Id);
                listOfChangeHistoryToInsert.add(chngObj);
            }
        }*/
        
       /* if(!listOfChangeHistoryToInsert.isEmpty())
        {.   xyz
            insert listOfChangeHistoryToInsert;
        }*/
    }
}