public class DeploymentController {
    private static final Integer METADATA_API_VERSION = Integer.valueOf(
        new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/')
    );
    
    //this method is to handle retrieve and deploy    
    @AuraEnabled(cacheable=true)
    public static String deployMetadataItems(String sourceOrg, String targetOrg, List<String> metadataItemNames, String metadataType ) {
        List<String> base64Zips = new List<String>();
        try {
            for (String metadataItemName : metadataItemNames) {
                base64Zips.add(
                    retrieveMetadataItem(sourceOrg, metadataType, metadataItemNames)
                );
            }
            
        } catch (Exception e) {
            // Handle the error
            System.debug(e.getMessage());
            return 'Error retrieving metadata items: ' + e.getMessage();
        }
        
        
        if (base64Zips.isEmpty()) {
            return 'Retrieved metadata items are empty';
        }
        
        
        // Combine the retrieved zip files
        String combinedZip = combineZips(base64Zips);
        
        // Deploy the combined zip file
        return deployZip(targetOrg, combinedZip);
    }
    
    //this method is to retrieve and download the zip file without being deployed
    
    @AuraEnabled(cacheable=true)
    public static String getmetadatazips(String sourceOrg, String targetOrg, List<String> metadataItemNames, String metadataType ) {
        List<String> base64Zips = new List<String>();
        try {
            for (String metadataItemName : metadataItemNames) {
                base64Zips.add(
                    retrieveMetadataItem(sourceOrg, metadataType, metadataItemNames)
                );
            }
            
        } catch (Exception e) {
            // Handle the error
            System.debug(e.getMessage());
            return 'Error retrieving metadata items: ' + e.getMessage();
        }
        
        
        if (base64Zips.isEmpty()) {
            return 'Retrieved metadata items are empty';
        }
        
        // Combine the retrieved zip files
        String combinedZip = combineZips(base64Zips);
        
        
        // return the combined zip file for download
        
        return combinedZip;
    }
    
    // this method is used to combine the zips to single zip
    
    @AuraEnabled(cacheable=true)
    public static String combineZips(List<String> base64ZipList) {
        String combinedBlob = '';
        
        for (String base64Zip : base64ZipList) {
            if (base64Zip.length() > 0) {
                combinedBlob += base64Zip;
            }
        }
        // System.debug('combinedBlob' + combinedBlob);
        return combinedBlob;
    }
    
    
    
    // this method handle retrieveing of selected metadataitems
    
    @AuraEnabled(cacheable=true)
    public static String retrieveMetadataItem(String sourceOrg, String metadataType, List<String> metadataItemNames) {
        MetadataService.MetadataPort service = createService('source', sourceOrg);
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = METADATA_API_VERSION;
        retrieveRequest.singlePackage = true;
        retrieveRequest.packageNames = null;
        retrieveRequest.specificFiles = null;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        
        // Create a list of package type members
        List<MetadataService.PackageTypeMembers> packageTypeMembersList = new List<MetadataService.PackageTypeMembers>();
        try{
            
            
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
            boolean done = false;
            while (!done) {
                retrieveResult = service.checkRetrieveStatus(asyncResult.Id, true);
                if (retrieveResult.done) {		
                    done = true;
                } else {
                    //System.debug('Sleeping for 05 seconds');
                    datetime start = System.now();
                    While(System.now()<start.addseconds(10)){}
                    
                    
                }
            }
            System.debug('retrieve Result in zipFile :- '+retrieveResult.zipFile);
            return retrieveResult.zipFile;
            
        } catch (Exception e) {
            // Handle the error
            System.debug(e.getMessage());
            return 'Error retrieveMetadataItem: ' + e.getMessage();
        }
        
        
    }
    
    //this method is used to deploy
    @AuraEnabled(cacheable=true)
    public static String deployZip(String targetOrg, String combinedZip) {
        MetadataService.MetadataPort service = createService('target', targetOrg);
        
        // Set deploy options for validation
        MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = true; // Set to true for validation
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'RunLocalTests';//'RunSpecifiedTests';
        deployOptions.singlePackage = true;
        /*List<String> tests = new List<String>();
        tests.add('NewStringManipulationUtilityTest');
        deployOptions.runTests = tests; */
        
        /*MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();

	// Set the appropriate test level.
	deployOptions.testLevel = 'RunSpecifiedTests';

	// Specify the test classes to run.
	// String array contains test class names.
	List<String> tests = new List<String>();
	tests.add('StringManipulationUtilityTest');	
	// Add the test class names array to the deployment options.
	deployOptions.runTests = tests;*/
        
        System.debug('targetOrg ' + targetOrg);
        // Deploy metadata for validation
        MetadataService.AsyncResult validationResult = service.deploy(combinedZip, deployOptions);
        System.debug('validation Result:>>'+validationResult);
        // Note the ID from the validation deployment
        String validationId = validationResult.Id;
        // Call the method to initiate a quick deployment
        //String quickDeploymentId = deployRecentValidation(validationId, targetOrg);
        //System.debug('quickDeploymentId'+quickDeploymentId);
        // Return the ID of the quick deployment
        String Deploymentstatus =checkDeploymentStatus(validationId, targetOrg);
        
        //return quickDeploymentId;
        return Deploymentstatus;
    }
    /////////////////////////////////////////////////////////////////////////////////
    
