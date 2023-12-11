public class AccountController {
 
    @AuraEnabled( cacheable = true )
    public static List< Account > fetchAccounts() {
     
        return [
            SELECT Id, Name, Industry, Is_Active__c
            FROM Account
            LIMIT 10
        ];
         
    }
     
}