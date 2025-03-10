@isTest
public class PropertyControllerTestClass {
    @testSetup
    static void setupTestData() {
        // Creating test property records
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 1; i <= 5; i++) {
            properties.add(new Property__c(
                Name = 'Property ' + i,
                Address__c = 'Test Address ' + i,
                City__c = 'Test City',
                State__c = 'Test State',
                Postal_Code__c = '123456',  // Required field added
                Country__c = 'USA',         // Required field added
                Type__c = 'Residential',      // Required field added
                Rent__c = 1000 + (i * 500),
                Furnishing_Status__c = 'Furnished',
                Status__c = 'Available'
            ));
        }
        insert properties;
    }

    @isTest
    static void testGetPaginatedProperties() {
        Test.startTest();
        
        List<Property__c> properties = PropertyController.getPaginatedProperties(1, 3, 500, 5000, 'Available', 'Furnished', null, null, null);
        
        Test.stopTest();

        System.assertNotEquals(null, properties, 'Properties list should not be null');
        System.assertEquals(3, properties.size(), 'The method should return 3 properties based on pagination');
    }

    @isTest
    static void testGetTotalPropertyCount() {
        Test.startTest();
        
        Integer totalCount = PropertyController.getTotalPropertyCount(5, 500, 5000, 'Available', 'Furnished', null, null, null);
        
        Test.stopTest();

        System.assertNotEquals(null, totalCount, 'Total count should not be null');
        System.assertEquals(5, totalCount, 'Total property count should match the inserted records');
    }
}