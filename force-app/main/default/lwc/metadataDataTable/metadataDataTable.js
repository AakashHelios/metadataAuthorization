import { LightningElement, api } from "lwc";
//import getSelectedMetadataItemsForOrgs from "@salesforce/apex/MetadataTypesRetriever.getSelectedMetadataItemsForOrgs";

const columns = [
  { label: "Name", fieldName: "fullName" },
  { label: "Meatadata Type", fieldName: "metaDataType" }
];

export default class MetadataDataTable extends LightningElement {
  @api selectedMetadataTypes;
  @api metadataDetails = [];
  @api source;
  @api target;
  columns = columns;


  handleAllItems() {
    
  }
  handleNewItems() {}

}
