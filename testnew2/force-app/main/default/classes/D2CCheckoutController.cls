public without sharing class D2CCheckoutController {
    @AuraEnabled
    public static String getActiveCartId() {
        try {
            System.debug('Current User ID: ' + UserInfo.getUserId());
            System.debug('User Type: ' + UserInfo.getUserType());
            
            // Get the current WebStore ID
            String webstoreId;
            String networkId = Network.getNetworkId();
            System.debug('Network ID: ' + networkId);
            
            // Query WebStore directly
            List<WebStore> stores = [
                SELECT Id, Name 
                FROM WebStore 
                WHERE Type = 'B2C'
                LIMIT 1
            ];
            
            if(!stores.isEmpty()) {
                webstoreId = stores[0].Id;
                System.debug('Found WebStore: ' + stores[0].Name + ' with ID: ' + webstoreId);
            } else {
                System.debug('No WebStore found');
                throw new AuraHandledException('No WebStore found');
            }
            
            // Get the guest buyer profile ID
            Id guestProfileId = [SELECT Id FROM Profile WHERE Name = 'Guest License User' LIMIT 1].Id;
            System.debug('Guest Profile ID: ' + guestProfileId);
            
            // Try to get active cart using ConnectApi
            try {
                // First try to get existing cart
                List<WebCart> existingCarts = [
                    SELECT Id, Name, Status, WebStoreId
                    FROM WebCart 
                    WHERE Status = 'Active' 
                    AND WebStoreId = :webstoreId
                    AND OwnerId = :UserInfo.getUserId()
                    ORDER BY LastModifiedDate DESC 
                    LIMIT 1
                ];
                
                String activeCartOrId = 'active'; // Default to 'active' for new cart creation
                
                if (!existingCarts.isEmpty()) {
                    System.debug('Found existing cart: ' + existingCarts[0]);
                    activeCartOrId = existingCarts[0].Id; // Use existing cart ID if found
                }
                
                // Get or create cart using the correct method signature
                ConnectApi.CartSummary cartSummary = ConnectApi.CommerceCart.getOrCreateActiveCartSummary(
                    webstoreId,      // ID of the webstore
                    null,  // Use guest profile ID for guest user context
                    activeCartOrId   // Use existing cart ID or 'active' for new cart
                );
                
                if(cartSummary != null) {
                    System.debug('Cart summary: ' + cartSummary);
                    return cartSummary.cartId;
                }
            } catch(Exception e) {
                System.debug('Error with cart operations: ' + e.getMessage());
                System.debug('Error type: ' + e.getTypeName());
                System.debug('Error stack: ' + e.getStackTraceString());
            }
            
            throw new AuraHandledException('Unable to get or create cart');
            
        } catch (Exception e) {
            System.debug('Error in getActiveCartId: ' + e.getMessage());
            System.debug('Error type: ' + e.getTypeName());
            System.debug('Error stack: ' + e.getStackTraceString());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
}