import { LightningElement, api } from 'lwc';

export default class MyComponent extends LightningElement {
  @api sourceArray;
  @api targetArray;
}
