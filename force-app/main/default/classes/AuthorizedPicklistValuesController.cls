public with sharing class AuthorizedPicklistValuesController {
    @AuraEnabled(cacheable=true)
    public static List<Authorized__c> getAuthorizedRecords() {
        //Database.executeBatch(new BatchTestToken(),10);
        return [SELECT Id, Name FROM Authorized__c];
    }
}