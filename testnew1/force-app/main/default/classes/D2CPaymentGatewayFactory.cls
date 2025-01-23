public class D2CPaymentGatewayFactory {
    public enum PaymentMethod {
        CREDIT_CARD,
        TAMARA_BNPL
    }
    
    public static D2CIPaymentGateway createPaymentGateway(PaymentMethod method) {
        switch on method {
            when CREDIT_CARD {
                return new D2CCheckoutComPaymentGateway();
            }
            when TAMARA_BNPL {
                return new D2CTamaraPaymentGateway();
            }
            when else {
                throw new D2CPaymentGatewayException('Unsupported payment method');
            }
        }
    }
}