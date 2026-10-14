//
//  MapViewFlagViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 13/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "DataManager.h"
#import "MapViewFlagViewController_iPhone.h"

static const CGFloat kFlagHeight = 30;
static const CGFloat kMaxWidth = 300;

@interface MapViewFlagViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIView *flag;

@end

@implementation MapViewFlagViewController_iPhone {
    // The country name and the flag in a horizontal stack. The bar sizes this
    // view by Auto Layout, so it must size itself from its content: a fixed
    // frame with the flag right-aligned ended up past the screen edge on iOS 27
    UIView *_flagHolder;
    NSLayoutConstraint *_flagWidth;
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    // Take the label out of the storyboard's frame layout and into a stack
    UILabel *label = self.label;
    [self.flag removeFromSuperview];
    [label removeFromSuperview];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    // High compression resistance: the bar asks for the compressed size, and a
    // low priority collapsed the name to nothing. The width limit below is what
    // truncates a long name
    [label setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    _flagHolder = [[UIView alloc] init];
    _flagHolder.translatesAutoresizingMaskIntoConstraints = NO;
    _flagWidth = [_flagHolder.widthAnchor constraintEqualToConstant:0];
    _flagWidth.active = YES;
    [_flagHolder.heightAnchor constraintEqualToConstant:kFlagHeight].active = YES;
    [_flagHolder setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[ label, _flagHolder ]];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 8;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.view.widthAnchor constraintLessThanOrEqualToConstant:kMaxWidth],
        [self.view.heightAnchor constraintGreaterThanOrEqualToConstant:44]
    ]];

    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];

    UIImage *image;
    BOOL isWorld = [selection isEqualToString:@"world"];
    if (isWorld)
        image = [UIImage imageNamed:@"globeHoriz"];
    else
        image = [UIImage imageNamed:[NSString stringWithFormat:@"country_flag_%@", selection]];
    if (!image)
        return;

    // Calculate its new size, including borders
    CGFloat scale = kFlagHeight / image.size.height;
    CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));

    for (UIView *old in [_flagHolder.subviews copy])
        [old removeFromSuperview];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (isWorld) {
        imageView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
    }
    else {
        // The flag is centered in a white background, which makes the border
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        imageView.frame = CGRectMake(2, 2, newSize.width - 4, newSize.height - 4);
        [backgroundView addSubview:imageView];
        imageView = (UIImageView *)backgroundView;
    }
    [_flagHolder addSubview:imageView];
    _flagWidth.constant = newSize.width;

    // Update the label
    self.label.text = info[@"name"];

    [self.view setNeedsLayout];
}

@end
