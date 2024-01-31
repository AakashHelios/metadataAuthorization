public class MetadataTypesRetriever {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));

    public class MetadataTypeWrapper {
        @AuraEnabled
        public String MetaDataType { get; set; }
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
        public String fullName { get; set; }
        @AuraEnabled
        public String decodedFullName { get; set; }
        @AuraEnabled
        public String metaDataType { get; set; }
          @AuraEnabled
        public DateTime lastModifiedDate { get; set; }

        
        public MetadataItemWrapper(
            String fullName,
            String decodedFullName,
            String metaDataType,
            DateTime lastModifiedDate

        ) {
            this.fullName = fullName;
            this.decodedFullName = decodedFullName;
            this.metaDataType = metaDataType;
            this.lastModifiedDate = lastModifiedDate;

        }
    }
    
    
    //This method is used to retrieve Metadata types
    @AuraEnabled(cacheable = true)
    public static List<MetadataTypeWrapper> getMetadataTypes(String sourceOrgId,String targetOrgId) {
        
        List<MetadataTypeWrapper> metadataTypes = new List<MetadataTypeWrapper>();
        
        // Get Authorized__c records for both source and target orgs
        List<Authorized__c> sourceOrgs = [ SELECT access_token__c, instance_url__c FROM Authorized__c WHERE Id = :sourceOrgId];
        List<Authorized__c> targetOrgs = [ SELECT access_token__c, instance_url__c FROM Authorized__c WHERE Id = :targetOrgId];
        try{
            if (!sourceOrgs.isEmpty() && !targetOrgs.isEmpty()) {
                // Since Id is unique, we can assume only one record is returned for each org
                Authorized__c sourceOrg = sourceOrgs[0];
                Authorized__c targetOrg = targetOrgs[0];
                
                // Call the createService method with access tokens and instance URLs
                MetadataService.MetadataPort sourceService = createService(sourceOrg.access_token__c, sourceOrg.instance_url__c);
                MetadataService.MetadataPort targetService = createService(targetOrg.access_token__c, targetOrg.instance_url__c );
                
                // List available Metadata Types via the 'describeMetadata' API call for the source org
                MetadataService.DescribeMetadataResult sourceDescribeResult = sourceService.describeMetadata(METADATA_API_VERSION );
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
                    metadataTypes.add(new MetadataTypeWrapper(metadataTypeName, metadataTypeName));
                }
            } else {
                System.debug('No records found for the provided org Ids');
            }
        } catch(exception e){
            System.debug('Error in getMetadataTypes method:'+e);
        }
        
        System.debug('metadataTypes' + metadataTypes);
        
        return metadataTypes;
        
        
    }
    
    
    //This method is used to invoked by lwc 
    @AuraEnabled(cacheable = true)
    public static Map<String, List<MetadataItemWrapper>> getSelectedMetadataItemsForOrgs(List<String> selectedTypes, Boolean isSourceOrg, String sourceOrgId, String targetOrgId) {
        
        Map<String, List<MetadataItemWrapper>> selectedMetadataItemsMap = new Map<String, List<MetadataItemWrapper>>();
        
        try{
            // Retrieve selected metadata items for the source org
            List<MetadataItemWrapper> sourceMetadataItems = getSelectedMetadataItems(selectedTypes, isSourceOrg, sourceOrgId, targetOrgId);
            selectedMetadataItemsMap.put('source', sourceMetadataItems);
            
            // Retrieve selected metadata items for the target org
            List<MetadataItemWrapper> targetMetadataItems = getSelectedMetadataItems(selectedTypes, !isSourceOrg, sourceOrgId, targetOrgId);
            selectedMetadataItemsMap.put('target', targetMetadataItems);
            
        } catch(exception e){
            System.debug('Error in getSelectedMetadataItemsForOrgs method:'+e);
        }
        return selectedMetadataItemsMap;
    }
    
    
    //This method is used to retrieve Selected metadata types items
    @AuraEnabled(cacheable = true)
    public static List<MetadataItemWrapper> getSelectedMetadataItems(List<String> selectedTypes, Boolean isSourceOrg, String sourceOrgId, String targetOrgId) {
        List<MetadataItemWrapper> metadataItems = new List<MetadataItemWrapper>();
        if (selectedTypes != null && !selectedTypes.isEmpty()) {
            System.debug('selectedTypes'+selectedTypes);
            String orgId = isSourceOrg ? sourceOrgId : targetOrgId;
            List<Authorized__c> orgs = [SELECT access_token__c, instance_url__c FROM Authorized__c WHERE Id = :orgId ];
            if (!orgs.isEmpty()) {
                Authorized__c orgRecord = orgs[0];
                
                // Call the createService method with access token and instance URL
                MetadataService.MetadataPort service = createService( orgRecord.access_token__c,  orgRecord.instance_url__c );
                
                for (String metaDataType : selectedTypes) {
                    // List metadata items for the current metadata type
                    List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
                    MetadataService.ListMetadataQuery query = new MetadataService.ListMetadataQuery();
                    System.debug('metaDataType : selectedTypes '+metaDataType);
                    query.type_x = metaDataType;
                    queries.add(query);
                    
                    // Call the listMetadata method to retrieve metadata items for the current type
                    MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
                    
                    // Process the retrieved metadata items and add them to the result list
                    if (fileProperties != null) {
                        
                        for (MetadataService.FileProperties fileProperty : fileProperties) {
                            metadataItems.add( new MetadataItemWrapper(fileProperty.fullName, EncodingUtil.urlDecode(fileProperty.fullName, 'UTF-8'),metaDataType,fileProperty.lastModifiedDate
));
                        }
                    } 
                }
            }   else {
                System.debug('No records found for the provided org Id');
            }
        }
        System.debug('metadataItems: ' + metadataItems);
        
        return metadataItems;
    }
    
    private static MetadataService.MetadataPort createService(String accessToken, String instanceUrl) {
        // Use the access token and instance URL to create the MetadataService
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        try{
            
            
            // Check if the instance URL is not null before creating the endpoint_x
            if (instanceUrl != null) {
                String endpoint_x = instanceUrl + '/services/Soap/m/' + METADATA_API_VERSION;
                service.endpoint_x = endpoint_x;
            }
            
            service.SessionHeader = new MetadataService.SessionHeader_element();
            service.SessionHeader.sessionId = accessToken;	
        } catch(exception e){
            System.debug('Error in createService method:'+e);
        }
        return service;
    }
    
}