import { LightningElement, api, wire } from 'lwc';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { getRecord } from 'lightning/uiRecordApi';
import getActiveCartId from '@salesforce/apex/D2CCheckoutController.getActiveCartId';

export default class D2cCheckout extends LightningElement {
    @api recordId; // This will be the cart ID
    @api accountId;
    
    flowStarted = false;
    flowStatus = '';
    flowInputs = [];

    async connectedCallback() {
        console.log('D2C Checkout initialized');
        try {
            // Get active cart ID if not provided
            if (!this.recordId) {
                const result = await getActiveCartId();
                this.recordId = result;
                //this.accountId = "0058d000007niOdAAI";
                console.log('Retrieved active cart ID:', this.recordId);
            }

            this.accountId = "0058d000007niOdAAI";
            
            // Set up flow inputs
            this.flowInputs = [
                {
                    name: 'cartId',
                    type: 'String',
                    value: this.recordId
                },
                {
                    name: 'accountId',
                    type: 'String',
                    value: this.accountId
                }
            ];
            console.log('Flow inputs prepared:', JSON.stringify(this.flowInputs));
            console.log('Ardaaaa')
        } catch (error) {
            console.error('Error initializing checkout:', error);
        }
    }

    handleFlowStatusChange(event) {
        console.log('Flow status changed:', event.detail.status);
        console.log('Flow event details:', JSON.stringify(event.detail));
        
        this.flowStatus = event.detail.status;
        if (event.detail.status === 'FINISHED') {
            // Handle flow completion - e.g., redirect to order confirmation
            const outputVariables = event.detail.outputVariables;
            console.log('Flow output variables:', JSON.stringify(outputVariables));
            
            const orderNumber = outputVariables.find(variable => variable.name === 'orderNumber')?.value;
            if (orderNumber) {
                // Handle successful order creation
                this.handleOrderSuccess(orderNumber);
            }
        } else if (event.detail.status === 'ERROR') {
            console.error('Flow error:', event.detail.error);
        }
    }

    handleOrderSuccess(orderNumber) {
        // Navigate to order confirmation or handle success
        console.log('Order created successfully:', orderNumber);
    }
}