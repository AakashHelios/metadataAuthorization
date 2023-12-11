import { LightningElement, wire } from 'lwc';
import getMetadataTypes from '@salesforce/apex/LWCController.getMetadataTypes';


export default class MetadataTypePicklist extends LightningElement {
    metadataTypes = [];
    selectedMetadataType;

    @wire(getMetadataTypes)
    wiredMetadataTypes({ error, data }) {
        if (data) {
            this.metadataTypes = data.map(metadataType => {
                return { label: metadataType, value: metadataType };
            });
            this.selectedMetadataType = data[0]; // Default to the first option
        } else if (error) {
            console.error('Error retrieving metadata types:', error);
        }
    }

    handleChange(event) {
        this.selectedMetadataType = event.detail.value;
        // Do something with the selected metadata type
    }
}
