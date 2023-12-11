public class MetadataTypesRetriever {
  private static final Integer METADATA_API_VERSION = Integer.valueOf(
    new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/')
  );

  public class MetadataTypeWrapper {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }

    public MetadataTypeWrapper(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  public class MetadataItemWrapper {
    @AuraEnabled
    public String base64ZipContent { get; set; }
    @AuraEnabled
    public String fullName { get; set; }
    @AuraEnabled
    public String decodedFullName { get; set; }
    @AuraEnabled
    public String metaDataType { get; set; }
    @AuraEnabled
    public String asyncResultId { get; set; }
    @AuraEnabled
    public String content { get; set; }

    public MetadataItemWrapper(
      String fullName,
      String decodedFullName,
      String metaDataType
    ) {
      this.fullName = fullName;
      this.decodedFullName = decodedFullName;
      this.metaDataType = metaDataType;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, List<MetadataItemWrapper>> getSelectedMetadataItemsForOrgs(
    List<String> selectedTypes,
    Boolean isSourceOrg,
    String sourceOrgId,
    String targetOrgId
  ) {
    Map<String, List<MetadataItemWrapper>> selectedMetadataItemsMap = new Map<String, List<MetadataItemWrapper>>();

    List<MetadataItemWrapper> sourceMetadataItems = getSelectedMetadataItems(
      selectedTypes,
      isSourceOrg,
      sourceOrgId
    );

    populateContent(sourceMetadataItems, sourceOrgId);
    System.debug('sourceMetadataItems' + sourceMetadataItems);
    selectedMetadataItemsMap.put('source', sourceMetadataItems);

    List<MetadataItemWrapper> targetMetadataItems = getSelectedMetadataItems(
      selectedTypes,
      !isSourceOrg,
      targetOrgId
    );
    populateContent(targetMetadataItems, targetOrgId);
    System.debug('targetMetadataItems' + targetMetadataItems);
    selectedMetadataItemsMap.put('target', targetMetadataItems);

    //System.debug('selectedMetadataItemsMap' + selectedMetadataItemsMap);
    return selectedMetadataItemsMap;
  }

  private static void populateContent(
    List<MetadataItemWrapper> metadataItems,
    String orgId
  ) {
    if (metadataItems != null && !metadataItems.isEmpty()) {
      List<Authorized__c> orgs = [
        SELECT access_token__c, instance_url__c
        FROM Authorized__c
        WHERE Id = :orgId
      ];

      if (!orgs.isEmpty()) {
        Authorized__c orgRecord = orgs[0];
        MetadataService.MetadataPort service = createService(
          orgRecord.access_token__c,
          orgRecord.instance_url__c
        );

        for (MetadataItemWrapper itemWrapper : metadataItems) {
          // Retrieve the content of the current metadata item and set it in the wrapper
          MetadataService.FileProperties fileProperty = new MetadataService.FileProperties();
          fileProperty.id = itemWrapper.asyncResultId;
          String content = getContentOfFile(service, fileProperty);
          System.debug('content' + itemWrapper.content);
          itemWrapper.content = content;
          itemWrapper.base64ZipContent = getContentOfFile(
            service,
            fileProperty
          );
        }
      }
    }
  }

  //this method is for to get selected metadata types
  @AuraEnabled(cacheable=true)
  public static List<MetadataItemWrapper> getSelectedMetadataItems(
    List<String> selectedTypes,
    Boolean isSourceOrg,
    String orgId
  ) {
    List<MetadataItemWrapper> metadataItems = new List<MetadataItemWrapper>();

    if (selectedTypes != null && !selectedTypes.isEmpty()) {
      List<Authorized__c> orgs = [
        SELECT access_token__c, instance_url__c
        FROM Authorized__c
        WHERE Id = :orgId
      ];

      if (!orgs.isEmpty()) {
        Authorized__c orgRecord = orgs[0];

        // Call the createService method with access token and instance URL
        MetadataService.MetadataPort service = createService(
          orgRecord.access_token__c,
          orgRecord.instance_url__c
        );

        for (String metaDataType : selectedTypes) {
          // List metadata items for the current metadata type
          List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
          MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
          query.type_x = metaDataType;
          queries.add(query);

          // Call the listMetadata method to retrieve metadata items for the current type
          List<MetadataService.FileProperties> fileProperties = service.listMetadata(
            queries,
            METADATA_API_VERSION
          );

          // Process the retrieved metadata items and add them to the result list
          if (fileProperties != null) {
            for (MetadataService.FileProperties fileProperty : fileProperties) {
              // Set the asyncResultId and other properties to the wrapper
              MetadataItemWrapper itemWrapper = new MetadataItemWrapper(
                fileProperty.fullName,
                EncodingUtil.urlDecode(fileProperty.fullName, 'UTF-8'),
                metaDataType
              );
              itemWrapper.asyncResultId = fileProperty.id;
              metadataItems.add(itemWrapper);
              //System.debug('asyncResultId ' + fileProperty.id);
            }
          }
        }
      } else {
        System.debug('No records found for the provided org Id');
      }
    }
    System.debug('metadataItems' + metadataItems);
    return metadataItems;
  }

  @AuraEnabled(cacheable=true)
  public static String getContentOfFile(
    MetadataService.MetadataPort service,
    MetadataService.FileProperties fileProperty
  ) {
    // Retrieve the content of a specific metadata item
    MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
    retrieveRequest.apiVersion = METADATA_API_VERSION;
    retrieveRequest.singlePackage = true;
    retrieveRequest.unpackaged = new MetadataService.Package_x(); // Change MetadataService.Package to MetadataService.Package_x
    retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
    MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();

    if (fileProperty.type_x != null) {
      packageType.name = fileProperty.type_x;
    } else {
      System.debug('fileProperty.type_x is getting null value');
      // Handle the case where fileProperty.type_x is null
    }
    System.debug('packageType.members' + packageType.members);

    packageType.members = new List<String>{ fileProperty.fullName };
    retrieveRequest.unpackaged.types.add(packageType);

    // Call the retrieve method and handle the result
    try {
      MetadataService.AsyncResult asyncResult = service.retrieve(
        retrieveRequest
      );
      if (asyncResult != null) {
        String asyncResultId = asyncResult.Id;
        // Return the AsyncResult Id as a String
        return asyncResultId;
      }
    } catch (Exception e) {
      System.debug('Exception during metadata retrieve: ' + e.getMessage());
    }

    return '';
  }

  @AuraEnabled(cacheable=true)
  public static List<MetadataTypeWrapper> getMetadataTypes(
    String sourceOrgId,
    String targetOrgId
  ) {
    List<MetadataTypeWrapper> metadataTypes = new List<MetadataTypeWrapper>();

    // Get Authorized__c records for both source and target orgs
    List<Authorized__c> sourceOrgs = [
      SELECT access_token__c, instance_url__c
      FROM Authorized__c
      WHERE Id = :sourceOrgId
    ];
    List<Authorized__c> targetOrgs = [
      SELECT access_token__c, instance_url__c
      FROM Authorized__c
      WHERE Id = :targetOrgId
    ];

    if (!sourceOrgs.isEmpty() && !targetOrgs.isEmpty()) {
      // Since Id is unique, we can assume only one record is returned for each org
      Authorized__c sourceOrg = sourceOrgs[0];
      Authorized__c targetOrg = targetOrgs[0];

      // Call the createService method with access tokens and instance URLs
      MetadataService.MetadataPort sourceService = createService(
        sourceOrg.access_token__c,
        sourceOrg.instance_url__c
      );
      MetadataService.MetadataPort targetService = createService(
        targetOrg.access_token__c,
        targetOrg.instance_url__c
      );

      // List available Metadata Types via the 'describeMetadata' API call for the source org
      MetadataService.DescribeMetadataResult sourceDescribeResult = sourceService.describeMetadata(
        METADATA_API_VERSION
      );
      List<String> metadataTypeNames = new List<String>();
      for (
        MetadataService.DescribeMetadataObject metadataObject : sourceDescribeResult.metadataObjects
      ) {
        metadataTypeNames.add(metadataObject.xmlName);
        // Include child Metadata Types (such as CustomField, ValidationRule, etc.)
        if (metadataObject.childXmlNames != null) {
          metadataTypeNames.addAll(metadataObject.childXmlNames);
        }
      }

      // Sort Metadata Types
      metadataTypeNames.sort();
      for (String metadataTypeName : metadataTypeNames) {
        metadataTypes.add(
          new MetadataTypeWrapper(metadataTypeName, metadataTypeName)
        );
      }
    } else {
      System.debug('No records found for the provided org Ids');
    }

    System.debug('metadataTypes' + metadataTypes);

    return metadataTypes;
  }

  private static MetadataService.MetadataPort createService(
    String accessToken,
    String instanceUrl
  ) {
    // Use the access token and instance URL to create the MetadataService
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();

    // Check if the instance URL is not null before creating the endpoint_x
    if (instanceUrl != null) {
      String endpoint_x =
        instanceUrl +
        '/services/Soap/m/' +
        METADATA_API_VERSION;
      service.endpoint_x = endpoint_x;
    }

    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.SessionHeader.sessionId = accessToken;

    return service;
  }
  public class MetadataFile extends MetadataService.MetadataWithContent {
    public String getFullname() {
      return fullName;
    }
    public String getContent() {
      System.debug('content' + content);
      return content;
    }
  }
}
