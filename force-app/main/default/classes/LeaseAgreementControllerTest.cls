@isTest
public class LeaseAgreementControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Property
        Property__c testProperty = new Property__c(
            Name = 'Test Property',
            Address__c = '123 Test Street',
            City__c = 'Test City',
            State__c = 'Test State',
            Postal_Code__c = '12345',
            Country__c = 'Test Country',
            Type__c = 'Residential',
            Status__c = 'Available',
            Rent__c = 1200
        );
        insert testProperty;

        // Create test Tenant with Email
        Tenant__c testTenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'testtenant@example.com', // ✅ Required field included
            Phone__c = '1234567890'
        );
        insert testTenant;

        // ✅ Ensure only ONE active Lease Agreement per Property
        Lease_Agreement__c testLease = new Lease_Agreement__c(
            Tenant__c = testTenant.Id,
            Property__c = testProperty.Id,
            Agreed_Monthly_Rent__c = 1200,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(12)
        );
        insert testLease;
    }

    @isTest
    static void testSendEmailWithPDF() {
        // ✅ Fetch the existing Lease Agreement
        Lease_Agreement__c lease = [SELECT Id FROM Lease_Agreement__c LIMIT 1];

        Test.startTest();
        String result = LeaseAgreementController.sendEmailWithPDF(lease.Id);
        Test.stopTest();

        // ✅ Verify the email was sent successfully
        System.assertEquals('Success', result, 'Email should be sent successfully.');
    }


}