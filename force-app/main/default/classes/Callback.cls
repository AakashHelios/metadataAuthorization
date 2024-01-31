@RestResource(urlMapping='/callback/*')
global without sharing class Callback {
    @HttpGet
    global static String getUrlParameters() {
        String code = RestContext.request.params.get('code');
        String url = RestContext.request.params.get('state');
        
        Secret__mdt smd = Secret__mdt.getInstance('app');
        
        String postURL = EncodingUtil.urlDecode(url, 'UTF-8') + '/services/oauth2/token?';
        postURL += 'client_id=' + smd.client__c + '&';
        postURL += 'redirect_uri=' + smd.url__c + '/services/apexrest/callback&';
        postURL += 'code=' + code + '&';
        postURL += 'grant_type=authorization_code&';
        postURL += 'client_secret=' + smd.secret__c + '&';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(postURL);
        req.setMethod('POST');
        
        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        
        if (res.getStatusCode() == 200) {
            callbackResponse resp = (callbackResponse) JSON.deserialize(responseBody, callbackResponse.class);
            String Name = resp.instance_url.split('//')[1];
            Name = Name.split('\\.')[0];
            Authorized__c ac = new Authorized__c();
            ac.Access_Token__c = resp.access_token;
            ac.Instance_URL__c = resp.instance_url;
            ac.Refresh_Token__c = resp.refresh_token;
            ac.Id_Token__c = resp.id_token;
            ac.Name =  Name +' ' + DateTime.now();
            
            insert ac;
            
            String sourceURL = 'https://helioswebservices-1b-dev-ed.develop.lightning.force.com/lightning/n/Comparison';
            RestContext.response.statusCode = 301;
   			RestContext.response.addHeader('Location',sourceURL);
   			RestContext.response.addHeader('http-equiv','refresh');
            
          
        }else{
            return 'Error : '+responseBody;
        }
        return null;
        
    }
    
    public class callbackResponse {
        public String access_token;
        public String instance_url;
        public String refresh_token;
        public String id_token;
    }
}