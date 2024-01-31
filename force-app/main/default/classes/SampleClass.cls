public class SampleClass {
      private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    
    public static void deployApexClass(String sessionId, String apexClassName) {
        MetadataService.MetadataPort service = createService(sessionId);
        
    
        String base64Zip = retrieveApexClass(service, apexClassName);
        
    
        deployZip(service, base64Zip);
    }
    
    private static MetadataService.MetadataPort createService(String sessionId) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        return service;
    }
    
    private static String retrieveApexClass(MetadataService.MetadataPort service, String apexClassName) {
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = METADATA_API_VERSION;
        retrieveRequest.singlePackage = true;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        
        MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
        packageType.name = 'ApexClass';
        packageType.members = new String[] { apexClassName };
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers> { packageType };
        
        MetadataService.AsyncResult asyncResult = service.retrieve(retrieveRequest);
        
    
        MetadataService.RetrieveResult retrieveResult = null;
        do {
            retrieveResult = service.checkRetrieveStatus(asyncResult.Id, true);
        } while (!retrieveResult.done);
        
        return retrieveResult.zipFile;
    }
     private static void deployZip(MetadataService.MetadataPort service, String base64Zip) {
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
        
        MetadataService.AsyncResult asyncResult = service.deploy(base64Zip, deployOptions);
        
      
    }
}