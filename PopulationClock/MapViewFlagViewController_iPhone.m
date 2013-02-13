//
//  MapViewFlagViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 13/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "DataManager.h"
#import "MapViewFlagViewController_iPhone.h"
#import "UIImage+NFResizable.h"

@interface MapViewFlagViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIImageView *flag;

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
        self.flag.image = image;
        
        // Calculate its new size
        CGFloat scale = 30 / image.size.height;
        CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));
        
        // Set the frame and content mode
        self.flag.frame = CGRectMake(0, 0, newSize.width, newSize.height);
        self.flag.contentMode = UIViewContentModeScaleToFill;
        self.flag.backgroundColor = [UIColor clearColor];
    }
    else {
        NSString *flagName = [NSString stringWithFormat:@"country_flag_%@", selection];
        UIImage *image = [UIImage imageNamed:flagName];
        
        // Calculate its new size, including borders
        CGFloat scale = 30 / image.size.height;
        CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));
        
        // Calculate the size of the image centered in the
        // image view by insetting the border width
        CGSize innerSize = newSize;
        innerSize.width -= 4;
        innerSize.height -= 4;
        
        // Assign the image to the image view and configure it
        self.flag.image = [image nf_resizedImageWithSize:innerSize];
        self.flag.frame = CGRectMake(0, 0, newSize.width, newSize.height);
        self.flag.contentMode = UIViewContentModeCenter;
        self.flag.backgroundColor = [UIColor whiteColor];
    }
    
    // Update the label
    // TODO: Use shortName instead
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
