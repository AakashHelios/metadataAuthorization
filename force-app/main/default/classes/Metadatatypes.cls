public class Metadatatypes {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));

    public String MetaDataFolder { get; set; }
    public List<SelectOption> MetaDataTypes { get; set; }
    public String MetaDataType { get; set; }
    public List<SelectOption> MetaDataItems { get; set; }
    public String MetaDataItem { get; set; }
    public String MetadataFileName { get; set; }
    public String MetadataFileData { get; set; }
    public MetadataService.AsyncResult AsyncResult { get; private set; }
    public String MetaDataRetrieveZip { get; private set; }

    // Method to retrieve metadata type names
    @AuraEnabled(cacheable=true)
    public static List<String> getMetadataTypeNames() {
        List<String> metadataTypeNames = new List<String>();

        // List available Metadata Types via the 'describeMetadata' API call
        MetadataService.MetadataPort service = createService();
        MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);

        for (MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects) {
            metadataTypeNames.add(metadataObject.xmlName);

            if (metadataObject.childXmlNames != null) {
                for (String childXmlName : metadataObject.childXmlNames) {
                    if (childXmlName != null) {
                        metadataTypeNames.add(childXmlName);
                    }
                }
            }
        }

        // Sort Metadata Types
        metadataTypeNames.sort();
        return metadataTypeNames;
    }

    // Method to retrieve metadata details based on the selected metadata types
   
    
    public static List<SelectOption> getMetadataDetails(List<String> selectedTypes) {
        
        List<SelectOption> metadataDetails = new List<SelectOption>();

        if (selectedTypes == null || selectedTypes.isEmpty()) {
            return metadataDetails;
        }

        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();

        for (String metadataType : selectedTypes) {
            MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
            queryLayout.type_x = metadataType;
            queries.add(queryLayout);
        }

        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);

        	// Sort
		List<String> fullNames = new List<String>();
		if(fileProperties!=null)
		{
			for(MetadataService.FileProperties fileProperty : fileProperties)
				fullNames.add(fileProperty.fullName);
			fullNames.sort();
			for(String fullName : fullNames)
				metadataDetails.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
		}
        
        
      return null;	
    }

    private static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}