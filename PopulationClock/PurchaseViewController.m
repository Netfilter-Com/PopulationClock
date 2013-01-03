//
//  PurchaseViewController.m
//  PopulationClock
//
//  Created by Pedro Paulo Oliveira Jr on 02/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "PurchaseViewController.h"


@interface PurchaseViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end

@implementation PurchaseViewController
#define INAPP_PURCHASE_ITEM @"REMOVE_ADS_POPCLOCK"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_activity startAnimating];
    [self performSelector:@selector(fetchProducts) withObject:nil afterDelay:0.5];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setActivity:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Store Implementation

-(void)fetchProducts {
    // Check if we can make payments
    if (![SKPaymentQueue canMakePayments]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry!", @"")
                                                            message:NSLocalizedString(@"This device cannot make payments", @"") delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alertView show];
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    
    // Query the store
    _request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:INAPP_PURCHASE_ITEM]];
    _request.delegate = self;
	[_request start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    // Done with the request
    _request.delegate = nil;
    _request = nil;
    
    // Make sure we get a response
    if ([response.products count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry!", @"")
                                                            message:NSLocalizedString(@"The products are not available in Apple App Store now. Maybe you can try later", @"")
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alertView show];
        [self dismissModalViewControllerAnimated:YES];
        return;
    }
    // Add the payment to the payment queue
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:[response.products objectAtIndex:0]]];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry!", @"")
                                                        message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
    [alertView show];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"removeAds"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // Let others know about this purchase
                [[NSNotificationCenter defaultCenter] postNotificationName:PurchaseNotification object:self userInfo:nil];
                [self dismissModalViewControllerAnimated:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"%@",transaction.debugDescription);
                [self dismissModalViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}

-(IBAction)StopPurchaseEvent:(id)sender {
    // Cancel the products request
    _request.delegate = nil;
    [_request cancel];
    _request = nil;
}
@end
