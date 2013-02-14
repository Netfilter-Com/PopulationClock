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

- (void)setViewStealingTouch:(UIView *)view;

@end

@protocol NFCarouselDataSource <NSObject>

@optional

- (void)carouselViewControllerWillBeginDragging:(NFCarouselViewController *)controller;

- (void)carouselViewController:(NFCarouselViewController *)controller
            controllerSelected:(UIViewController *)selectedController;

- (NSArray *)extraToolbarItemsForCarouselViewController:(NFCarouselViewController *)controller;

@end
