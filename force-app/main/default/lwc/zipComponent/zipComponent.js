import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jsZipLibrary from '@salesforce/resourceUrl/jszip';


export default class ZipComponent extends LightningElement {
    jsZipInitialized = false;

    connectedCallback() {
        // Load JSZip library dynamically
        if (!this.jsZipInitialized) {
            loadScript(this, jsZipLibrary)
                .then(() => {
                    this.jsZipInitialized = true;
                })
                .catch(error => {
                    console.error('Error loading JSZip:', error);
                });
        }
    }

    zipFiles() {
        if (this.jsZipInitialized) {
            const zip = new JSZip();

            // Get all zip entries
            const zipEntries = this.template.querySelectorAll('c-zip-entry');
            zipEntries.forEach(zipEntry => {
                const filename = zipEntry.fileName;
                const content = zipEntry.fileContent;
                if (filename && content) {
                    zip.file(filename, content);
                }
            });

            // Generate the zip and execute the oncomplete JavaScript
            zip.generateAsync({ type: 'blob' }).then(blob => {
                const zipFileName = 'myZipFile.zip'; // Change this to your desired zip file name
                const url = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = url;
                link.download = zipFileName;
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                eval(this.oncomplete); // Execute the oncomplete JavaScript
            });
        }
    }

}