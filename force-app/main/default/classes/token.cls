public class token {
    public static void generateNewSession(String sid){
        Authorized__c source = [SELECT Id, Name, access_token__c, refresh_token__c, id_token__c, instance_url__c FROM Authorized__c WHERE Id = :sid];
        secret__mdt smd = secret__mdt.getInstance('app');
        HttpRequest req = new HttpRequest();
         Http ht = new Http();
        String apexEndPoint = source.instance_url__c + '/services/data/v58.0/tooling/query/?q=Select+id,Name,lastModifiedBy.Name,CreatedBy.Name,Body,Status+from+ApexClass';
        req.setEndpoint(apexEndPoint); 
        req.setHeader('Authorization', 'Bearer '+source.access_token__c);
		req.setHeader('content-type', 'application/x-www-form-urlencoded');        
        req.setMethod('POST');
        HttpResponse apexRes = ht.send(req);
        if(apexRes.getStatus() == 'OK'){
            return;
        }
        String endPoint = source.instance_url__c+'/services/oauth2/token?' +
            'client_id='+smd.client__c+
            '&client_secret='+smd.secret__c+
            '&grant_type=refresh_token&' +
            'refresh_token='+ source.refresh_token__c ;
        req.setHeader('Authorization', EncodingUtil.base64Encode(Blob.valueOf(smd.client__c+':'+smd.secret__c)));
		req.setEndpoint(endPoint);
		req.setHeader('content-type', 'application/x-www-form-urlencoded');        
        req.setMethod('POST');
       
        HttpResponse res = ht.send(req);
        System.debug(res.getStatus()+' -- Response '+ res.getBody());
        if(res.getStatus() == 'OK'){
            refreshTokenData rtd = refreshTokenData.parse(res.getBody());
            source.access_token__c = rtd.access_token;
            update source;
        }else{
            throw new AuthorizationException('Failed to Refresh Token');
        }
    }
}