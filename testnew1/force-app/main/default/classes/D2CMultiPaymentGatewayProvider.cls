global class D2CMultiPaymentGatewayProvider {
    global static commercepayments.PaymentGatewayAdapter getPaymentGatewayAdapter(commercepayments.PaymentGatewayContext gatewayContext) {
        return new D2CMultiPaymentGatewayAdapter();
    }
}