trigger OrderStatusTrigger on Order (after update) {
    List<Order_Event__e> events = new List<Order_Event__e>();
    for (Order ord : Trigger.new) {
        Order oldOrder = Trigger.oldMap.get(ord.Id);
        if (ord.Status != oldOrder.Status) { // Check if the status has changed
            events.add(new Order_Event__e(
                OrderId__c = ord.Id,
                Status__c = ord.Status,
                Order_Name__c  = ord.OrderNumber  
            ));
        }
    }

    if (!events.isEmpty()) {
        EventBus.publish(events); // Publish the Platform Events
    }
}