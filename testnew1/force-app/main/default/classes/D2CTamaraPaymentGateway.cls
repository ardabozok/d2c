public class D2CTamaraPaymentGateway implements D2CIPaymentGateway {
    private static final String TAMARA_API_URL = 'https://api.tamara.co/';
    private static final String API_KEY = 'your_tamara_api_key';
    
    public Map<String, Object> processPayment(Decimal amount, Map<String, Object> paymentDetails) {
        System.debug('D2CTamaraPaymentGateway.processPayment - Start');
        System.debug('Amount: ' + amount);
        System.debug('Payment Details: ' + paymentDetails);
        
        try {
            /* Real API implementation - Uncomment when ready to use
            // Prepare the request body for Tamara checkout
            Map<String, Object> requestBody = new Map<String, Object>{
                'order' => new Map<String, Object>{
                    'total_amount' => new Map<String, Object>{
                        'amount' => amount,
                        'currency' => 'SAR'
                    },
                    'description' => 'Order payment',
                    'reference_id' => paymentDetails.get('reference'),
                    'country_code' => 'SA',
                    'payment_type' => paymentDetails.get('paymentType'),
                    'consumer' => new Map<String, Object>{
                        'first_name' => paymentDetails.get('firstName'),
                        'last_name' => paymentDetails.get('lastName'),
                        'phone_number' => paymentDetails.get('phoneNumber'),
                        'email' => paymentDetails.get('email')
                    }
                }
            };
            
            // Make API call to Tamara
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TAMARA_API_URL + 'checkout');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + API_KEY);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse response = http.send(request);
            return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            */

            // Mock implementation for testing
            String mockOrderId = 'ord_' + generateRandomString(24);
            String mockCheckoutUrl = 'https://checkout.tamara.co/' + mockOrderId;
            
            Map<String, Object> mockResponse = new Map<String, Object>{
                'id' => mockOrderId,
                'status' => 'approved',
                'order_id' => mockOrderId,
                'checkout_url' => mockCheckoutUrl,
                'amount' => amount,
                'currency' => 'SAR',
                'payment_type' => paymentDetails.get('paymentType'),
                'order_reference_id' => paymentDetails.get('reference'),
                'created_at' => System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'consumer' => new Map<String, Object>{
                    'first_name' => paymentDetails.get('firstName'),
                    'last_name' => paymentDetails.get('lastName'),
                    'email' => paymentDetails.get('email'),
                    'phone' => paymentDetails.get('phoneNumber')
                }
            };
            
            System.debug('Mock Response: ' + mockResponse);
            return mockResponse;
        } catch(Exception e) {
            throw new D2CPaymentGatewayException('Error processing Tamara payment: ' + e.getMessage());
        }
    }
    
    public Map<String, Object> refundPayment(String paymentId, Decimal amount) {
        System.debug('D2CTamaraPaymentGateway.refundPayment - Start');
        System.debug('Payment ID: ' + paymentId);
        System.debug('Amount: ' + amount);
        
        try {
            /* Real API implementation - Uncomment when ready to use
            Map<String, Object> requestBody = new Map<String, Object>{
                'refund' => new Map<String, Object>{
                    'amount' => amount,
                    'currency' => 'SAR',
                    'comment' => 'Refund requested'
                }
            };
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TAMARA_API_URL + 'orders/' + paymentId + '/refunds');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + API_KEY);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(requestBody));
            
            HttpResponse response = http.send(request);
            return (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            */

            // Mock implementation for testing
            String mockRefundId = 'ref_' + generateRandomString(24);
            Map<String, Object> mockResponse = new Map<String, Object>{
                'id' => mockRefundId,
                'status' => 'approved',
                'amount' => amount,
                'currency' => 'SAR',
                'order_id' => paymentId,
                'created_at' => System.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
                'refund_id' => mockRefundId,
                'message' => 'Refund processed successfully'
            };
            
            System.debug('Mock Refund Response: ' + mockResponse);
            return mockResponse;
        } catch(Exception e) {
            throw new D2CPaymentGatewayException('Error processing Tamara refund: ' + e.getMessage());
        }
    }
    
    public String getPaymentStatus(String paymentId) {
        System.debug('D2CTamaraPaymentGateway.getPaymentStatus - Start');
        System.debug('Payment ID: ' + paymentId);
        
        try {
            /* Real API implementation - Uncomment when ready to use
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(TAMARA_API_URL + 'orders/' + paymentId);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + API_KEY);
            
            HttpResponse response = http.send(request);
            Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            return (String)responseBody.get('status');
            */

            // Mock implementation for testing
            return 'approved';
        } catch(Exception e) {
            throw new D2CPaymentGatewayException('Error getting Tamara payment status: ' + e.getMessage());
        }
    }
    
    public Boolean validatePaymentDetails(Map<String, Object> paymentDetails) {
        // Validate required fields for Tamara
        String[] requiredFields = new String[]{
            'firstName', 'lastName', 'email', 'phoneNumber', 'paymentType'
        };
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