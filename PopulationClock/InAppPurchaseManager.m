//
//  InAppPurchaseManager.m
//  Population Clock
//
//  Created by Fernando Lemos on 05/09/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "InAppPurchaseManager.h"

NSString *InAppPurchaseManagerRetrievedProducts = @"InAppPurchaseManagerRetrievedProducts";
NSString *InAppPurchaseManagerFaieldToRetrieveProducts = @"InAppPurchaseManagerFaieldToRetrieveProducts";
NSString *InAppPurchasePurchasedRemoveAds = @"InAppPurchasePurchasedRemoveAds";

#define REMOVE_ADS_PRODUCT_NAME @"REMOVE_ADS_POPCLOCK"
#define REMOVE_ADS_DEFAULTS_KEY @"removeAds"

@implementation InAppPurchaseManager {
    BOOL _retrievingProductData;
    NSMutableDictionary *_products;
    void (^_purchaseCallback)(BOOL);
}

+ (InAppPurchaseManager *)sharedInstance {
    static InAppPurchaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InAppPurchaseManager alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // Check if we have already purchased the option to remove ads
        _adsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:REMOVE_ADS_DEFAULTS_KEY];
        
        // Restore product information if this device can make payments
        // and the option to remove ads hasn't been purchased yet
        _canMakePayments = [SKPaymentQueue canMakePayments];
        if (_canMakePayments && !_adsRemoved) {
            _retrievingProductData = YES;
            [self requestProductData];
        }
    }
    return self;
}

- (BOOL)retrieveProducts {
    if (_canMakePayments && !_products && !_retrievingProductData)
        [self requestProductData];
    return _products != nil;
}

- (void)requestProductData {
    NSArray *products = @[ REMOVE_ADS_PRODUCT_NAME ];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:products]];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
#ifdef DEBUG
    NSLog(@"Successfully retrieved product data for %d product(s)", response.products.count);
#endif
    
    // Map product names to products
    _products = [[NSMutableDictionary alloc] initWithCapacity:response.products.count];
    for (SKProduct *product in response.products)
        [_products setObject:product forKey:product.productIdentifier];
    
    // We are no longer retrieving product data
    _retrievingProductData = NO;
    
    // Set ourselves as transaction observers
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // Let the observers know
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseManagerRetrievedProducts object:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"StoreKit request failed: %@", error.localizedDescription);
#endif
    
    // We're no longer retrieving product data
    _retrievingProductData = NO;
    
    // Let the observers know
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchaseManagerFaieldToRetrieveProducts object:self];
}

- (NSString *)priceForProduct:(NSString *)identifier {
    SKProduct *product = [_products objectForKey:identifier];
    if (product) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        return [numberFormatter stringFromNumber:product.price];
    }
    else {
        return nil;
    }
}

- (NSString *)priceForRemoveAds {
    return [self priceForProduct:REMOVE_ADS_PRODUCT_NAME];
}

- (void)purchaseProduct:(NSString *)identifier callback:(void (^)(BOOL))callback {
    // Make sure we have information about this product
    SKProduct *product = [_products objectForKey:identifier];
    if (product == nil) {
        callback(NO);
        return;
    }
    
    // Save the callback
    _purchaseCallback = callback;
    
    // Add the product to the payment queue
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
}

- (void)purchaseRemoveAdsWithCallback:(void (^)(BOOL))callback {
    [self purchaseProduct:REMOVE_ADS_PRODUCT_NAME callback:callback];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self provideContent:transaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failPurchase:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self provideContent:transaction.originalTransaction.payment.productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)provideRemoveAds {
    // Update our state
    _adsRemoved = YES;
    
    // Write to the user defaults
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMOVE_ADS_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Let the observers know
    [[NSNotificationCenter defaultCenter] postNotificationName:InAppPurchasePurchasedRemoveAds object:self];
}

- (void)provideContent:(NSString *)productName {
#ifdef DEBUG
    NSLog(@"Providing content for purchase: %@", productName);
#endif
    
    // Check if it's one of the known products
    BOOL success = YES;
    if ([productName isEqualToString:REMOVE_ADS_PRODUCT_NAME]) {
        [self provideRemoveAds];
    }
    else {
        NSLog(@"Purchased unknown product: %@", productName);
        success = NO;
    }
    
    // Invoke the callback
    if (_purchaseCallback) {
        _purchaseCallback(success);
        _purchaseCallback = nil;
    }
}

- (void)failPurchase:(SKPaymentTransaction *)transaction {
#ifdef DEBUG
    NSLog(@"Failed to purchase %@", transaction.payment.productIdentifier);
#endif
    
    // Invoke the callback
    if (_purchaseCallback) {
        _purchaseCallback(NO);
        _purchaseCallback = nil;
    }
}

@end
