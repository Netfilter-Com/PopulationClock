//
//  NFCarouselViewController.h
//  ContainerTest
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NFCarouselViewControllerDelegate;

@interface NFCarouselViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) id <NFCarouselViewControllerDelegate> delegate;

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)rotateLeft;
- (void)rotateRight;

@end

@protocol NFCarouselViewControllerDelegate <NSObject>

@optional
- (NSArray *)extraToolbarItemsForCarouselViewController:(NFCarouselViewController *)controller;

@end
