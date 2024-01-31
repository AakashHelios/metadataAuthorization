public with sharing class Authrization {

    @AuraEnabled(cacheable=true)
    public static String getURL(string Domain){ 
        Datetime sysTime = System.now().addSeconds(2);
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
       	remoteSite s = new remoteSite(Domain);
		System.schedule('Schecdule '+chronExpression, chronExpression, s);
       	secret__mdt smd = secret__mdt.getInstance('app');
        System.debug(smd);
        String redirectURL= Domain+'/services/oauth2/authorize?';
        system.debug('redirectURL :'+redirectURL);
        redirectURL += 'client_id='+smd.client__c+'&';
        redirectURL += 'redirect_uri='+smd.url__c +'/services/apexrest/callback&';
        redirectURL += 'response_type=code&state='+EncodingUtil.urlEncode(Domain, 'UTF-8');
        return redirectURL;
      
    }
}