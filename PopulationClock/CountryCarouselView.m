//
//  CountryCarouselView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DataManager.h"
#import "CountryCarouselView.h"

@interface CountryCarouselView ()

@property (nonatomic, weak) IBOutlet UIButton *leftArrow;
@property (nonatomic, weak) IBOutlet UIButton *rightArrow;

@end

@implementation CountryCarouselView {
    UIView *_flags[3];
    NSString *_countryCodes[3];
    CGFloat _layoutWidth;
}

- (void)dealloc
{
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    // We are our own delegate
    self.delegate = self;
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Nothing to do if we are the source of the notification
    if (notification.object == self) {
        return;
    }
    
    // Get the selection and reload the flags
    NSString *selection = notification.userInfo[SelectedCountryKey];
    [self reloadWithCountry:selection];
    
    // Point to the flag in the middle
    [self layoutSubviews];
    self.contentOffset = CGPointMake(self.bounds.size.width, 0);
}

- (void)reloadWithCountry:(NSString *)countryCode
{
    // Find the index of the selection
    NSArray *countries = [DataManager sharedDataManager].orderedCountryData;
    NSUInteger index = NSNotFound;
    for (NSInteger i = 0; i < countries.count; ++i) {
        NSDictionary *info = countries[i];
        if ([info[@"code"] isEqualToString:countryCode]) {
            index = i;
            break;
        }
    }
    assert(index != NSNotFound);
    
    // Remove all subviews
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    
    /*
     * Note that the way we implemented borders really sucks. The reason we're doing
     * this is that CALayer borders overlap the content. I couldn't get alternatives
     * like drawing a new image with the borders to work as they all got ridiculously
     * blurry. This should be possible, though, so if you can figure out, please
     * replace this crap with something that doesn't suck as much.
     */
    
    // Change the portrait flags
    NSInteger indices[3] = { index == 0 ? countries.count - 1 : index - 1, index, (index + 1) % countries.count };
    for (int i = 0; i < 3; ++i) {
        // Get the country info and country code
        NSDictionary *info = countries[indices[i]];
        NSString *countryCode = info[@"code"];
        
        // Get the flag into an image view and apply a border and shadow
        // unless we're showing the globe
        UIView *flag;
        if ([countryCode isEqualToString:@"world"]) {
            flag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"globeVertical"]];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                BOOL iphone5 = [UIScreen mainScreen].bounds.size.height == 568;
                CGFloat maxHeight = iphone5 ? 104 : 80;
                CGFloat scale = maxHeight / ((UIImageView *)flag).image.size.height;
                flag.transform = CGAffineTransformMakeScale(scale, scale);
            }
        } else {
            // Get the right flag
            NSString *flagName = [NSString stringWithFormat:@"country_flag_%@", countryCode];
            UIImage *image = [UIImage imageNamed:flagName];
            
            // Calculate its new size, including borders
            CGFloat maxHeight;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                maxHeight = 126;
            } else if ([UIScreen mainScreen].bounds.size.height == 568) {
                maxHeight = 72;
            } else {
                maxHeight = 64;
            }
            CGFloat scale = maxHeight / image.size.height;
            CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));
            
            // Calculate the size of the image centered in the
            // image view by insetting the border width
            CGSize innerSize = newSize;
            innerSize.width -= 8;
            innerSize.height -= 8;

            // Create the background view
            flag = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
            flag.backgroundColor = [UIColor whiteColor];

            // Create the flag image
            UIImageView *flagImage = [[UIImageView alloc] initWithImage:image];
            flagImage.frame = CGRectMake(4, 4, innerSize.width, innerSize.height);
            [flag addSubview:flagImage];

            // Add the shadow effect
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                flag.layer.shadowOffset = CGSizeMake(2, 2);
                flag.layer.shadowColor = [UIColor blackColor].CGColor;
                flag.layer.shadowOpacity = 0.6;
                flag.layer.shouldRasterize = YES;
                flag.layer.rasterizationScale = [UIScreen mainScreen].scale;
            }
        }
        
        // Save the flag and country code
        _flags[i] = flag;
        _countryCodes[i] = countryCode;
        
        // Add the flag
        [self addSubview:flag];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // Give precedence to the arrows if we're not animating
    // and the middle flag is the one that is currently shown
    // (in case we haven't swapped the flags yet)
    if (!self.layer.animationKeys.count && self.contentOffset.x == self.frame.size.width) {
        UIView *hit = [self.leftArrow hitTest:[self.leftArrow convertPoint:point fromView:self] withEvent:event];
        if (hit) {
            return hit;
        }
        hit = [self.rightArrow hitTest:[self.rightArrow convertPoint:point fromView:self] withEvent:event];
        if (hit) {
            return hit;
        }
    }
    
    // Operate as normal
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    // Set the content size
    self.contentSize = CGSizeMake(self.bounds.size.width * 3, self.frame.size.height);
    
    // Make sure the middle flag is centered even
    // if our dimensions change
    if (_layoutWidth != self.bounds.size.width) {
        _layoutWidth = self.bounds.size.width;
        self.contentOffset = CGPointMake(self.bounds.size.width, 0);
    }
    
    // Position the flags
    for (int i = 0; i < 3; ++i) {
        UIView *flag = _flags[i];
        flag.center = CGPointMake(self.bounds.size.width * (i + 0.5), self.frame.size.height / 2);
    }
}

- (IBAction)leftArrowTouched:(id)sender
{
    [self setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)rightArrowTouched:(id)sender
{
    [self setContentOffset:CGPointMake(self.frame.size.width * 2, 0) animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // This is called after the animation triggered
    // by setting the content offset programatically
    [self checkSelectedCountry];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // This is called after the decelerating animation
    // when the user releases the dragged scrollview
    [self checkSelectedCountry];
}

- (void)checkSelectedCountry
{
    // Find the selected page
    int page = self.contentOffset.x / self.frame.size.width;
    assert(page == 0 || page == 1 || page == 2);
    
    // If it's the middle page, the selection hasn't changed
    if (page == 1) {
        return;
    }
    
    // Reload the flags
    NSString *selection = _countryCodes[page];
    [self reloadWithCountry:selection];
    
    // Point to the flag in the middle
    self.contentOffset = CGPointMake(self.bounds.size.width, 0);
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification
                                                        object:self
                                                      userInfo:@{SelectedCountryKey : selection}];
}

@end
