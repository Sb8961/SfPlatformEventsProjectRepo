/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : changeHistoryApexClass
 * Author          : <YourName>
 * Created Date    : May 1, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 1, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 1, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class changeHistoryApexClass {

	@AuraEnabled(cacheable=true)
	public static List<Change_History__c> fetchApexResultMethod(Id accountId) {

			return[SELECT Field_Name__c, Old_Field_Value__c, New_Field_Value__c,Record_Id__c,
			 User_Name__c, SystemModstamp FROM Change_History__c WHERE Object_Name__c = 'Account' and 	
			 Record_Id__c =: accountId 
			 ORDER BY SystemModstamp ASC];
	}

}