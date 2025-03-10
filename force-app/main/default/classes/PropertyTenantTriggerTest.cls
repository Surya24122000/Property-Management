@isTest
public class PropertyTenantTriggerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test Property record with all required fields
        Property__c property = new Property__c(
            Name = 'Test Property',
            Address__c = '123 Test Street',
            City__c = 'Test City',
            State__c = 'Test State',
            Postal_Code__c = '12345',
            Country__c = 'Test Country',
            Type__c = 'Residential',  // Adjust based on available picklist values
            Status__c = 'Available', // Adjust based on allowed values
            Rent__c = 1000 // Must be a valid decimal number
        );
        insert property;
        
        // Create a test Tenant record with required fields
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Phone__c = '1234567890', // Required field
            Email__c = 'testtenant@example.com' // Required field
        );
        insert tenant;
    }
    
    @isTest
    static void testBeforeInsertTrigger() {
        // Fetch test data
        Property__c testProperty = [SELECT Id FROM Property__c LIMIT 1];
        Tenant__c testTenant = [SELECT Id FROM Tenant__c LIMIT 1];

        // Create a Property_Tenant__c record
        Property_Tenant__c propertyTenant = new Property_Tenant__c(
            Property__c = testProperty.Id,
            Tenant__c = testTenant.Id
        );

        Test.startTest();
        insert propertyTenant;
        Test.stopTest();

        // Verify that Name is not null (if writable)
        Property_Tenant__c insertedRecord = [SELECT Name FROM Property_Tenant__c WHERE Id = :propertyTenant.Id];
        System.assertNotEquals(null, insertedRecord.Name, 'Name should not be null after insert');
    }

    @isTest
    static void testAfterInsertTrigger() {
        // Fetch test data
        Property__c testProperty = [SELECT Id FROM Property__c LIMIT 1];
        Tenant__c testTenant = [SELECT Id FROM Tenant__c LIMIT 1];

        // Create a Property_Tenant__c record
        Property_Tenant__c propertyTenant = new Property_Tenant__c(
            Property__c = testProperty.Id,
            Tenant__c = testTenant.Id
        );

        Test.startTest();
        insert propertyTenant;
        Test.stopTest();

        // Verify that a Task is created
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :testTenant.Id];
        System.assertEquals(1, tasks.size(), 'A task should be created for the tenant');
        System.assertEquals('Generate Lease Agreement', tasks[0].Subject, 'Task subject should match expected value');
    }
}