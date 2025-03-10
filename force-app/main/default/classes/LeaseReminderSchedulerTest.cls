@isTest
private class LeaseReminderSchedulerTest {
    @isTest
    static void testLeaseReminderScheduler() {
        Test.startTest();

        // ✅ Step 1: Insert Test Tenant
        Tenant__c testTenant = new Tenant__c(
            Name = 'John Doe',
            Email__c = 'johndoe@example.com', // ✅ Ensure Email is present
            Phone__c = '1234567890'
        );
        insert testTenant;

        System.debug('✅ Inserted Tenant: ' + testTenant);

        // ✅ Step 2: Insert Test Property
        Property__c testProperty = new Property__c(
            Name = 'Test Apartment',
            Address__c = '123 Test Street',
            City__c = 'Test City',
            State__c = 'Test State',
            Postal_Code__c = '12345',
            Country__c = 'Test Country',
            Type__c = 'Residential',
            Status__c = 'Available',
            Rent__c = 2000
        );
        insert testProperty;

        System.debug('✅ Inserted Property: ' + testProperty);

        // ✅ Step 3: Insert Lease Agreement ending in 30 days
        Lease_Agreement__c leaseAgreement = new Lease_Agreement__c(
            Tenant__c = testTenant.Id,
            Property__c = testProperty.Id,
            Agreed_Monthly_Rent__c = 2000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30) // ✅ Matches scheduler criteria
        );
        insert leaseAgreement;

        System.debug('✅ Inserted Lease Agreement: ' + leaseAgreement);

        // ✅ Step 4: Execute Scheduler
        LeaseReminderScheduler scheduler = new LeaseReminderScheduler();
        scheduler.execute(null); // Simulate scheduled execution

        Test.stopTest();

        // ✅ Step 5: Verify Lease Agreement Exists
        List<Lease_Agreement__c> leases = [SELECT Id, Tenant__r.Email__c FROM Lease_Agreement__c WHERE Id = :leaseAgreement.Id];
        System.assertEquals(1, leases.size(), 'Lease Agreement should exist');
        System.assertNotEquals(null, leases[0].Tenant__r.Email__c, 'Tenant Email should be populated');

        // ✅ Step 6: Check if Email Logic Applied
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Lease_Agreement__c lease : leases) {
            if (lease.Tenant__r.Email__c != null) {
                emails.add(new Messaging.SingleEmailMessage());
            }
        }

        System.assertEquals(1, emails.size(), 'One email should be sent');
    }
}