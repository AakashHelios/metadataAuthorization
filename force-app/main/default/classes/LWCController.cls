public with sharing class LWCController {
    @AuraEnabled(cacheable=true)
    public static List<String> getMetadataTypes() {
        MetadataRetrieveController metadataController = new MetadataRetrieveController();
        // Initialize the metadata controller and retrieve metadata types
        metadataController.init();
        return metadataController.getMetadataTypeNames();
    }
}