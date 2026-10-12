//
//  UIView+NFLocalization.h
//  PopulationClock
//

#import <UIKit/UIKit.h>

@interface UIView (NFLocalization)

// Looks up the English texts of the labels, buttons, segmented controls, text
// field placeholders and toolbar items under this view in Localizable.strings.
// Texts that have no translation are left alone. Used because the iPad
// storyboard strings are not applied at build time.
- (void)nf_localizeTexts;

@end
