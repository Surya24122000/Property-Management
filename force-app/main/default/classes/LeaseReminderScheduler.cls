global class LeaseReminderScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        List<Lease_Agreement__c> agreements = [
            SELECT Id, Tenant__r.Email__c, Property__r.Name, Agreed_Monthly_Rent__c, End_Date__c
            FROM Lease_Agreement__c
            WHERE End_Date__c = NEXT_N_DAYS:30 OR End_Date__c = NEXT_N_DAYS:1
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Lease_Agreement__c lease : agreements) {
            if (lease.Tenant__r.Email__c == null) continue;

            String subject = 'Reminder: Your Lease Agreement is Ending Soon!';
            String body = '<p>Dear Tenant,</p>' +
                          '<p>Your lease agreement for <b>' + lease.Property__r.Name + '</b> is expiring on <b>' + lease.End_Date__c + '</b>.</p>' +
                          '<p>Please make necessary arrangements.</p>';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ lease.Tenant__r.Email__c });
            email.setSubject(subject);
            email.setHtmlBody(body);
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}