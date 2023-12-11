import { LightningElement, wire } from 'lwc';
import getURL from '@salesforce/apex/Authrization.getURL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class InitAuthrization extends LightningElement {

    loaded = false;
    domain = '';

    /**
     * Event handler for the domain input field.
     * @param event The event object.
     */
    getDomainValue(event) {
        this.domain = event.target.value;
    }

    /**
     * Redirects the user to the authorization page.
     */
    redirectToAuthPage() {
        if (this.domain !== '') {
            this.loaded = true;
            getURL({Domain: this.domain}).then((res) => {
                this.setTimeoutCallback(() => {
                    this.loaded = false;
                    window.open(res, '_blank');
                }, 3000);
            }).catch((err) => {
                console.error(err);
            });
        } else {
            const evt = new ShowToastEvent({
                title: 'Please enter some value in Domain',
                message: '',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }

    /**
     * Schedules a callback function to be executed after a specified delay.
     * @param callback The callback function to be executed.
     * @param delay The delay in milliseconds.
     */
    
}