public with sharing class authcontroller {
    @AuraEnabled
    public static List<Authorized__c> getAuthorizedRecords() {
        return [SELECT Id, Name FROM Authorized__c];
    }

}