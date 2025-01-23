import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processPayment from '@salesforce/apex/D2CMultiPaymentGatewayAdapter.processPayment';

export default class D2CPaymentForm extends LightningElement {
    _amount;
    @api 
    get amount() {
        return this._amount;
    }
    set amount(value) {
        console.log('Amount value being set to:', value, typeof value);
        this._amount = value;
    }
    @api recordId;
    @track paymentMethod = 'CREDIT_CARD';
    @track isLoading = false;
    @track paymentDetails = {};

    get paymentMethods() {
        return [
            { label: 'Credit Card', value: 'CREDIT_CARD' },
            { label: 'Tamara Buy Now Pay Later', value: 'TAMARA_BNPL' }
        ];
    }

    get installmentOptions() {
        return [
            { label: 'Pay in 3', value: 'PAY_BY_INSTALMENTS' },
            { label: 'Pay in 6', value: 'PAY_BY_INSTALMENTS_6' }
        ];
    }

    get isCreditCard() {
        return this.paymentMethod === 'CREDIT_CARD';
    }

    get isTamara() {
        return this.paymentMethod === 'TAMARA_BNPL';
    }

    handlePaymentMethodChange(event) {
        this.paymentMethod = event.detail.value;
        this.paymentDetails = {};
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this.paymentDetails[field] = event.target.value;
        //console.log('Updated payment details:', JSON.stringify(this.paymentDetails));
    }

    async handleSubmit() {
        try {
            this.isLoading = true;
            
            console.log('Current payment details:', JSON.stringify(this.paymentDetails));
            
            // Format expiry year to 4 digits if it's 2 digits
            let expiryYear = this.paymentDetails.expiryYear;
            if (expiryYear && expiryYear.length === 2) {
                expiryYear = '20' + expiryYear;
            }
            
            // Convert amount to number
            const numericAmount = parseFloat(this.amount);
            if (isNaN(numericAmount)) {
                throw new Error('Invalid amount value');
            }
            
            const request = {
                paymentMethod: this.paymentMethod,
                amount: numericAmount,
                currencyCode: 'USD',
                referenceNumber: this.recordId
            };

            if (this.isCreditCard) {
                const cardDetails = {
                    cardNumber: this.paymentDetails.cardNumber,
                    expiryMonth: this.paymentDetails.expiryMonth,
                    expiryYear: expiryYear,
                    cvv: this.paymentDetails.cvv
                };
                console.log('Card Details before assignment:', JSON.stringify(cardDetails));
                request.cardDetails = cardDetails;
            } else if (this.isTamara) {
                const additionalData = {
                    firstName: this.paymentDetails.firstName,
                    lastName: this.paymentDetails.lastName,
                    email: this.paymentDetails.email,
                    phoneNumber: this.paymentDetails.phoneNumber,
                    paymentType: this.paymentDetails.installmentPlan
                };
                console.log('Tamara Details before assignment:', JSON.stringify(additionalData));
                request.additionalData = additionalData;
            }
            
            console.log('Final Request:', JSON.stringify(request));
            const result = await processPayment({ request });
            console.log('Payment Result:', JSON.stringify(result));

            if (result.isSuccess) {
                this.showToast('Success', 'Payment processed successfully', 'success');
                this.dispatchEvent(new CustomEvent('paymentcomplete', {
                    detail: {
                        paymentId: result.paymentId,
                        status: result.status
                    }
                }));
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}