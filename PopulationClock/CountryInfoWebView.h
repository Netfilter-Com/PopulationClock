//
//  CountryInfoWebView.h
//  PopulationClock
//
//  Created by Fernando Lemos on 20/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface CountryInfoWebView : UIView

@property (nonatomic, readonly) UIScrollView *scrollView;

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

@end
