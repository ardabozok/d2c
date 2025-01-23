global with sharing class D2CMultiPaymentGatewayAdapter implements commercepayments.PaymentGatewayAdapter {
    @TestVisible private static final String CHECKOUT_METHOD = 'CREDIT_CARD';
    @TestVisible private static final String TAMARA_METHOD = 'TAMARA_BNPL';
    
    @TestVisible private static final commercepayments.SalesforceResultCodeInfo SUCCESS_RESULT_INFO = 
        new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
    @TestVisible private static final commercepayments.SalesforceResultCodeInfo ERROR_RESULT_INFO = 
        new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.SystemError);

    global commercepayments.GatewayResponse processRequest(commercepayments.PaymentGatewayContext gatewayContext) {
        System.debug('D2CMultiPaymentGatewayAdapter.processRequest - Start');
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.PaymentGatewayRequest paymentRequest = gatewayContext.getPaymentRequest();
        System.debug('Request Type: ' + requestType);
        System.debug('Payment Request: ' + paymentRequest);

        try {
            if (requestType == commercepayments.RequestType.Authorize) {
                System.debug('Processing Authorization Request');
                return createAuthResponse((commercepayments.AuthorizationRequest)paymentRequest);
            } 
            else if (requestType == commercepayments.RequestType.Capture) {
                System.debug('Processing Capture Request');
                return createCaptureResponse((commercepayments.CaptureRequest)paymentRequest);
            }
            else if (requestType == commercepayments.RequestType.Sale) {
                System.debug('Processing Sale Request');
                return createSaleResponse((commercepayments.SaleRequest)paymentRequest);
            }
            else if (requestType == commercepayments.RequestType.ReferencedRefund) {
                System.debug('Processing Refund Request');
                return createRefundResponse((commercepayments.ReferencedRefundRequest)paymentRequest);
            }
            else {
                System.debug('Unsupported Request Type: ' + requestType);
                return createErrorResponse('Unsupported request type: ' + requestType);
            }
        } catch (Exception e) {
            System.debug('Error in processRequest: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            return createErrorResponse(e.getMessage());
        }
    }

    private commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
        System.debug('D2CMultiPaymentGatewayAdapter.createAuthResponse - Start');
        System.debug('Auth Request: ' + authRequest);
        commercepayments.AuthorizationResponse response = new commercepayments.AuthorizationResponse();
        
        if (authRequest.amount == null) {
            System.debug('Error: Amount is null');
            throw new SalesforceValidationException('Required Field Missing: Amount');
        }
        
        try {
            Map<String, Object> paymentDetails = buildPaymentDetails(authRequest);
            System.debug('Payment Details: ' + paymentDetails);
            
            D2CPaymentService.PaymentResult result = D2CPaymentService.processPayment(
                getPaymentMethod(authRequest),
                authRequest.amount,
                paymentDetails
            );
            System.debug('Payment Result: ' + result);

            response.setAmount(authRequest.amount);
            if (result.isSuccess) {
                System.debug('Authorization Successful');
                response.setGatewayResultCode(result.status);
                response.setGatewayResultCodeDescription('Success');
                response.setGatewayAuthCode(result.paymentId);
                response.setGatewayReferenceNumber(result.paymentId);
                response.setSalesforceResultCodeInfo(SUCCESS_RESULT_INFO);
            } else {
                System.debug('Authorization Failed: ' + result.message);
                response.setGatewayResultCode('ERROR');
                response.setGatewayResultCodeDescription(result.message);
                response.setSalesforceResultCodeInfo(ERROR_RESULT_INFO);
            }
            response.setGatewayDate(System.now());
            return response;
        } catch (Exception e) {
            System.debug('Error in createAuthResponse: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            return createErrorResponse(e.getMessage());
        }
    }

    private commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
        commercepayments.CaptureResponse response = new commercepayments.CaptureResponse();
        
        if (captureRequest.amount == null) {
            throw new SalesforceValidationException('Required Field Missing: Amount');
        }

        response.setAmount(captureRequest.amount);
        response.setGatewayResultCode('SUCCESS');
        response.setGatewayResultCodeDescription('Capture processed');
        response.setGatewayReferenceNumber('CAP-' + generateRandomString(6));
        response.setSalesforceResultCodeInfo(SUCCESS_RESULT_INFO);
        response.setGatewayDate(System.now());
        return response;
    }

    private commercepayments.GatewayResponse createSaleResponse(commercepayments.SaleRequest saleRequest) {
        commercepayments.SaleResponse response = new commercepayments.SaleResponse();
        
        if (saleRequest.amount == null) {
            throw new SalesforceValidationException('Required Field Missing: Amount');
        }
        
        try {
            Map<String, Object> paymentDetails = buildPaymentDetails(saleRequest);
            D2CPaymentService.PaymentResult result = D2CPaymentService.processPayment(
                getPaymentMethod(saleRequest),
                saleRequest.amount,
                paymentDetails
            );

            response.setAmount(saleRequest.amount);
            if (result.isSuccess) {
                response.setGatewayResultCode(result.status);
                response.setGatewayResultCodeDescription('Success');
                response.setGatewayReferenceNumber(result.paymentId);
                response.setSalesforceResultCodeInfo(SUCCESS_RESULT_INFO);
            } else {
                response.setGatewayResultCode('ERROR');
                response.setGatewayResultCodeDescription(result.message);
                response.setSalesforceResultCodeInfo(ERROR_RESULT_INFO);
            }
            response.setGatewayDate(System.now());
            return response;
        } catch (Exception e) {
            return createErrorResponse(e.getMessage());
        }
    }

    private commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
        commercepayments.ReferencedRefundResponse response = new commercepayments.ReferencedRefundResponse();
        
        if (refundRequest.amount == null) {
            throw new SalesforceValidationException('Required Field Missing: Amount');
        }
        
        try {
            D2CPaymentService.PaymentResult result = D2CPaymentService.refundPayment(
                getPaymentMethod(refundRequest),
                refundRequest.PaymentId,
                refundRequest.amount
            );

            response.setAmount(refundRequest.amount);
            if (result.isSuccess) {
                response.setGatewayResultCode(result.status);
                response.setGatewayResultCodeDescription('Success');
                response.setGatewayReferenceNumber(result.paymentId);
                response.setSalesforceResultCodeInfo(SUCCESS_RESULT_INFO);
            } else {
                response.setGatewayResultCode('ERROR');
                response.setGatewayResultCodeDescription(result.message);
                response.setSalesforceResultCodeInfo(ERROR_RESULT_INFO);
            }
            response.setGatewayDate(System.now());
            return response;
        } catch (Exception e) {
            return createErrorResponse(e.getMessage());
        }
    }

    private String getPaymentMethod(commercepayments.PaymentGatewayRequest request) {
        if (request instanceof commercepayments.AuthorizationRequest) {
            commercepayments.AuthorizationRequest authRequest = (commercepayments.AuthorizationRequest)request;
            if (authRequest.paymentMethod != null && authRequest.paymentMethod.cardPaymentMethod != null) {
                return CHECKOUT_METHOD;
            }
        }
        
        Map<String, String> params = getAdditionalParams(request);
        if (params != null && params.containsKey('paymentType') 
            && params.get('paymentType').startsWith('TAMARA')) {
            return TAMARA_METHOD;
        }
        return CHECKOUT_METHOD;
    }

    private Map<String, Object> buildPaymentDetails(commercepayments.PaymentGatewayRequest request) {
        System.debug('D2CMultiPaymentGatewayAdapter.buildPaymentDetails - Start');
        System.debug('Request: ' + request);
        
        Map<String, Object> paymentDetails = new Map<String, Object>();
        String paymentMethod = getPaymentMethod(request);
        System.debug('Payment Method: ' + paymentMethod);

        if (paymentMethod == CHECKOUT_METHOD && request instanceof commercepayments.AuthorizationRequest) {
            System.debug('Building Credit Card Payment Details');
            commercepayments.AuthorizationRequest authRequest = (commercepayments.AuthorizationRequest)request;
            commercepayments.CardPaymentMethodRequest cardRequest = authRequest.paymentMethod.cardPaymentMethod;
            paymentDetails.put('cardNumber', cardRequest.cardNumber);
            paymentDetails.put('expiryMonth', cardRequest.expiryMonth);
            paymentDetails.put('expiryYear', cardRequest.expiryYear);
            paymentDetails.put('cvv', cardRequest.cvv);
            paymentDetails.put('currency', 'USD');
        } else if (paymentMethod == TAMARA_METHOD) {
            System.debug('Building Tamara Payment Details');
            Map<String, String> params = getAdditionalParams(request);
            paymentDetails.put('firstName', params.get('firstName'));
            paymentDetails.put('lastName', params.get('lastName'));
            paymentDetails.put('email', params.get('email'));
            paymentDetails.put('phoneNumber', params.get('phoneNumber'));
            paymentDetails.put('installmentPlan', params.get('paymentType'));
        }

        String currencyCode = getCurrencyIsoCode(request);
        String paymentId = getPaymentId(request);
        System.debug('Currency Code: ' + currencyCode);
        System.debug('Payment ID: ' + paymentId);
        
        paymentDetails.put('currencyCode', currencyCode);
        paymentDetails.put('reference', paymentId);
        
        System.debug('Final Payment Details: ' + paymentDetails);
        return paymentDetails;
    }

    private Map<String, String> getAdditionalParams(commercepayments.PaymentGatewayRequest request) {
        if (request instanceof commercepayments.AuthorizationRequest) {
            return ((commercepayments.AuthorizationRequest)request).additionalData;
        } else if (request instanceof commercepayments.CaptureRequest) {
            return ((commercepayments.CaptureRequest)request).additionalData;
        } else if (request instanceof commercepayments.SaleRequest) {
            return ((commercepayments.SaleRequest)request).additionalData;
        } else if (request instanceof commercepayments.ReferencedRefundRequest) {
            return ((commercepayments.ReferencedRefundRequest)request).additionalData;
        }
        return new Map<String, String>();
    }

    private String getCurrencyIsoCode(commercepayments.PaymentGatewayRequest request) {
        if (request instanceof commercepayments.AuthorizationRequest) {
            return ((commercepayments.AuthorizationRequest)request).currencyIsoCode;
        } else if (request instanceof commercepayments.CaptureRequest) {
            return 'USD';
        } else if (request instanceof commercepayments.SaleRequest) {
            return ((commercepayments.SaleRequest)request).currencyIsoCode;
        } else if (request instanceof commercepayments.ReferencedRefundRequest) {
            return 'USD';
        }
        return null;
    }

    private String getPaymentId(commercepayments.PaymentGatewayRequest request) {
        if (request instanceof commercepayments.AuthorizationRequest) {
            return ((commercepayments.AuthorizationRequest)request).paymentMethod?.cardPaymentMethod?.cardNumber;
        } else if (request instanceof commercepayments.CaptureRequest) {
            return ((commercepayments.CaptureRequest)request).paymentAuthorizationId;
        } else if (request instanceof commercepayments.SaleRequest) {
            return ((commercepayments.SaleRequest)request).paymentMethod?.cardPaymentMethod?.cardNumber;
        } else if (request instanceof commercepayments.ReferencedRefundRequest) {
            return ((commercepayments.ReferencedRefundRequest)request).PaymentId;
        }
        return null;
    }

    private commercepayments.GatewayErrorResponse createErrorResponse(String message) {
        commercepayments.GatewayErrorResponse response = new commercepayments.GatewayErrorResponse('400', message);
        return response;
    }

    private String generateRandomString(Integer length) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    private class SalesforceValidationException extends Exception {}

    @AuraEnabled
    global static D2CPaymentService.PaymentResult processPayment(Map<String, Object> request) {
        System.debug('D2CMultiPaymentGatewayAdapter.processPayment - Start');
        System.debug('Raw Request: ' + JSON.serialize(request));
        
        try {
            String paymentMethod = String.valueOf(request.get('paymentMethod'));
            
            // Handle amount conversion properly
            Object amountObj = '100';
            System.debug('Amount Object: ' + amountObj);
            Decimal amount;
            if (amountObj instanceof String) {
                amount = Decimal.valueOf((String)amountObj);
            } else if (amountObj instanceof Decimal) {
                amount = (Decimal)amountObj;
            } else if (amountObj instanceof Integer) {
                amount = Decimal.valueOf((Integer)amountObj);
            } else if (amountObj instanceof Double) {
                amount = Decimal.valueOf((Double)amountObj);
            } else {
                throw new SalesforceValidationException('Invalid amount format');
            }
            
            Map<String, Object> paymentDetails = new Map<String, Object>();
            
            System.debug('Payment Method: ' + paymentMethod);
            System.debug('Converted Amount: ' + amount);
            
            // Add common fields
            paymentDetails.put('currencyCode', String.valueOf(request.get('currencyCode')));
            paymentDetails.put('reference', String.valueOf(request.get('referenceNumber')));
            
            // Add payment method specific details
            if (paymentMethod == CHECKOUT_METHOD) {
                System.debug('Processing Credit Card Payment');
                Object cardDetailsObj = request.get('cardDetails');
                System.debug('Card Details Object: ' + JSON.serialize(cardDetailsObj));
                
                if (cardDetailsObj != null) {
                    // Convert the Object to a Map<String, Object> using JSON serialization/deserialization
                    Map<String, Object> cardDetails = (Map<String, Object>)JSON.deserializeUntyped(
                        JSON.serialize(cardDetailsObj)
                    );
                    System.debug('Converted Card Details: ' + JSON.serialize(cardDetails));
                    
                    paymentDetails.put('cardNumber', String.valueOf(cardDetails.get('cardNumber')));
                    paymentDetails.put('expiryMonth', String.valueOf(cardDetails.get('expiryMonth')));
                    paymentDetails.put('expiryYear', String.valueOf(cardDetails.get('expiryYear')));
                    paymentDetails.put('cvv', String.valueOf(cardDetails.get('cvv')));
                    paymentDetails.put('currency', 'USD');
                }
            } else if (paymentMethod == TAMARA_METHOD) {
                System.debug('Processing Tamara Payment');
                Object additionalDataObj = request.get('additionalData');
                System.debug('Additional Data Object: ' + JSON.serialize(additionalDataObj));
                
                if (additionalDataObj != null) {
                    // Convert the Object to a Map<String, Object> using JSON serialization/deserialization
                    Map<String, Object> additionalData = (Map<String, Object>)JSON.deserializeUntyped(
                        JSON.serialize(additionalDataObj)
                    );
                    System.debug('Converted Additional Data: ' + JSON.serialize(additionalData));
                    
                    paymentDetails.put('firstName', String.valueOf(additionalData.get('firstName')));
                    paymentDetails.put('lastName', String.valueOf(additionalData.get('lastName')));
                    paymentDetails.put('email', String.valueOf(additionalData.get('email')));
                    paymentDetails.put('phoneNumber', String.valueOf(additionalData.get('phoneNumber')));
                    paymentDetails.put('paymentType', String.valueOf(additionalData.get('paymentType')));
                }
            }
            
            System.debug('Map size: ' + paymentDetails.size());
            System.debug('Final Payment Details: ' + JSON.serialize(paymentDetails));
            D2CPaymentService.PaymentResult result = D2CPaymentService.processPayment(paymentMethod, amount, paymentDetails);
            System.debug('Payment Result: ' + JSON.serialize(result));
            return result;
        } catch (Exception e) {
            System.debug('Error in processPayment: ' + e.getMessage());
            System.debug('Stack Trace: ' + e.getStackTraceString());
            D2CPaymentService.PaymentResult result = new D2CPaymentService.PaymentResult(false, e.getMessage());
            return result;
        }
    }
}