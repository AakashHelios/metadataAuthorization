public with sharing class AuthorizedPicklistValuesController {
    @AuraEnabled(cacheable=true)
    public static List<Authorized__c> getAuthorizedRecords() {
        return [SELECT Id, Name FROM Authorized__c];
    }
}
