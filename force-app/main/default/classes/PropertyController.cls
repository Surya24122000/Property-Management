public with sharing class PropertyController {
    @AuraEnabled(cacheable=true)
    public static List<Property__c> getPaginatedProperties(
        Integer pageNumber, Integer pageSize, Decimal minPrice, Decimal maxPrice,
        String status, String furnishingStatus, Decimal latitude, Decimal longitude, Decimal maxDistance
    ) {
        Integer offsetValue = (pageNumber - 1) * pageSize;

        System.debug('Fetching Properties: PageNumber=' + pageNumber + ', Offset=' + offsetValue);

        // Base Query
        String baseQuery = 'SELECT Id, Name, Address__c, City__c, State__c, Rent__c, Furnishing_Status__c, Status__c,Geolocation__c FROM Property__c WHERE Rent__c >= :minPrice AND Rent__c <= :maxPrice';
        
        List<String> filters = new List<String>();

        // Adding Filters Securely
        if (!String.isEmpty(status)) {
            filters.add('Status__c = :status');
        }
        if (!String.isEmpty(furnishingStatus)) {
            filters.add('Furnishing_Status__c = :furnishingStatus');
        }
        if (latitude != null && longitude != null && maxDistance != null && maxDistance > 0) {
            filters.add('DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'km\') < :maxDistance');
        }

        // Append conditions if present
        if (!filters.isEmpty()) {
            baseQuery += ' AND ' + String.join(filters, ' AND ');
        }

        baseQuery += ' ORDER BY Name LIMIT :pageSize OFFSET :offsetValue';

        System.debug('Final Query: ' + baseQuery);

        // Execute Query Safely with Bind Variables
        return Database.query(baseQuery);
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalPropertyCount( Integer pageSize, Decimal minPrice, Decimal maxPrice,
        String status, String furnishingStatus, Decimal latitude, Decimal longitude, Decimal maxDistance) {
      //  return [SELECT COUNT() FROM Property__c];

      
        // Base Query
        String baseQuery = 'SELECT Id, Name, Address__c, City__c, State__c, Rent__c, Furnishing_Status__c, Status__c,Geolocation__c FROM Property__c WHERE Rent__c >= :minPrice AND Rent__c <= :maxPrice';
        
        List<String> filters = new List<String>();

        // Adding Filters Securely
        if (!String.isEmpty(status)) {
            filters.add('Status__c = :status');
        }
        if (!String.isEmpty(furnishingStatus)) {
            filters.add('Furnishing_Status__c = :furnishingStatus');
        }
        if (latitude != null && longitude != null && maxDistance != null && maxDistance > 0) {
            filters.add('DISTANCE(Geolocation__c, GEOLOCATION(:latitude, :longitude), \'km\') < :maxDistance');
        }

        // Append conditions if present
        if (!filters.isEmpty()) {
            baseQuery += ' AND ' + String.join(filters, ' AND ');
        }

        System.debug('Final Query: ' + baseQuery);

        // Execute Query Safely with Bind Variables
        return Database.query(baseQuery).Size();
    }
}