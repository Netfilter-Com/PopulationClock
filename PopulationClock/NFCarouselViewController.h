//
//  NFCarouselViewController.h
//  ContainerTest
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFCarouselViewController : UIViewController <UIScrollViewDelegate>

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)rotateLeft;
- (void)rotateRight;

- (void)updateToolbarButtons;

@end

@protocol NFCarouselDataSource <NSObject>

@optional
- (NSArray *)extraToolbarItemsForCarouselViewController:(NFCarouselViewController *)controller;

@end
