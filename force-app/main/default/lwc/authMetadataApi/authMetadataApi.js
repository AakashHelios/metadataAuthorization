import { LightningElement, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAuthorizedRecords from "@salesforce/apex/AuthorizedPicklistValuesController.getAuthorizedRecords";
import getMetadataTypes from "@salesforce/apex/MetadataTypesRetriever.getMetadataTypes";
import getSelectedMetadataItemsForOrgs from "@salesforce/apex/MetadataTypesRetriever.getSelectedMetadataItemsForOrgs";
import deployMetadataItems from "@salesforce/apex/MetadataDeployment.deployMetadataItems";
import checkDeploymentStatus from "@salesforce/apex/MetadataDeployment.checkDeploymentStatus";
import getmetadatazips from "@salesforce/apex/MetadataDeployment.getmetadatazips";


const columns = [
  { label: "Name", fieldName: "fullName" },
  { label: "Metadata Type", fieldName: "metaDataType" },
  { label: "Category", fieldName: "category" }
  
 
];

export default class AuthMetadataApi extends LightningElement {

  @track TypeofValidation
  @track selectedSource;
  @track selectedTarget;
  @track sourceOptions = [];
  @track targetOptions = [];
  @track selectedRows = [];
  @track metadataitem;
  @track metadataDetails = {
    source: [],
    target: []
  };
  columns = columns;
  filteredMetadataDetails = [];
  isTargetDisabled = true;
  showSourceTarget = true;
  showMetadataTypes = false;
  showDataTable = false;
  metadataTypes = [];
  selectedMetadataTypes = [];
  selectedItems = [];
  showTextArea = false;
  showCompareCard = false;
  updatethesource;
  loaded = true;
  disableValidate=true;
  disablebuttonmenu=true;
  diablenext1=true;
  disableDualPicklistNext=true;
  disableDownload=true;

  RecordPicklistValues(records) {
    return records.map((record) => {
      return {
        label: record.Name,
        value: record.Id
      };
    });
  }

  @wire(getAuthorizedRecords)
  authorizedRecords({ error, data }) {
    if (data) {
      this.sourceOptions = this.RecordPicklistValues(data);
      this.targetOptions = this.RecordPicklistValues(data);
      this.isTargetDisabled = this.targetOptions.length === 0;
    } else if (error) {
      console.error("Error records:", error);
    }
  }

  handleSourceChange(event) {
    this.selectedSource = event.detail.value;
    this.targetOptions = this.getTargetOptions();
    this.isTargetDisabled = this.targetOptions.length === 0;
    console.log('event',this.selectedSource);
    this.diablenext1=true;

    
    
  }

  handleTargetChange(event) {
    this.selectedTarget = event.detail.value;
    if(this.selectedSource || this.selectedTarget ){
      this.diablenext1=false;
    }else {
      this.diablenext1=true;
    }
    
  }

  getTargetOptions() {
    return this.sourceOptions.filter(
      (option) => option.value !== this.selectedSource
    );
  }

  // Fetch metadata types for the selected source and target orgs
  @wire(getMetadataTypes, {
    sourceOrgId: "$selectedSource",
    targetOrgId: "$selectedTarget"
  })
  wiredMetadataTypes({ error, data }) {
    if (data) {
      this.metadataTypes = data.map((metadataType) => {
        return {
          label: metadataType.label,
          value: metadataType.value
        };
      });
      console.log('data', data);
    } else if (error) {
      console.error("Error retrieving metadata types:", error);
    }
  }

  handleNext1() {
    this.showSourceTarget = false;
    this.showMetadataTypes = true;
  }

  handlePrevious() {
    this.showSourceTarget = true;
    this.showMetadataTypes = false;
  }

  handleNextForDatatable() {
    // Fetch selected metadata items for both orgs in datatable 
    getSelectedMetadataItemsForOrgs({
      selectedTypes: this.selectedMetadataTypes,
      isSourceOrg: true,
      sourceOrgId: this.selectedSource,
      targetOrgId: this.selectedTarget
    })
      .then((result) => {
        console.log(result.source);
        console.log(result.target);
        // Merge source and target arrays into a single array
        this.metadataDetails.source = result.source.map((item) => ({
          ...item,
          category: "New"
        }));
        this.metadataDetails.target = result.target.map((item) => ({
          ...item,
          category: "Deleted"
        }));
        this.filteredMetadataDetails = [
          ...this.metadataDetails.source,
          ...this.metadataDetails.target
        ];
  
        const commonMetadataItems = result.source.filter((sourceItem) =>
          result.target.some(
            (targetItem) => targetItem.fullName === sourceItem.fullName
          )
        );
        console.log("commonMetadataItems", commonMetadataItems);
  
        // Check if there are common metadata items for comparison
        if (commonMetadataItems.length > 0) {
          // Retrieve content for comparison
          //this.retrieveAndCompareContent(commonMetadataItems);
        } else {
          this.showToastMessage(
            "No common metadata items for comparison",
            "info"
          );
        }
  
        this.showDataTable = true;
      })
      .catch((error) => {
        console.error("Error retrieving metadata items:", error);
      });
  }
  
  retrieveAndCompareContent(metadataItems) {
    // Create a copy of the metadataDetails object to update category values
    const updatedMetadataDetails = { ...this.metadataDetails };
  
    // Loop through each metadata item
    metadataItems.forEach((metadataItem) => {
      const metadataItemNames = [metadataItem.fullName];
  
      // Retrieve content for both source and target orgs
      Promise.all([
        getmetadatazips({
          sourceOrg: this.selectedSource,
          targetOrg: this.selectedTarget,
          metadataItemNames: metadataItemNames,
          metadataType: "ApexClass"
        }),
        getmetadatazips({
          sourceOrg: this.selectedTarget,
          targetOrg: this.selectedSource,
          metadataItemNames: metadataItemNames,
          metadataType: "ApexClass"
        })
      ])
        .then(([sourceData, targetData]) => {
         
  
          // Compare the base64 content
          const comparisonResult = this.compareBase64Content(
            sourceData,
            targetData
          );
  
          // Update the category based on the comparison result
          if (comparisonResult === "Different") {
            //console.log(" metadataItem.category", metadataItem.category);
            updatedMetadataDetails[metadataItem.source ? 'source' : 'target'] = updatedMetadataDetails[metadataItem.source ? 'source' : 'target'].map(item => {
              if (item.fullName === metadataItem.fullName) {
                return {
                  ...item,
                  category: "Different"
                };
              }
              return item;
            });
          } else if (comparisonResult === "No Difference") {
            updatedMetadataDetails[metadataItem.source ? 'source' : 'target'] = updatedMetadataDetails[metadataItem.source ? 'source' : 'target'].map(item => {
              if (item.fullName === metadataItem.fullName) {
                return {
                  ...item,
                  category: "No Difference"
                };
              }
              return item;
            });
          
          }
  
          // Continue processing or updating your UI as needed
          //console.log("Updated metadataItem:", metadataItem); // Add this line to check if the category is correctly updated
        })
        .catch((error) => {
          // Handle the error
          console.error(error);
        });
    });
  
    // Set the updated metadataDetails back to the component's state
    this.metadataDetails = updatedMetadataDetails;
  
    // Add this line to ensure the data table updates with the new category values
    this.filteredMetadataDetails = [
      ...updatedMetadataDetails.source,
      ...updatedMetadataDetails.target
    ];
  }
  
  compareBase64Content(base64Content1, base64Content2) {
    // Convert base64 strings to binary data
    const binaryData1 = atob(base64Content1);
    const binaryData2 = atob(base64Content2);
  
    // Convert binary data to Uint8Arrays
    const uint8Array1 = new Uint8Array(binaryData1.length);
    const uint8Array2 = new Uint8Array(binaryData2.length);
  
    for (let i = 0; i < binaryData1.length; i++) {
      uint8Array1[i] = binaryData1.charCodeAt(i);
    }
  
    for (let i = 0; i < binaryData2.length; i++) {
      uint8Array2[i] = binaryData2.charCodeAt(i);
    }
  
    // Compare the Uint8Arrays element by element
    if (uint8Array1.length !== uint8Array2.length) {
      //console.log('Different',uint8Array1.length,'!=',uint8Array2.length);
      return 'Different';
    }

      //console.log('No Different',uint8Array1.length,'=',uint8Array2.length);
      return 'No Difference';
    
  
    // for (let i = 0; i < uint8Array1.length; i++) {
    //   console.log('Different',uint8Array1.length,uint8Array2.length);
    //   if (uint8Array1[i] !== uint8Array2[i]) {
    //     return 'Different';
    //   }
  
  }
  
  


  handleAllItems() {
    this.filteredMetadataDetails = this.metadataDetails.source.concat(
      this.metadataDetails.target
    );
  }

  handleNewItems() {
    this.filteredMetadataDetails = this.metadataDetails.source.filter(
      (item) => item.category === "New"
    );
  }

  handleDifferentItems() {
    this.filteredMetadataDetails = this.metadataDetails.target.filter(
      (item) => item.category === "Different"
    );
  }

  handleDeletedItems() {
    this.filteredMetadataDetails = this.metadataDetails.target.filter(
      (item) => item.category === "Deleted"
    );
  }

  handleSelectedItems() {
    this.filteredMetadataDetails = this.metadataDetails.source
      .concat(this.metadataDetails.target)
      .filter((item) => this.selectedItems.includes(item.fullName));
  }

  handlePreviousDatatable() {
    this.showDataTable = false;
    this.filteredMetadataDetails = [];
  }

  handleMetadataTypesChange(event) {
    
    this.selectedMetadataTypes = event.detail.value;
    console.log('this.selectedMetadataTypes',this.selectedMetadataTypes);
   let Countselectedmetadatatype=event.detail.value.length;
    if(Countselectedmetadatatype){

      this.disableDualPicklistNext=false;
    }else{
      this.disableDualPicklistNext=true;
    }
  }

  showToastMessage(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  handleCheckboxSelection(event) {
    console.log('event',event.detail.selectedRows.length);
    let countcheckboxselection = event.detail.selectedRows.length;
    this.selectedItems = event.detail.selectedRows.map((row) => row.fullName);
   if(countcheckboxselection){
    this.disableValidate=false;
    this.disablebuttonmenu=false;
    this.disableDownload=false;
    console.log('selectedItems',JSON.stringify(this.selectedItems));
  }else{
    this.disableValidate=true;
    this.disablebuttonmenu=true;
    this.disableDownload=true;
    console.log('selectedItems',JSON.stringify(this.selectedItems));
   }
   
   
  }

  handleValidateClick() {
    this.loaded = false;
    
    if(this.TypeofValidation== null){
      this.TypeofValidation='NoTestRun';
    }else{
      console.log('TypeofValidation=',this.TypeofValidation);
    }
    
    // Check if any metadata items have been selected
    if (!this.selectedItems || this.selectedItems.length === 0) {
      // No metadata items selected
      this.showToastMessage("No metadata items selected", "warning");
      return;
    }
    console.log('this.selectedMetadataTypes',this.selectedMetadataTypes);
    // Deploy the metadata items
    deployMetadataItems({
      
      sourceOrg: this.selectedSource,
      targetOrg: this.selectedTarget,
      metadataItemNames: this.selectedItems,
      metadataType: this.selectedMetadataTypes[0],
      TypeofValidation: this.TypeofValidation
    })

    
      .then((result) => {
       
        // Deployment successful
        console.log(" this.TypeofValidation=", this.TypeofValidation);
        console.log(" Validation Status", result);
        
        this.showToastMessage(
          `Validation Status: ${result}`,
          "info"
        );

        this.showTextArea = true;
        this.errorData = result;
        console.log("Validation Status:", result);
        this.loaded = true;
        // // Get the deployment ID from the result (assuming it's included in the message)
        // const deploymentId = result.split(":")[1].trim();

        // // Call the method to check deployment status
        // this.checkDeploymentStatus(deploymentId, this.selectedTarget);
      })
      .catch((error) => {
        // Deployment failed
        this.showToastMessage(
          `Validation Error metadata items: ${error.message}`,
          "error"
        );
        console.error('Validation Error', JSON.stringify(error));
      });
  }

  checkDeploymentStatus(deploymentId, targetOrg) {
    // Call the checkDeploymentStatus method
    return checkDeploymentStatus({
      deploymentId: deploymentId,
      targetOrg: targetOrg
    })
      .then((statusResult) => {
        this.showTextArea = true;
        this.errorData = statusResult;
        console.log("Deployment Status:", statusResult);
        return statusResult; // Return the status result if needed
      })
      .catch((error) => {
        // Error while checking deployment status
        console.error("Error checking deployment status:", error);
        throw error; // Rethrow the error to the caller
      });
  }

  handlehideStatus() {
    this.showTextArea = false;
  }

  handleDownload() {
    // Call the Apex method
    getmetadatazips({
      sourceOrg: this.selectedSource,
      targetOrg: this.selectedTarget,
      metadataItemNames: this.selectedItems,
      metadataType: "ApexClass"
    })
      .then((result) => {
        // Handle the result, e.g., initiate the download
        this.downloadFile(result);
      })
      .catch((error) => {
        // Handle the error
        console.error(error);
      });
  }

  downloadFile(combinedZip) {
    const link = document.createElement("a");
    link.href = "data:application/zip;base64," + combinedZip;
    link.download = "metadata.zip";
    console.log("Downloaded", link.download);
    link.click();
  }

 async handleCompare() {
   let data1=await getmetadatazips({
      sourceOrg: this.selectedSource,
      targetOrg: this.selectedTarget,
      metadataItemNames: this.selectedItems,
      metadataType: "ApexClass"
    })
    console.log(data1);
    const base64String = data1; 
     const decodedString = atob(base64String);
     console.log(decodedString);

    




      // .then((data) => {
      //   this.showCompareCard = true;
      //   console.log('in getmetadatazips');
      //   console.log('data'+data);

      //   const base64String = data; 
      //   const decodedString = atob(base64String);

      //   console.log(decodedString);
      //   return data;
      // })
      // .catch((error) => {
      //   // Error while checking deployment status
      //   console.error("Error checking deployment status:", error);
      //   throw error; // Rethrow the error to the caller
      // });
      // console.log('End');
  }

  



  


  handlehidecomparison() {
    this.showCompareCard = false;
  } 



  validateOptionHandle(event){
    this.TypeofValidation=event.target.value;

    console.log('validateOptionHandle',this.TypeofValidation);
  }
  
  

  


  

}

