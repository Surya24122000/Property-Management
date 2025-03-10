trigger PropertyTenantTrigger on Property_Tenant__c (before insert, after insert) {

  If(Trigger.isBefore){
        for (Property_Tenant__c pt : Trigger.new){
            pt.Name = pt.TenantPropoertyName__c;
        }
   }
If(Trigger.isAfter){
    
    List<Task> tasks = new List<Task>();

    Set<Id> propertyIds = new Set<Id>();
    Set<Id> tenantIds = new Set<Id>();

    for (Property_Tenant__c pt : Trigger.new) {
        if (pt.Property__c != null) {
            propertyIds.add(pt.Property__c);
        }
        if (pt.Tenant__c != null) {
            tenantIds.add(pt.Tenant__c);
        }
    }

    Map<Id, Property__c> propertyMap = new Map<Id, Property__c>(
        [SELECT Id, Name FROM Property__c WHERE Id IN :propertyIds]
    );

    for (Property_Tenant__c pt : Trigger.new) {
        if (pt.Property__c != null && pt.Tenant__c != null) {
            String propertyName = propertyMap.containsKey(pt.Property__c) ? propertyMap.get(pt.Property__c).Name : 'Unknown Property';
            
            Task newTask = new Task(
                Subject = 'Generate Lease Agreement',
                WhatId = pt.Tenant__c,
                OwnerId = UserInfo.getUserId(), 
                ActivityDate = Date.today().addDays(1),
                Status = 'Not Started',
                Priority = 'High',
                Description = 'Generate the lease agreement for ' + propertyName
            );
            tasks.add(newTask);
        }
    }

    if (!tasks.isEmpty()) {
        insert tasks;
    }
    
}
    
    
}