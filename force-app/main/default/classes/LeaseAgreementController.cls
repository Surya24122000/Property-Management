public with sharing class LeaseAgreementController {
    @AuraEnabled
    public static String sendEmailWithPDF(Id recordId) {
        System.debug('✅ Fetching Lease Agreement with ID: ' + recordId);
        
        if (recordId == null) {
            throw new AuraHandledException('❌ Record ID is missing!');
        }

        Lease_Agreement__c lease;
        try {
            lease = [
                SELECT Id, Tenant__c, Tenant__r.Email__c, Property__r.Name, 
                       Agreed_Monthly_Rent__c, Start_Date__c, End_Date__c
                FROM Lease_Agreement__c 
                WHERE Id = :recordId
                LIMIT 1
            ];
            System.debug('✅ Lease Agreement Data: ' + lease);
        } catch (Exception e) {
            throw new AuraHandledException('❌ Error fetching Lease Agreement: ' + e.getMessage());
        }

        if (lease == null || String.isEmpty(lease.Tenant__r.Email__c)) {
            throw new AuraHandledException('❌ Tenant email is missing.');
        }

        // ✅ Generate PDF Content
        String pdfContent = 'Lease Agreement\n'
            + 'Tenant: ' + lease.Tenant__r.Email__c + '\n'
            + 'Property: ' + lease.Property__r.Name + '\n'
            + 'Rent: ' + lease.Agreed_Monthly_Rent__c + '\n'
            + 'Start Date: ' + lease.Start_Date__c + '\n'
            + 'End Date: ' + lease.End_Date__c;

        Blob pdfBlob = Blob.valueOf(pdfContent);

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Lease_Agreement.pdf');
        attachment.setBody(pdfBlob);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ lease.Tenant__r.Email__c });
        email.setSubject('Your Lease Agreement');
        email.setHtmlBody('<p>Dear Tenant,</p><p>Please find your lease agreement attached.</p>');
        email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ attachment });

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
System.debug('✅ Email Sent Successfully!');
return 'Success'; // ✅ Now LWC can detect a response
    }
}