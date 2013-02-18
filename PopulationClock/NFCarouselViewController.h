//
//  NFCarouselViewController.h
//  ContainerTest
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModalDialogViewController.h"

@interface NFCarouselViewController : ModalDialogViewController <UIScrollViewDelegate>

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)rotateLeft;
- (void)rotateRight;

- (void)updateToolbarButtons;

- (void)setViewStealingTouch:(UIView *)view;

@end

@protocol NFCarouselDataSource <NSObject>

- (NSArray *)extraToolbarItemsForCarouselViewController:(NFCarouselViewController *)controller;

@end
