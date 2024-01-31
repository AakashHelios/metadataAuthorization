public class CheckApiBoomi {
     @AuraEnabled(cacheable=true)
    public static void testBoomiAPI() {
        // Define the endpoint URL of your Boomi API
        String endpoint = 'https://devboomi.imprimisrx.com:9090/ws/simple/createAPI_Create';

        // Create a JSON payload with the required data (name and email)
        Map<String, String> requestBody = new Map<String, String>();
        requestBody.put('name', 'John Doe');
        requestBody.put('email', 'johndoe@example.com');
        String requestBodyJson = JSON.serialize(requestBody);

        // Create an HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET'); 
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBodyJson);
        req.setTimeout(60000); // Set timeout to 60 seconds (adjust as needed)

        // Create an HTTP client and send the request
        Http http = new Http();
        HttpResponse res = http.send(req);


        // Check the response
        if (res.getStatusCode() == 200) {
            // API call was successful, you can process the response here if needed
            String responseBody = res.getBody();
            System.debug('API Response: ' + responseBody);
        } else {
            // API call failed
            System.debug('API Call failed with status code: ' + res.getStatusCode());
            System.debug('API Response: ' + res.getBody());
        }
    }


}