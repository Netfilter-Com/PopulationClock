//
//  NFCarouselViewController.m
//  ContainerTest
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "NFCarouselViewController.h"

@interface NFCarouselTouchHackView : UIView

@property (nonatomic, strong) UIView *viewStealingTouch;

@end

@implementation NFCarouselTouchHackView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.viewStealingTouch) {
        CGPoint subviewPoint = [self.viewStealingTouch convertPoint:point fromView:self];
        UIView *touchedView = [self.viewStealingTouch hitTest:subviewPoint withEvent:event];
        if (touchedView) {
            return touchedView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end

#pragma mark -

@implementation NFCarouselViewController {
    UIToolbar *_toolbar;
    UIScrollView *_scrollView;
    
    NSArray *_orderedControllers;
    NSMutableArray *_controllers;
    
    int _selectedController;
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Save the controllers
        _orderedControllers = viewControllers;
        _controllers = [viewControllers mutableCopy];
    }
    return self;
}

- (void)loadView
{
    // Create the main view
    CGRect frame = [UIScreen mainScreen].bounds;
    self.view = [[NFCarouselTouchHackView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Create the toolbar
    _toolbar = [UIToolbar new];
    _toolbar.barStyle = UIBarStyleBlack;
    [_toolbar sizeToFit];
    CGRect toolbarFrame = _toolbar.frame;
    toolbarFrame.size.width = frame.size.width;
    _toolbar.frame = toolbarFrame;
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_toolbar];
    
    // Create the segmented control items
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:_controllers.count];
    for (UIViewController *controller in _controllers) {
        NSString *title = controller.title;
        if (!title) {
            title = @"Unnamed";
        }
        [items addObject:title];
    }
    
    // Create the scroll view
    frame.origin.y += toolbarFrame.size.height;
    frame.size.height -= toolbarFrame.size.height;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(frame.size.width * _controllers.count, frame.size.height);
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.clipsToBounds = NO;
    [self.view addSubview:_scrollView];
    
    // Add the view controllers
    for (UIViewController *controller in _controllers) {
        [self addChildViewController:controller];
        controller.view.frame = frame;
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
    
    // Start in the middle
    _selectedController = _controllers.count / 2;
    [self setControllersFrame];
    
    // Update the toolbar buttons
    [self updateToolbarButtons];
}

#pragma mark -

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    // This means we should call beginAppearanceTransition:animated: and
    // endAppearanceTransition on the child controllers ourselves. Same
    // for the rotation methods, but we don't care about those for now
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!_scrollView.dragging) {
        [_controllers[_selectedController] beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_scrollView.dragging) {
        [_controllers[_selectedController] endAppearanceTransition];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (!_scrollView.dragging) {
        [_controllers[_selectedController] beginAppearanceTransition:NO animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (!_scrollView.dragging) {
        [_controllers[_selectedController] endAppearanceTransition];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark -

- (void)viewWillLayoutSubviews
{
    CGRect frame = _scrollView.bounds;
    _scrollView.contentSize = CGSizeMake(frame.size.width * _controllers.count, frame.size.height);
    _scrollView.contentOffset = CGPointMake(frame.size.width * _selectedController, 0.0f);
    [self setControllersFrame];
}

- (void)setControllersFrame
{
    CGRect frame = _scrollView.bounds;
    frame.origin = CGPointZero;
    for (UIViewController *controller in _controllers) {
        controller.view.frame = frame;
        frame.origin.x += frame.size.width;
    }
}

- (void)reorderControllers
{
    int middle = _controllers.count / 2;
    while (_selectedController != middle) {
        if (_selectedController-- == 0) {
            _selectedController = _controllers.count - 1;
        }
        [_controllers addObject:_controllers[0]];
        [_controllers removeObjectAtIndex:0];
    }
    
    [self setControllersFrame];
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width * _selectedController, 0.0f);
}

- (void)updateToolbarButtons
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
    
    NSString *title = ((UIViewController *)_controllers[_selectedController - 1]).title;
    if (!title) {
        title = @"Unnamed";
    }
    [items addObject:[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(rotateRight)]];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpace];
    
    UIViewController *current = _controllers[_selectedController];
    if ([current conformsToProtocol:@protocol(NFCarouselDataSource)]) {
        NSArray *extraItems = [(id <NFCarouselDataSource>)current extraToolbarItemsForCarouselViewController:self];
        if (extraItems.count) {
            for (UIBarButtonItem *item in extraItems) {
                [items addObject:item];
            }
            [items addObject:flexibleSpace];
        }
    }
    
    title = ((UIViewController *)_controllers[_selectedController + 1]).title;
    if (!title) {
        title = @"Unnamed";
    }
    [items addObject:[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(rotateLeft)]];
    
    [_toolbar setItems:items animated:YES];
}

- (void)animateAfterRotation
{
    [self.view endEditing:NO];
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width * _selectedController, 0.0f) animated:YES];
}

- (void)rotateLeft
{
    UIViewController *current = _controllers[_selectedController];
    [current beginAppearanceTransition:NO animated:NO];
    [current endAppearanceTransition];
    
    if (++_selectedController == _controllers.count) {
        _selectedController = 0;
    }
    
    [self animateAfterRotation];
}

- (void)rotateRight
{
    UIViewController *current = _controllers[_selectedController];
    [current beginAppearanceTransition:NO animated:NO];
    [current endAppearanceTransition];
    
    if (_selectedController-- == 0) {
        _selectedController = _controllers.count - 1;
    }
    [self animateAfterRotation];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:NO];
    
    UIViewController *current = _controllers[_selectedController];
    [current beginAppearanceTransition:NO animated:NO];
    [current endAppearanceTransition];
}

- (void)adjustAfterScrolling
{
    _selectedController = (int)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    int middle = _controllers.count / 2;
    
    if (_selectedController != middle) {
        [self reorderControllers];
    }
    
    UIViewController *current = _controllers[_selectedController];
    [current beginAppearanceTransition:YES animated:NO];
    [current endAppearanceTransition];
    
    [self updateToolbarButtons];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustAfterScrolling];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self adjustAfterScrolling];
}

#pragma mark -

- (void)setViewStealingTouch:(UIView *)view
{
    ((NFCarouselTouchHackView *)self.view).viewStealingTouch = view;
}

@end
