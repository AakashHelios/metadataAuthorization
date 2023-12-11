import { LightningElement } from 'lwc';
import testBoomiAPI from '@salesforce/apex/CheckApiBoomi.testBoomiAPI';


export default class Apitest extends LightningElement {

    handleTestButtonClick() {
        // Call the Boomi API test method
        testBoomiAPI()
            .then(result => {
                // Handle the result, e.g., show a success message
                console.log('API Test Successful: ', result);
            })
            .catch(error => {
                // Handle any errors, e.g., show an error message
                console.error('API Test Error: ', error);
            });
    }

}