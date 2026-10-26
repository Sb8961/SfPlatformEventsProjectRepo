import { LightningElement, track } from 'lwc';
import { subscribe, onError } from 'lightning/empApi';

export default class PlatformEventSubscriber extends LightningElement {
    @track message = '';
    @track status = '';

    channelName = '/event/Account_PE__e';

    connectedCallback() {
        this.subscribeToEvent();
    }

    // Subscribe to the Platform Event
    subscribeToEvent() {
        subscribe(this.channelName, -1, (event) => {
            const eventData = event.data.payload;
            this.message = eventData.Account_Name__c;
            this.status = 'Account rating is changed';
        }).then(response => {
            console.log('Subscribed to Platform Event: ', response.channel);
        });
    }

    
}