    // One second in milliseconds
    private static final Long ONE_SECOND = 1000L;
    // Maximum number of attempts to deploy the zip file
    private static final Integer MAX_NUM_POLL_REQUESTS = 50;
    
    // This method is used to initiate a quick deployment
    /*public static String deployRecentValidation(String recentValidationId, String targetOrg) {
        //MetadataService.MetadataPort service = createService('target', targetOrg);
        
        // Call deployRecentValidation and obtain the ID of the quick deployment
        String quickDeploymentId = MetadataService.deployRecentValidation(recentValidationId);
        System.debug('In deployRecentValidations quickDeploymentId:' + quickDeploymentId);
        
        // Wait for the deploy to complete
        Integer poll = 0;
        Long waitTimeMilliSecs = ONE_SECOND;
        MetadataService.DeployResult deployResult = null;
        Boolean fetchDetails;
        do {
            
            // Double the wait time for the next iteration
            waitTimeMilliSecs *= 2;
            if (poll++ > MAX_NUM_POLL_REQUESTS) {
                System.debug('Request timed out. If this is a large set ' +
                             'of metadata components, check that the time allowed by ' +
                             'MAX_NUM_POLL_REQUESTS is sufficient.');
                
            }
            
            // Fetch in-progress details once for every 3 polls
            fetchDetails = Math.mod(poll, 3) == 0;
            
            deployResult = MetadataService.checkDeployStatus(quickDeploymentId, fetchDetails);
            System.debug('Status is: ' + deployResult.status);
            if (!deployResult.Done && fetchDetails) {
                System.debug(deployResult + 'Failures for deployment in progress:\n');
            }
        } while (!deployResult.Done);
        
        if (!deployResult.Success && deployResult.errorStatusCode != null) {
            System.debug(deployResult.errorStatusCode + ' msg: ' +
                         deployResult.errorStatusCode);
        }
        
        if (!fetchDetails) {
            // Get the final result with details if we didn't do it in the last attempt.
            deployResult = MetadataService.checkDeployStatus(quickDeploymentId, true);
        }
        
        if (!deployResult.Success) {
            System.debug(deployResult+ 'Final list of failures:\n');
            return 'The files were not successfully deployed';
        }
        
        System.debug('The recent validation ' + recentValidationId +
                     ' was successfully deployed');
        
        // Return the ID of the quick deployment
        return quickDeploymentId;
    }*/
    
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////
    
    
    /**
* Print out any errors, if any, related to the deploy.
* @param result - DeployResult
*/
    
    
    /////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    // this method is used to check status of deployment
    @AuraEnabled(cacheable=true)
    public static String checkDeploymentStatus(String deploymentId, String targetOrg) {
        
        MetadataService.MetadataPort service = createService('target', targetOrg);
        // Query the deployment status
        MetadataService.DeployResult deployResult = service.checkDeployStatus(deploymentId, true);
        System.debug('deploymentId ' + deploymentId);
        String statusMessage = '';
        boolean done = false;
        
        while (!done) {
            statusMessage = 'Validation in Progress... Current State: ' + deployResult.status;
            
            if (deployResult.done) {
                if (deployResult.status == 'Succeeded') {
                    statusMessage = 'Validation Completed successfully';
                } else if (deployResult.status == 'Failed') {
                    if (deployResult.details != null && deployResult.details.componentFailures != null) {
                        statusMessage = 'Validation Failed:';
                        
                        for (MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures) {
                            if (deployMessage.problem != null) {
                                statusMessage += '\n';
                                statusMessage +=  'FullName: ' + deployMessage.fullName + '   Line: ' + deployMessage.lineNumber + '   Column: ' + deployMessage.columnNumber + '  Error Message: ' + deployMessage.problem;
                            }
                        }
                    } else {
                        statusMessage = 'Validation Failed';
                    }
                }
                
                done = true;
            } else {
                System.debug('');
                deployResult = service.checkDeployStatus(deploymentId, true);
            }
        }
        
        return statusMessage;
        
        
    }
    
    
    
    
    
    private static MetadataService.MetadataPort createService(String orgType,String orgId) {
        // Query the Authorized__c record to get the access token and instance URL based on the orgType and orgId
        Authorized__c orgRecord = [ SELECT access_token__c, instance_url__c FROM Authorized__c WHERE Id = :orgId];
        String accessToken = orgRecord.access_token__c;
        String instanceUrl = orgRecord.instance_url__c;
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.endpoint_x = instanceUrl +'/services/Soap/m/' + METADATA_API_VERSION;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken;
        
        return service;
    }
}