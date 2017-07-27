//
//  InAppPurchaseManager.h
//  Population Clock
//
//  Created by Fernando Lemos on 05/09/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <StoreKit/StoreKit.h>

extern NSString *InAppPurchaseManagerRetrievedProducts;
extern NSString *InAppPurchaseManagerFaieldToRetrieveProducts;
extern NSString *InAppPurchasePurchasedRemoveAds;

@interface InAppPurchaseManager : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign, readonly) BOOL canMakePayments;
@property (nonatomic, assign, readonly) BOOL adsRemoved;

+ (InAppPurchaseManager *)sharedInstance;

- (BOOL)retrieveProducts;
- (void)purchaseRemoveAdsWithCallback:(void (^)(BOOL))callback;

@end
