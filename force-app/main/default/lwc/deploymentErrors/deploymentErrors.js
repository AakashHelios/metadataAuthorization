import { LightningElement, api } from 'lwc';

const statusColumns = [
    { label: 'Name', fieldName: 'fullName' },
    { label: 'Line', fieldName: 'lineNumber' },
    { label: 'Column', fieldName: 'columnNumber' },
    { label: 'Problem', fieldName: 'problem' }
];

export default class DeploymentErrors extends LightningElement {
    @api deploymentErrors;
    statusColumns = statusColumns;
}
