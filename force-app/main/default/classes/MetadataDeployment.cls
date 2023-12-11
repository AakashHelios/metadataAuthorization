public class MetadataDeployment {
  private static final Integer METADATA_API_VERSION = Integer.valueOf(
    new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/')
  );

  @AuraEnabled(cacheable=true)
  public static String deployMetadataItems(
    String sourceOrg,
    String targetOrg,
    List<String> metadataItemNames,
    String metadataType
  ) {
    List<String> base64Zips = new List<String>();
    try {
      for (String metadataItemName : metadataItemNames) {
        base64Zips.add(
          retrieveMetadataItem(sourceOrg, metadataType, metadataItemNames)
        );
      }
      System.debug('metadataItemNames' + metadataItemNames);
      System.debug('Data Retrieved base64Zips: ' + base64Zips);
    } catch (Exception e) {
      // Handle the error
      System.debug(e.getMessage());
      return 'Error retrieving metadata items: ' + e.getMessage();
    }

    if (base64Zips.isEmpty()) {
      return 'Retrieved metadata items are empty';
    }

    System.debug('base64Zips' + base64Zips);
    // Combine the retrieved zip files
    String combinedZip = combineZips(base64Zips);

    // Deploy the combined zip file
    return deployZip(targetOrg, combinedZip);
  }

  public static String combineZips(List<String> base64ZipList) {
    String combinedBlob = '';

    for (String base64Zip : base64ZipList) {
      if (base64Zip.length() > 0) {
        combinedBlob += base64Zip;
      }
    }
    System.debug('combinedBlob' + combinedBlob);
    return combinedBlob;
  }

  public static String retrieveMetadataItem(
    String sourceOrg,
    String metadataType,
    List<String> metadataItemNames
  ) {
    MetadataService.MetadataPort service = createService('source', sourceOrg);
    MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
    retrieveRequest.apiVersion = METADATA_API_VERSION;
    retrieveRequest.singlePackage = true;
    retrieveRequest.packageNames = null;
    retrieveRequest.specificFiles = null;
    retrieveRequest.unpackaged = new MetadataService.Package_x();

    // Create a list of package type members
    List<MetadataService.PackageTypeMembers> packageTypeMembersList = new List<MetadataService.PackageTypeMembers>();
    for (String metadataItemName : metadataItemNames) {
      MetadataService.PackageTypeMembers packageTypeMembers = new MetadataService.PackageTypeMembers();
      packageTypeMembers.name = metadataType;
      packageTypeMembers.members = new List<String>();
      packageTypeMembers.members.add(metadataItemName);
      packageTypeMembersList.add(packageTypeMembers);
    }

    retrieveRequest.unpackaged.types = packageTypeMembersList;

    // Retrieve the zip file
    MetadataService.AsyncResult asyncResult = service.retrieve(retrieveRequest);

    // Poll the service until the zip file is available
    MetadataService.RetrieveResult retrieveResult;
    do {
      retrieveResult = service.checkRetrieveStatus(asyncResult.Id, true);
    } while (!retrieveResult.done);

    return retrieveResult.zipFile;
  }

  @AuraEnabled(cacheable=true)
  public static String deployZip(String targetOrg, String combinedZip) {
    MetadataService.MetadataPort service = createService('target', targetOrg);

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

    System.debug('targetOrg ' + targetOrg);
    MetadataService.AsyncResult asyncResult = service.deploy(
      combinedZip,
      deployOptions
    );

    System.debug('Metadata is deployed' + combinedZip);
    return 'Deployed successfully. Deployment Id: ' + asyncResult.Id;
  }

  private static MetadataService.MetadataPort createService(
    String orgType,
    String orgId
  ) {
    // Query the Authorized__c record to get the access token and instance URL based on the orgType and orgId
    Authorized__c orgRecord = [
      SELECT access_token__c, instance_url__c
      FROM Authorized__c
      WHERE Id = :orgId
    ];
    String accessToken = orgRecord.access_token__c;
    String instanceUrl = orgRecord.instance_url__c;

    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.endpoint_x =
      instanceUrl +
      '/services/Soap/m/' +
      METADATA_API_VERSION;
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.SessionHeader.sessionId = accessToken;

    return service;
  }
}
