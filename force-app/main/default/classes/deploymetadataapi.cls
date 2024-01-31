public class deploymetadataapi {
    public String ZipData { get; set; }	
    public MetadataService.AsyncResult AsyncResult {get; private set;}
public  void deployZip()
	{
		

		// Deploy zip file posted back from the page action function				
		MetadataService.MetadataPort service = createService();
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'NoTestRun';
        deployOptions.singlePackage = true;		
		AsyncResult = service.deploy(ZipData, DeployOptions);				
		//return null;
	}	
    private static MetadataService.MetadataPort createService() {
   
    Authorized__c authorizedRecord = [SELECT access_token__c, instance_url__c  FROM Authorized__c LIMIT 1];
    String accessToken = authorizedRecord.access_token__c;
    String instanceUrl = authorizedRecord.instance_url__c;

    //String endpoint_x = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/42.0';
    //String endpoint_x = instance_url__c;
    
    String endpoint_x = instanceUrl + '/services/Soap/m/42.0';
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.endpoint_x = endpoint_x;
   
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.SessionHeader.sessionId = accessToken;

    return service;
}
}