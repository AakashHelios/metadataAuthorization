import { LightningElement } from 'lwc';

export default class ParentComponent extends LightningElement {
  sourceArray = [
    { id: 1, value: 5, highlightClass: '' },
    { id: 2, value: -1, highlightClass: 'highlight-green' },
    { id: 3, value: 8, highlightClass: '' },
  ];

  targetArray = [
    { id: 1, value: 10, highlightClass: '' },
    { id: 2, value: -1, highlightClass: 'highlight-red' },
    { id: 3, value: 15, highlightClass: '' },
  ];
}
