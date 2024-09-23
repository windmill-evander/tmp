import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getQuotePdf from '@salesforce/apex/QuotePdfControllerLwc.getQuotePdf';

export default class QuoteQuickAction extends LightningElement {
    @api recordId;

    isLoaded = false;

    renderedCallback() {
        if (this.isLoaded) return;
        const style = document.createElement("style");
        style.innerText = `.uiModal--medium .modal-container {
            width: 90% !important;
            height: 90% !important;
            max-width: 100% !important;
            min-width: 600px !important;
            max-height: 100% !important;
            min-height: 600px !important;
        }
        .uiModal--horizontalForm .modal-container {
            width: 90% !important;
            height: 90% !important;
            max-width: 100% !important;
            min-width: 600px !important;
            max-height: 100% !important;
            min-height: 600px !important;
        }`;
        this.template.querySelector('lightning-quick-action-panel').appendChild(style);
        this.isLoaded = true;
    }

    get iframeSrc() {
        return `/apex/QuotePdfContent?id=${this.recordId}`;
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleSave() {
        try {
            const result = await getQuotePdf({ quoteId: this.recordId });
            console.log('PDF saved result:', result); // Optional logging
            this.handleClose(); // Close modal if PDF save is successful
            return result; // Return result to handle in handleEmail
        } catch (error) {
            console.error('Error saving PDF:', error);
            return 'Error'; // Handle the error in handleEmail
        }
    }
    
    async handleEmail() {
        // const saveResult = await this.handleSave(); // Ensure the PDF save completes
        // if (saveResult.includes('successfully')) {
        //     alert('lets send email'); // Trigger email process
        //     // You can implement the actual email logic here, e.g., calling another Apex method.
        // } else {
        //     alert('PDF save failed. Cannot send email.');
        // }
    }
}
