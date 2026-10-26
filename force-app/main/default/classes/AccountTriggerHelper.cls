public class AccountTriggerHelper {
    public static void publishAccountPlatformEvents(list<Account>accs){
        list<Account_PE__e>accountPes=new list<Account_PE__e>();
        for(Account acc:accs){
            Account_PE__e accPe=new Account_PE__e();
            accPe.Account_Id__c=acc.Id;
            accPe.Account_Name__c=acc.Name;
            accPe.Rating__c=acc.Rating;
            accountPes.add(accPe);
        }
        if(!accountPes.isEmpty()){
            EventBus.publish(accountPes);
        }
    }
}