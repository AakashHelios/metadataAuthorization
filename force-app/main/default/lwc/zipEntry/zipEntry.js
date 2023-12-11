import { LightningElement, api } from 'lwc';

export default class ZipEntry extends LightningElement {
    @api path;
     data;

    connectedCallback() {
        const event = new CustomEvent('zipentrydata', {
            detail: {
                path: this.path,
                data: this.data,
            },
        });
        this.dispatchEvent(event);
    }
}
