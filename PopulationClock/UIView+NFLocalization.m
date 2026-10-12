//
//  UIView+NFLocalization.m
//  PopulationClock
//

#import "UIView+NFLocalization.h"

static NSString *NFLocalized(NSString *text) {
    if (text.length == 0) {
        return text;
    }
    return [[NSBundle mainBundle] localizedStringForKey:text value:text table:nil];
}

@implementation UIView (NFLocalization)

- (void)nf_localizeTexts {
    if ([self isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self;
        label.text = NFLocalized(label.text);
    }
    else if ([self isKindOfClass:[UITextField class]]) {
        UITextField *field = (UITextField *)self;
        field.placeholder = NFLocalized(field.placeholder);
    }
    else if ([self isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *control = (UISegmentedControl *)self;
        for (NSUInteger i = 0; i < control.numberOfSegments; i++) {
            [control setTitle:NFLocalized([control titleForSegmentAtIndex:i]) forSegmentAtIndex:i];
        }
    }
    else if ([self isKindOfClass:[UIToolbar class]]) {
        for (UIBarButtonItem *item in ((UIToolbar *)self).items) {
            item.title = NFLocalized(item.title);
        }
    }
    else if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self;
        [button setTitle:NFLocalized([button titleForState:UIControlStateNormal]) forState:UIControlStateNormal];
    }
    
    for (UIView *subview in self.subviews) {
        [subview nf_localizeTexts];
    }
}

@end
