import { LightningElement,track } from 'lwc';
    import {
        subscribe,
        unsubscribe,
        onError,
        setDebugFlag,
        isEmpEnabled,
    } from 'lightning/empApi';
    
    export default class SubscribeEvent extends LightningElement {
        channelName = '/data/AccountChangeEvent';
        channelName2 = '/event/Order_Event__e';
        isSubscribeDisabled = false;
        isUnsubscribeDisabled = !this.isSubscribeDisabled;
        dataFetched = false;
        sfOrgId;
        OrderStatus;
        platformEventData;
        platformEventData2;
        @track eventList=[];
        subscription = {};
    
        // Tracks changes to channelName text field
        handleChannelName(event) {
            this.channelName = event.target.value;
        }
    
        // Initializes the component
        connectedCallback() {
            // Register error listener
            this.registerErrorListener();
        }
    
        // Handles subscribe button click
        handleSubscribe() {
            console.log('entered method')
            // Callback invoked whenever a new event message is received
            const messageCallback = (response) => {
                console.log('New message received: ', JSON.stringify(response));
                console.log('New message received: ', JSON.stringify(response.data.payload.OrderStatus__c));
    
                this.dataFetched = true;
                this.platformEventData = JSON.stringify(response);
                // this.sfOrgId = response.data.payload.OrderId__c;
                // this.OrderStatus = response.data.payload.Status__c;
                // Response contains the payload of the new message received
            };
    
            // Invoke subscribe method of empApi. Pass reference to messageCallback
            subscribe(this.channelName, -1, messageCallback).then((response) => {
                // Response contains the subscription information on subscribe call
                console.log(
                    'Subscription request sent to: ',
                    JSON.stringify(response.channel)
                );
                this.subscription = response;
                this.toggleSubscribeButton(true);
            });
        }

        // Handles subscribe2 button click
        handleSubscribe2() {
            console.log('entered method')
            // Callback invoked whenever a new event message is received
            const messageCallback = (response) => {
                console.log('New message received: ', JSON.stringify(response));
                console.log('New message received: ', JSON.stringify(response.data.payload.OrderStatus__c));
    
                this.dataFetched = true;
              
                this.platformEventData2 = JSON.stringify(response);
                this.eventList.push(this.platformEventData2);
                this.sfOrgId = response.data.payload.OrderId__c;
                this.OrderStatus = response.data.payload.Status__c;
                // Response contains the payload of the new message received
            };
    
            // Invoke subscribe method of empApi. Pass reference to messageCallback
            subscribe(this.channelName2, -1, messageCallback).then((response) => {
                // Response contains the subscription information on subscribe call
                console.log(
                    'Subscription request sent to: ',
                    JSON.stringify(response.channel)
                );
                this.subscription = response;
                this.toggleSubscribeButton(true);
            });
        }
    
        // Handles unsubscribe button click
        handleUnsubscribe() {
            this.toggleSubscribeButton(false);
    
            // Invoke unsubscribe method of empApi
            unsubscribe(this.subscription, (response) => {
                console.log('unsubscribe() response: ', JSON.stringify(response));
                // Response is true for successful unsubscribe
            });
        }
    
        toggleSubscribeButton(enableSubscribe) {
            this.isSubscribeDisabled = enableSubscribe;
            this.isUnsubscribeDisabled = !enableSubscribe;
        }
    
        registerErrorListener() {
            // Invoke onError empApi method
            onError((error) => {
                console.log('Received error from server: ', JSON.stringify(error));
                // Error contains the server-side error
            });
        }
    }