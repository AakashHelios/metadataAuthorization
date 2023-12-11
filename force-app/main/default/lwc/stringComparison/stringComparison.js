import { LightningElement, track } from 'lwc';

export default class StringComparison extends LightningElement {
  sourceArray = [
    { body: 'Sed ut perspiciatis unde omnis iste' },
    { body: '', blankline: 1 },
    { body: 'Architecto beatae vitae dicta sunt', foundIndex: 1 },
    { body: 'Teachings of the great', foundIndex: -1 },
    { body: 'Beatae vitae teachings of the great', foundIndex: -1 },
    { body: '', blankline: 1 },
    { body: 'Hell33o', foundIndex: 1 },
  ];

  targetArray = [
    { body: 'Sed ut perspiciatis unde omnis iste' },
    { body: 'Explorer of the truth', foundIndex: -1 },
    { body: 'Architecto beatae vitae dicta sunt', foundIndex: 1 },
    { body: '', blankline: 1 },
    { body: '', blankline: 1 },
    { body: 'Explorer of the truth', foundIndex: -1 },
    { body: 'Hell33o', foundIndex: 1 },
  ];

  @track sourceArrayWithClass = [];
  @track targetArrayWithClass = [];
  searchTerm1 = '';
  searchTerm2 = '';
 
  connectedCallback() {
    this.calculateItemClasses();
  }

  calculateItemClasses() {
    this.sourceArrayWithClass = this.sourceArray.map((sourceItem) => ({
      ...sourceItem,
      cssClass:sourceItem.foundIndex === -1? 'highlight-green': sourceItem.blankline === 1? 'blank-line': '',}));

    this.targetArrayWithClass = this.targetArray.map((targetItem) => ({
      ...targetItem,
      cssClass:
        targetItem.foundIndex === -1 ? 'highlight-red': targetItem.blankline === 1
          ? 'blank-line'
          : '',
    }));
  }
//this is for the search filter in both the arrays
  get filteredSourceArray() {
    if (!this.searchTerm1) {
      return this.sourceArrayWithClass;
    }
    const searchTerm = this.searchTerm1.toLowerCase();
    return this.sourceArrayWithClass.filter((sourceItem) =>
      sourceItem.body.toLowerCase().includes(searchTerm)
    );
  }

  get filteredTargetArray() {
    if (!this.searchTerm2) {
      return this.targetArrayWithClass;
    }
    const searchTerm = this.searchTerm2.toLowerCase();
    return this.targetArrayWithClass.filter((targetItem) =>
      targetItem.body.toLowerCase().includes(searchTerm)
    );
  }

  handleSourceSearch(event) {
    this.searchTerm1 = event.target.value;
  }

  handleTargetSearch(event) {
    this.searchTerm2 = event.target.value;
  }
 
  
}
