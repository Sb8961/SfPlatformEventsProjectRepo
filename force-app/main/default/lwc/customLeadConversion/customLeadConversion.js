import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import findMatchingPatients from '@salesforce/apex/LeadConvertController.findMatchingPatients';
import processLeadConversion from '@salesforce/apex/LeadConvertController.processLeadConversion';

export default class LeadConvertAction extends NavigationMixin(LightningElement) {
    @api recordId; // Captures the current Lead Id
    
    @track matches = [];
    @track showSelectionScreen = false;
    @track isLoading = true; // Starts as true so the spinner shows immediately on load
    
    selectedPatientId = null;
    createNew = false;

    // The wire service automatically waits for this.recordId to be populated 
    // because of the '$' prefix on '$recordId'
    @wire(findMatchingPatients, { leadId: '$recordId' })
    wiredPatients({ error, data }) {
        if (data) {
            if (data.length > 0) {
                // Matches found: populate list and show UI
                this.matches = data.map(contact => ({
                    label: `${contact.Patient__r.Name}`,
                    value: contact.Patient__c
                }));
                this.matches.push({ label: '-- Create New Patient Records --', value: 'CREATE_NEW' });
                this.showSelectionScreen = true;
                this.isLoading = false;
            } else {
                // No matches found: Auto-convert seamlessly
                this.createNew = true;
                this.executeConversion();
            }
        } else if (error) {
            this.handleError(error);
        }
    }

    handleSelection(event) {
        const val = event.detail.value;
        if (val === 'CREATE_NEW') {
            this.createNew = true;
            this.selectedPatientId = null;
        } else {
            this.createNew = false;
            this.selectedPatientId = val;
        }
    }

    handleNext() {
        if (!this.selectedPatientId && !this.createNew) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a match or choose to create new records.',
                variant: 'error'
            }));
            return;
        }
        
        // Trigger the conversion process
        this.executeConversion();
    }

    executeConversion() {
        this.isLoading = true; // Turn spinner back on to block UI while converting on the server

        processLeadConversion({
            leadId: this.recordId,
            selectedPatientId: this.selectedPatientId,
            createNew: this.createNew
        })
            .then(newRecordId => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Lead converted successfully!',
                    variant: 'success'
                }));
                
                // Navigate to the resulting Custom Patient record
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: newRecordId,
                        actionName: 'view'
                    }
                });
            })
            .catch(error => {
                this.handleError(error);
            })
            .finally(() => {
                // The .finally() block ensures the spinner ALWAYS turns off, 
                // even if the Apex method throws an exception.
                this.isLoading = false; 
            });
    }

    handleError(error) {
        this.isLoading = false; // Turn off spinner if an error occurs outside of executeConversion
        let message = 'Unknown error';
        
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body === 'object' && error.body !== null) {
            message = error.body.message;
        }
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        }));
    }
}