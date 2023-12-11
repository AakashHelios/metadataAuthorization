import { LightningElement, wire, track } from "lwc";
import getAuthorizedRecords from "@salesforce/apex/AuthorizedPicklistValuesController.getAuthorizedRecords";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getComparions from "@salesforce/apex/ApexComparision.getComparions";
import deployApexClass from "@salesforce/apex/MetadataDeployment.deployApexClass";

export default class AuthorizationTab extends LightningElement {
  @track selectedSource;
  @track selectedTarget;
  @track sourceOptions = [];
  @track targetOptions = [];
  isTargetDisabled = true;
  @track apexClassName;
  showTable = false;
  datatable = [];
  disableCompareButton = true;
  disableDeployButton = true;

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
    this.updateCompareButtonState();
    this.updateDeployButtonState();
  }

  handleTargetChange(event) {
    this.selectedTarget = event.detail.value;
    this.updateCompareButtonState();
    this.updateDeployButtonState();
  }

  updateCompareButtonState() {
    this.disableCompareButton = !this.selectedSource || !this.selectedTarget;
  }

  updateDeployButtonState() {
    this.disableDeployButton = !this.selectedSource || !this.selectedTarget;
  }

  getTargetOptions() {
    if (this.selectedSource) {
      return this.targetOptions.filter(
        (option) => option.value !== this.selectedSource
      );
    }
    return this.targetOptions;
  }

  handleCompareClick() {
    this.showTable = true;
    if (this.selectedSource && this.selectedTarget) {
      getComparions({
        targetOrg: this.selectedTarget,
        sourceOrg: this.selectedSource
      })
        .then((result) => {
          this.datatable = result;
        })
        .catch((error) => {
          console.error("Error fetching result:", error);
          this.showToastMessage("Error fetching result", "error");
        });
    } else {
      this.showToastMessage(
        "Please select both source and target values",
        "error"
      );
    }
  }

  handleDeployClick() {
    deployApexClass({
        sourceOrg: this.selectedSource,
        targetOrg: this.selectedTarget,
        apexClassName: this.apexClassName
    })
    .then((result) => {
        this.showToastMessage("Apex class deployed successfully", "success");
        this.deploymentResult = result;
        // Handle the result if needed
        console.log(result);
    })
    .catch((error) => {
        this.showToastMessage("Error deploying Apex class", "error");
        this.deploymentResult = 'Error deploying Apex class: ' + error.body.message ;
        console.log(error);
        this.isLoading = false;
    });
}

  handleApexClassChange(event) {
    this.apexClassName = event.target.value;
  }

  handleReset() {
    this.showTable = false;
    this.selectedSource = null;
    this.selectedTarget = null;
    this.updateCompareButtonState();
    this.updateDeployButtonState();
  }

  showToastMessage(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }
}
