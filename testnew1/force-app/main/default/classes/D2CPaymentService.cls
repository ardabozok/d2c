global class D2CPaymentService {
    global class PaymentResult {
        @AuraEnabled global Boolean isSuccess { get; set; }
        @AuraEnabled global String message { get; set; }
        @AuraEnabled global String paymentId { get; set; }
        @AuraEnabled global String status { get; set; }
        @AuraEnabled global Map<String, Object> additionalData { get; set; }
        
        global PaymentResult(Boolean isSuccess, String message) {
            System.debug('Creating PaymentResult - Success: ' + isSuccess + ', Message: ' + message);
            this.isSuccess = isSuccess;
            this.message = message;
            this.additionalData = new Map<String, Object>();
        }

        private void setAdditionalData(Map<String, Object> sourceMap) {
            System.debug('Setting additional data map');
            if (sourceMap != null) {
                this.additionalData = new Map<String, Object>(sourceMap);
            }
            System.debug('Set additional data: ' + this.additionalData);
        }
    }
    
    @AuraEnabled
    global static PaymentResult processPayment(String paymentMethod, Decimal amount, Map<String, Object> paymentDetails) {
        System.debug('D2CPaymentService.processPayment - Start');
        System.debug('Payment Method: ' + paymentMethod);
        System.debug('Amount: ' + amount);
        
        // Break down payment details into smaller chunks for debugging
        if (paymentDetails != null) {
            System.debug('Payment Details Keys: ' + paymentDetails.keySet());
            for (String key : paymentDetails.keySet()) {
                System.debug('Payment Detail - ' + key + ': ' + paymentDetails.get(key));
            }
        }
        
        try {
            // Convert string payment method to enum
            System.debug('Converting payment method to enum: ' + paymentMethod);
            D2CPaymentGatewayFactory.PaymentMethod method = D2CPaymentGatewayFactory.PaymentMethod.valueOf(paymentMethod);
            
            // Get the appropriate payment gateway
            System.debug('Creating payment gateway for method: ' + method);
            D2CIPaymentGateway gateway = D2CPaymentGatewayFactory.createPaymentGateway(method);
            
            // Validate payment details
            System.debug('Validating payment details');
            if (!gateway.validatePaymentDetails(paymentDetails)) {
                System.debug('Payment details validation failed');
                return new PaymentResult(false, 'Invalid payment details provided');
            }
            
            // Process the payment
            System.debug('Processing payment through gateway');
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(
                JSON.serialize(gateway.processPayment(amount, paymentDetails))
            );
            
            // Break down result into smaller chunks for debugging
            if (result != null) {
                System.debug('Payment Result Keys: ' + result.keySet());
                for (String key : result.keySet()) {
                    System.debug('Result - ' + key + ': ' + result.get(key));
                }
            }
            
            // Create success response
            System.debug('Creating success response');
            PaymentResult response = new PaymentResult(true, 'Payment processed successfully');
            response.paymentId = String.valueOf(result.get('id'));
            response.status = String.valueOf(result.get('status'));
            response.setAdditionalData(result);
            
            // Debug response details individually
            System.debug('Response - isSuccess: ' + response.isSuccess);
            System.debug('Response - message: ' + response.message);
            System.debug('Response - paymentId: ' + response.paymentId);
            System.debug('Response - status: ' + response.status);
            if (response.additionalData != null) {
                System.debug('Response - additionalData keys: ' + response.additionalData.keySet());
            }
            
            return response;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in processPayment: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            return new PaymentResult(false, 'Payment processing failed: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    global static PaymentResult refundPayment(String paymentMethod, String paymentId, Decimal amount) {
        System.debug('D2CPaymentService.refundPayment - Start');
        System.debug('Payment Method: ' + paymentMethod);
        System.debug('Payment ID: ' + paymentId);
        System.debug('Amount: ' + amount);
        
        try {
            System.debug('Converting payment method to enum: ' + paymentMethod);
            D2CPaymentGatewayFactory.PaymentMethod method = D2CPaymentGatewayFactory.PaymentMethod.valueOf(paymentMethod);
            
            System.debug('Creating payment gateway for method: ' + method);
            D2CIPaymentGateway gateway = D2CPaymentGatewayFactory.createPaymentGateway(method);
            
            System.debug('Processing refund through gateway');
            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(
                JSON.serialize(gateway.refundPayment(paymentId, amount))
            );
            System.debug('Gateway refund result: ' + result);
            
            System.debug('Creating success response');
            PaymentResult response = new PaymentResult(true, 'Refund processed successfully');
            response.paymentId = String.valueOf(result.get('id'));
            response.status = String.valueOf(result.get('status'));
            response.setAdditionalData(result);
            
            System.debug('Final refund response: ' + response);
            return response;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in refundPayment: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            return new PaymentResult(false, 'Refund processing failed: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    global static PaymentResult getPaymentStatus(String paymentMethod, String paymentId) {
        System.debug('D2CPaymentService.getPaymentStatus - Start');
        System.debug('Payment Method: ' + paymentMethod);
        System.debug('Payment ID: ' + paymentId);
        
        try {
            System.debug('Converting payment method to enum: ' + paymentMethod);
            D2CPaymentGatewayFactory.PaymentMethod method = D2CPaymentGatewayFactory.PaymentMethod.valueOf(paymentMethod);
            
            System.debug('Creating payment gateway for method: ' + method);
            D2CIPaymentGateway gateway = D2CPaymentGatewayFactory.createPaymentGateway(method);
            
            System.debug('Getting payment status from gateway');
            String status = gateway.getPaymentStatus(paymentId);
            System.debug('Gateway status result: ' + status);
            
            System.debug('Creating success response');
            PaymentResult response = new PaymentResult(true, 'Payment status retrieved successfully');
            response.status = status;
            
            System.debug('Final status response: ' + response);
            return response;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in getPaymentStatus: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Stack trace: ' + e.getStackTraceString());
            return new PaymentResult(false, 'Failed to retrieve payment status: ' + e.getMessage());
        }
    }
}