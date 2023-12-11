import { LightningElement, api } from 'lwc';

export default class CompareContent extends LightningElement {
  @api compareContent1;
  @api compareContent2;
  isZipContent1 = false;
  isZipContent2 = false;

  connectedCallback() {
    if (!this.compareContent1 || !this.compareContent2) {
      return;
    }

    // Check if the content is a zip file (based on some condition, you can update this)
    this.isZipContent1 = this.compareContent1.startsWith('PK');
    this.isZipContent2 = this.compareContent2.startsWith('PK');
  }

  get content1ToShow() {
    return this.isZipContent1 ? 'ZIP Content' : this.compareContent1;
  }

  get content2ToShow() {
    return this.isZipContent2 ? 'ZIP Content' : this.compareContent2;
  }

  handleCloseCompare() {
    const closeEvent = new CustomEvent('close');
    this.dispatchEvent(closeEvent);
  }
}
