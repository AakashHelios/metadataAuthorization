import { LightningElement, track } from "lwc";

import deployApexClass from "@salesforce/apex/MetadataDeployment.deployApexClass";

export default class DeployButton extends LightningElement {
  @track apexClassName = "";
  @track deploymentResult = "";
  @track isLoading = false;

  handleApexClassChange(event) {
    this.apexClassName = event.target.value;
  }

  handleDeployClick() {
    this.isLoading = true;
    deployApexClass({ apexClassName: this.apexClassName })
      .then((result) => {
        this.deploymentResult = result;
        this.isLoading = false;
        console.log(
          this.deploymentResult,
          "deployment result",
          "Apex class name:",
          this.apexClassName
        );
      })
      .catch((error) => {
        this.deploymentResult =
          "Error deploying Apex class: " + error.body.message + error;
        this.isLoading = false;
      });
  }
}
