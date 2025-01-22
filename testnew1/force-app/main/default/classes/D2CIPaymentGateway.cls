public interface D2CIPaymentGateway {
    // Process payment with the given amount and payment details
    Map<String, Object> processPayment(Decimal amount, Map<String, Object> paymentDetails);
    
    // Validate payment details before processing
    Boolean validatePaymentDetails(Map<String, Object> paymentDetails);
    
    // Refund a payment
    Map<String, Object> refundPayment(String paymentId, Decimal amount);
    
    // Get payment status
    String getPaymentStatus(String paymentId);
}