trigger ApexTrigger on Account (after update)
{
	if(Trigger.isAfter && Trigger.isUpdate)
    {
        AccountClass.AccMethod(Trigger.new,Trigger.oldMap);
    }
}