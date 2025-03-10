trigger VendorAssign on Maintenance_Requests__c (before insert) {
    // Fetch vendor workload
    Map<Id, Integer> workloadMap = new Map<Id, Integer>();

    for (AggregateResult ar : [
        SELECT Vendor__c, COUNT(Id) totalRequests 
        FROM Maintenance_Requests__c 
        WHERE Status__c = 'Open' 
        GROUP BY Vendor__c
    ]) {
        workloadMap.put(
            (Id) ar.get('Vendor__c'), 
            (Integer) ar.get('totalRequests') // ✅ Correct way to access COUNT(Id)
        );
    }

    // Fetch all vendors
    List<Vendor__c> vendors = [SELECT Id FROM Vendor__c];

    // Ensure every vendor is in the workload map (handle missing vendors)
    for (Vendor__c vendor : vendors) {
        if (!workloadMap.containsKey(vendor.Id)) {
            workloadMap.put(vendor.Id, 0);  // ✅ Default workload to 0
        }
    }

    // Find vendor with least workload
    Id leastBusyVendor = null;
    Integer minWorkload = 9999999;  // ✅ Instead of Integer.MAX_VALUE, use a large number

    for (Id vendorId : workloadMap.keySet()) {
        Integer workload = workloadMap.get(vendorId);
        if (workload < minWorkload) {
            minWorkload = workload;
            leastBusyVendor = vendorId;
        }
    }

    // Assign maintenance requests to the least busy vendor
    if (leastBusyVendor != null) {
        for (Maintenance_Requests__c req : Trigger.new) {
            req.Vendor__c = leastBusyVendor;
        }
    }
}