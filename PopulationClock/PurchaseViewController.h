//
//  PurchaseViewController.h
//  PopulationClock
//
//  Created by Pedro Paulo Oliveira Jr on 02/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "globals.h"

@interface PurchaseViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    SKProductsRequest *_request;
}
@end
