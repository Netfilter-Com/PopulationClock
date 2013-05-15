//
//  MapViewFlagViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 13/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "DataManager.h"
#import "MapViewFlagViewController_iPhone.h"

@interface MapViewFlagViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIView *flag;

@end

@implementation MapViewFlagViewController_iPhone

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    
    if ([selection isEqualToString:@"world"]) {
        // Load the image
        UIImage *image = [UIImage imageNamed:@"globeHoriz"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

        // Replace the current flag
        [self.flag.superview insertSubview:imageView aboveSubview:self.flag];
        [self.flag removeFromSuperview];
        self.flag = imageView;
        
        // Calculate its new size
        CGFloat scale = 30 / image.size.height;
        CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));
        
        // Set the frame
        self.flag.frame = CGRectMake(0, 0, newSize.width, newSize.height);
        self.flag.backgroundColor = [UIColor clearColor];
    }
    else {
        // Load the image
        NSString *flagName = [NSString stringWithFormat:@"country_flag_%@", selection];
        UIImage *image = [UIImage imageNamed:flagName];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        // Calculate its new size, including borders
        CGFloat scale = 30 / image.size.height;
        CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));

        // Create the background view
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        backgroundView.backgroundColor = [UIColor whiteColor];

        // Replace the current flag
        [self.flag.superview insertSubview:backgroundView aboveSubview:self.flag];
        [self.flag removeFromSuperview];
        self.flag = backgroundView;

        // Calculate the size of the image centered in the background view
        CGSize innerSize = newSize;
        innerSize.width -= 4;
        innerSize.height -= 4;

        // Add the image to the background view
        imageView.frame = CGRectMake(2, 2, innerSize.width, innerSize.height);
        [backgroundView addSubview:imageView];
    }
    
    // Update the label
    self.label.text = info[@"name"];
    [self.label sizeToFit];
    
    // We'll need to layout the view
    [self.view setNeedsLayout];
}

- (void)viewWillLayoutSubviews
{
    // Right-align the flag
    CGRect frame = self.flag.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    frame.origin.y = (self.view.frame.size.height - frame.size.height) / 2;
    self.flag.frame = frame;
    
    // Align the label to its right
    frame = self.label.frame;
    frame.origin.x = self.flag.frame.origin.x - frame.size.width - 8;
    frame.origin.y = (self.view.frame.size.height - frame.size.height) / 2;
    self.label.frame = frame;
}

@end
