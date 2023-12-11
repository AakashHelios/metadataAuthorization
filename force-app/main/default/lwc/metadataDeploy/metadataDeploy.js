import { LightningElement, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import deployZip from "@salesforce/apex/MetadataDeployment.deployZip";

export default class MetadataDeploy extends LightningElement {
  packageXml;
  helloWorldMetadata;
  helloWorld;
  zipData;
  asyncResult;

  recordId = "<recordId>";

  @wire(getRecord, {
    recordId: "$recordId",
    fields: ["Authorized__c.access_token__c", "Authorized__c.instance_url__c"]
  })
  authorizedRecord;

  @wire(deployZip, {
    packageXml: "$packageXml",
    helloWorldMetadata: "$helloWorldMetadata",
    helloWorld: "$helloWorld"
  })
  generateZipResult({ error, data }) {
    if (data) {
      this.zipData = data;
    } else if (error) {
      console.log(error, "error");
    }
  }
  generateZip() {
    if (!this.isNull(this.zipData)) {
      deployZip({ zipData: this.zipData })
        .then((result) => {
          this.asyncResult = result;
          console.log(result, "result");
        })
        .catch((error) => {
          console.log("error", error);
        });
    }
  }
}
