//
//  MainView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "MainView.h"

@implementation MainView {
    IBOutlet __weak UIScrollView *_scrollView;
    IBOutlet __weak UIImageView *_map;
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // Save the content offset and the previous scale so we
    // can adjust the content offset accordingly after we change
    // the content size
    CGPoint contentOffset = _scrollView.contentOffset;
    CGFloat previousScale = _scrollView.frame.size.width / _map.image.size.width;
    
    // Save and reset the zoom level
    float zoomScale = _scrollView.zoomScale;
    _scrollView.zoomScale = 1;
    
    // Find an appropriate size for the map
    CGFloat scaleX = self.bounds.size.width / _map.image.size.width;
    CGFloat scaleY = self.bounds.size.height / _map.image.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    CGSize mapSize = CGSizeMake(_map.image.size.width * scale, _map.image.size.height * scale);
    
    // Resize the scroll view and the map
    CGRect frame = CGRectMake(0, 0, mapSize.width, mapSize.height);
    _scrollView.frame = frame;
    _scrollView.contentSize = mapSize;
    _map.frame = frame;
    
    // Restore the zoom level
    _scrollView.zoomScale = zoomScale;
    
    // Scale the content offset according to the difference from the
    // previous scale, to keep the image centered at the same point
    // before the change in scale
    CGFloat scaleScale = previousScale == 0 ? 1 : scale / previousScale;
    _scrollView.contentOffset = CGPointMake(contentOffset.x * scaleScale, contentOffset.y * scaleScale);
    
    // TODO: Resize other views
}

@end
