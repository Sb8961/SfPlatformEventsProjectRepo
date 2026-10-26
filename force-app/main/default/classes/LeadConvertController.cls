public with sharing class LeadConvertController {

    @AuraEnabled(cacheable=true)
    public static List<Patient_Contact__c> findMatchingPatients(Id leadId) {
        // 1. SAFE QUERY: Assign to List first
        List<Lead> queriedLeads = [SELECT Id, Email, Phone, DOB__c FROM Lead WHERE Id = :leadId LIMIT 1];
        
        // If no lead is found, return an empty list immediately
        if (queriedLeads.isEmpty()) {
            return new List<Patient_Contact__c>(); 
        }
        
        Lead currentLead = queriedLeads[0];
        
        // Execute matching SOQL against custom patient objects
        List<Patient_Contact__c> matchedContacts = [
            SELECT Id, Patient__c, Patient__r.Name,Primary_Email__c,Mobile_Phone__c, Patient__r.Date_of_Birth__c 
            FROM Patient_Contact__c 
             WHERE 
            (
                (Primary_Email__c != null AND Primary_Email__c = :currentLead.Email) OR 
                (Mobile_Phone__c != null AND Mobile_Phone__c = :currentLead.Phone)
            )
            WITH SECURITY_ENFORCED
        ];
        System.debug('Matched Contacts--->'+matchedContacts);
        return matchedContacts;
    }

    @AuraEnabled
    public static String processLeadConversion(Id leadId, Id selectedPatientId, Boolean createNew) {
        Savepoint sp = Database.setSavepoint();
        
        try {
            // 2. SAFE QUERY: Get Lead info safely
            List<Lead> leadsToConvert = [SELECT Id, FirstName, LastName, Email, Phone, DOB__c FROM Lead WHERE Id = :leadId LIMIT 1];
            if (leadsToConvert.isEmpty()) {
                 throw new AuraHandledException('Lead not found. It may have been deleted or already converted.');
            }
            Lead currentLead = leadsToConvert[0];

            // 3. SAFE QUERY: Get Lead Status safely
            List<LeadStatus> convertStatuses = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            if (convertStatuses.isEmpty()) {
                 throw new AuraHandledException('No converted Lead Status found. Please check your Lead Status configuration in Setup.');
            }
            LeadStatus convertStatus = convertStatuses[0];
            
            Id patientIdToReturn;

            if (createNew) {
                // Create custom Patient__c Master Record
                Patient__c newPatient = new Patient__c(
                    Name = currentLead.FirstName + ' ' + currentLead.LastName,
                    Date_of_Birth__c = currentLead.DOB__c
                );
                insert newPatient;

                // Create custom Patient_Contact__c record
                Patient_Contact__c newContact = new Patient_Contact__c(
                    Patient__c = newPatient.Id,
                    Primary_Email__c = currentLead.Email,
                    Mobile_Phone__c = currentLead.Phone
                );
                insert newContact;

                // Create custom Patient_Account__c record
                Patient_Account__c newAccount = new Patient_Account__c(
                    Patient__c = newPatient.Id,
                    Account_Type__c = 'Private Pay' 
                );
                insert newAccount;

                patientIdToReturn = newPatient.Id;
            } else {
                patientIdToReturn = selectedPatientId;
            }

            // Standard Lead Convert
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setDoNotCreateOpportunity(true); 
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            if (!lcr.isSuccess()) {
                throw new AuraHandledException('Standard Lead Conversion failed: ' + lcr.getErrors()[0].getMessage());
            }
            
            return patientIdToReturn; 
            
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }
}