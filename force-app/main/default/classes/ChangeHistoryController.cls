public class ChangeHistoryController {
    public static Change_History__c createChangeHistoryRecord(sObject oldSobj,sObject newSobj,
                                                              String fieldName,Id RecordId){
        Change_History__c chngObj = new Change_History__c();
        chngObj.Object_Name__c = String.valueof(RecordId.getSobjectType());
        chngObj.Field_Name__c = fieldName ;
        chngObj.Old_Field_Value__c = String.valueof(oldSobj.get(fieldName)) ;
        chngObj.New_Field_Value__c = String.valueof(newSobj.get(fieldName));
        //chngObj.Record_Type_Id__c = accRtMap.get(acc.RecordTypeId).getDeveloperName();
        chngObj.User_Name__c = Userinfo.getUserId(); 
        chngObj.Record_Id__c = RecordId;
        return chngObj;
    }
    
    public static void filterRecordsChangeHistory(Map<Id,sObject>oldsObjectMap,list<sObject>newList,String objName){
        list<Change_History__c>listOfChangeHistoryToInsert=new list<Change_History__c>();
        List<Change_Tracking__mdt>historyRecords=[Select Tracked_Field__c,Object_Name__c from Change_Tracking__mdt where Object_Name__c=:objName];
        
        for(sObject newsObj:newList){
            sObject oldsObj=oldsObjectMap.get(String.valueOf(newsObj.get('Id')));
            for(Change_Tracking__mdt fieldHisttrck:historyRecords){
                if(String.valueOf(newsObj.get(fieldHisttrck.Tracked_Field__c))!=String.valueOf(oldsObj.get(fieldHisttrck.Tracked_Field__c))){
                    Change_History__c chngObj = createChangeHistoryRecord(oldsObj,newsObj,fieldHisttrck.Tracked_Field__c,String.valueOf(newsObj.get('Id')));
                	listOfChangeHistoryToInsert.add(chngObj);
                }
            }
        }
        if(!listOfChangeHistoryToInsert.isEmpty()){
            insert listOfChangeHistoryToInsert;
        }
    }
}