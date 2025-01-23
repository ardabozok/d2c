public class D2CCheckoutComPaymentGateway implements D2CIPaymentGateway {
    private static final String CHECKOUT_API_URL = 'https://api.sandbox.checkout.com/payments';
    private static final String API_KEY = 'sk_sbox_mqw4ju27rdmbvc4pt7snl27qpag';
    
    public Map<String, Object> processPayment(Decimal amount, Map<String, Object> paymentDetails) {
        System.debug('D2CCheckoutComPaymentGateway.processPayment - Start');
        System.debug('Amount: ' + amount);
        System.debug('Payment Details: ' + paymentDetails);
        
        try {
            /* Real API implementation - Uncomment when ready to use
            // Prepare the request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'source' => new Map<String, Object>{
                    'type' => 'card',
                    'number' => paymentDetails.get('cardNumber'),
                    'expiry_month' => paymentDetails.get('expiryMonth'),
                    'expiry_year' => paymentDetails.get('expiryYear'),
                    'cvv' => paymentDetails.get('cvv')
                },
                'amount' => (Integer)(amount * 100), // Convert to cents
                'currency' => paymentDetails.get('currency'),
                'reference' => paymentDetails.get('reference')
            };
            
            // Make API call to Checkout.com
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CHECKOUT_API_URL);
            request.setMethod('POST');
            request.setHeader('Authorization', API_KEY);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse response = http.send(request);
            return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            */

            // Mock implementation for testing
            String mockPaymentId = 'pay_' + generateRandomString(24);
            Map<String, Object> mockResponse = new Map<String, Object>{
                'id' => mockPaymentId,
                'status' => 'Authorized',
                'amount' => amount,
                'currency' => paymentDetails.get('currency'),
                'reference' => paymentDetails.get('reference'),
                'processed_on' => System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'response_code' => '10000',
                'response_summary' => 'Approved',
                'source' => new Map<String, Object>{
                    'type' => 'card',
                    'last4' => String.valueOf(paymentDetails.get('cardNumber')).right(4),
                    'expiry_month' => paymentDetails.get('expiryMonth'),
                    'expiry_year' => paymentDetails.get('expiryYear')
                }
            };
            
            System.debug('Mock Response: ' + mockResponse);
            return mockResponse;
        } catch(Exception e) {
            throw new D2CPaymentGatewayException('Error processing Checkout.com payment: ' + e.getMessage());
        }
    }
    
    public Map<String, Object> refundPayment(String paymentId, Decimal amount) {
        System.debug('D2CCheckoutComPaymentGateway.refundPayment - Start');
        System.debug('Payment ID: ' + paymentId);
        System.debug('Amount: ' + amount);
        
        try {
            /* Real API implementation - Uncomment when ready to use
            Map<String, Object> requestBody = new Map<String, Object>{
                'amount' => (Integer)(amount * 100)
            };
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CHECKOUT_API_URL + '/' + paymentId + '/refunds');
            request.setMethod('POST');
            request.setHeader('Authorization', API_KEY);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse response = http.send(request);
            return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            */

            // Mock implementation for testing
            String mockRefundId = 'ref_' + generateRandomString(24);
            Map<String, Object> mockResponse = new Map<String, Object>{
                'id' => mockRefundId,
                'status' => 'Succeeded',
                'amount' => amount,
                'reference' => paymentId,
                'processed_on' => System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'response_code' => '10000',
                'response_summary' => 'Refund approved'
            };
            
            System.debug('Mock Refund Response: ' + mockResponse);
            return mockResponse;
        } catch(Exception e) {
            throw new D2CPaymentGatewayException('Error processing refund: ' + e.getMessage());
        }
    }
    
    public String getPaymentStatus(String paymentId) {
        System.debug('D2CCheckoutComPaymentGateway.getPaymentStatus - Start');
        System.debug('Payment ID: ' + paymentId);
        
        try {
            /* Real API implementation - Uncomment when ready to use
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CHECKOUT_API_URL + '/' + paymentId);
            request.setMethod('GET');
            request.setHeader('Authorization', API_KEY);
            
            HttpResponse response = http.send(request);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (String)responseBody.get('status');
            */

            // Mock implementation for testing
            return 'Succeeded';
        } catch(Exception e) {
            throw new D2CPaymentGatewayException('Error getting payment status: ' + e.getMessage());
        }
    }
    
    public Boolean validatePaymentDetails(Map<String, Object> paymentDetails) {
        // Validate required fields
        String[] requiredFields = new String[]{'cardNumber', 'expiryMonth', 'expiryYear', 'cvv', 'currency'};
        for(String field : requiredFields) {
            if(!paymentDetails.containsKey(field) || paymentDetails.get(field) == null) {
                return false;
            }
        }
        return true;
    }
    
    private String generateRandomString(Integer length) {
        final String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }
}