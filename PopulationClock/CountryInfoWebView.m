//
//  CountryInfoWebView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 20/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryInfoWebView.h"
#import "DataManager.h"

static NSString * const StatFormat = @"<div class=\"metric\"><span class=\"key\">%@</span><span class=\"value\">%@</span></div>";

@implementation CountryInfoWebView {
    BOOL _didLayout;
    UIInterfaceOrientation _interfaceOrientationForLayout;
    NSDictionary *_selectedInfo;
}

- (void)awakeFromNib {
    // Disable bouncing
    self.scrollView.bounces = NO;
    
    // Remove some random shadows (where does this come from?)
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
    }
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Save the information for this selection
    _selectedInfo = [DataManager sharedDataManager].countryData[selection];
    assert(_selectedInfo);
    
    // Force a layout
    _didLayout = NO;
    [self setNeedsLayout];
}

- (NSString *)formatBigMoney:(NSNumber *)number {
    // We want to divide into millions, billions and trillions
    float money = number.floatValue;
    NSString *suffix;
    if (money >= 10e12) {
        money /= 10e12;
        suffix = NSLocalizedString(@" trillion", @"");
    }
    if (money >= 10e9) {
        money /= 10e9;
        suffix = NSLocalizedString(@" billion", @"");
    }
    else if (money >= 10e6) {
        money /= 10e6;
        suffix = NSLocalizedString(@" million", @"");
    }
    else {
        suffix = @"";
    }
    
    // Apply the number formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 3;
    formatter.currencyCode = @"USD";
    NSString *formatted = [formatter stringFromNumber:@(money)];
    
    // Append the suffix and return
    return [formatted stringByAppendingString:suffix];
}

- (NSString *)formatSmallMoney:(NSNumber *)number {
    // Use a simple formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    return [formatter stringFromNumber:number];
}

- (NSString *)formatPercentage:(NSNumber *)number {
    // Use a simple formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.maximumFractionDigits = 2;
    return [formatter stringFromNumber:@(number.floatValue / 100)];
}

- (NSString *)formatYears:(NSNumber *)number {
    // Use a simple formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 1;
    return [[formatter stringFromNumber:number] stringByAppendingString:NSLocalizedString(@" years", @"")];
}

- (NSString *)formatSmallNumber:(NSNumber *)number {
    // Use a simple formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 2;
    return [formatter stringFromNumber:number];
}

- (void)layoutSubviews {
    // Nothing to do until we have a selection
    if (!_selectedInfo)
        return;
    
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // Nothing to do if the interface orientation didn't change
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    if (_didLayout && isPortrait == UIInterfaceOrientationIsPortrait(_interfaceOrientationForLayout))
        return;
    
    // Load the right template depending on the orientation
    NSString *templateName = isPortrait ? @"info_template_portrait" : @"info_template_landscape";
    NSString *path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    // Get the short paragraph about the country
    // TODO: This is currently hardcoded
    NSString *description = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi in felis id tortor lobortis lacinia vel sed ipsum. Aliquam viverra lacus lectus, vitae tristique felis. Ut rhoncus.";
    
    // Create the substitution dictionary
    NSDictionary *substitutions;
    if (isPortrait) {
        // Build a list of stats
        NSMutableString *stats = [NSMutableString string];
#define ADD_STAT(stkey, stname, fmtfunc) \
    do { \
        NSNumber *number = _selectedInfo[stkey]; \
        if (number) \
            [stats appendFormat:StatFormat, stname, [self fmtfunc:number]]; \
    } while (NO)
        ADD_STAT(@"gdp", NSLocalizedString(@"GDP", @""), formatBigMoney);
        ADD_STAT(@"gdpPerCapita", NSLocalizedString(@"GDP per capita", @""), formatSmallMoney);
        ADD_STAT(@"gdpGrowth", NSLocalizedString(@"GDP growth", @""), formatPercentage);
        ADD_STAT(@"lifeExpectancy", NSLocalizedString(@"Life expectancy", @""), formatYears);
        ADD_STAT(@"birthsPerWoman", NSLocalizedString(@"Births per woman", @""), formatSmallNumber);
        ADD_STAT(@"healthExpensePercentGDP", NSLocalizedString(@"Health expenditure % GDP", @""), formatPercentage);
        ADD_STAT(@"literacyRate", NSLocalizedString(@"Literacy rate", @""), formatPercentage);
        ADD_STAT(@"govtEducationExpensePercentGDP", NSLocalizedString(@"Govt. education expenditure % GDP", @""), formatPercentage);
        ADD_STAT(@"unemploymentRate", NSLocalizedString(@"Unenmployment rate", @""), formatPercentage);
        ADD_STAT(@"electricityAccess", NSLocalizedString(@"Access to electricity", @""), formatPercentage);
        // TODO: ADD_STAT(@"CO2 emission", NSLocalizedString(@"Access to electricity", @""), formatPercentage);
        ADD_STAT(@"forestArea", NSLocalizedString(@"Forest area", @""), formatPercentage);
        // TODO: ADD_STAT(@"energyProduction", NSLocalizedString(@"Access to electricity", @""), formatPercentage);
        ADD_STAT(@"internetUsers", NSLocalizedString(@"Internet users", @""), formatPercentage);
        ADD_STAT(@"mobileUsersPer100", NSLocalizedString(@"Mobile phones per each 1000 inhabitants", @""), formatSmallNumber);
        ADD_STAT(@"passengerCarPer1000", NSLocalizedString(@"Passenger cars per each 1000 inhabitants", @""), formatSmallNumber);
        ADD_STAT(@"roadsPaved", NSLocalizedString(@"Roads paved", @""), formatPercentage);
#undef ADD_STAT
        
        // Create a more complete dictionary of substitutions
        substitutions = @{
            @"%%NAME%%" : _selectedInfo[@"name"],
            @"%%DESCRIPTION%%" : description,
            @"%%STATS%%" : stats
        };
    }
    else {
        substitutions = @{ @"%%DESCRIPTION%%" : description };
    }
    
    // Perform the template substitutions
    for (NSString *key in substitutions.allKeys)
        template = [template stringByReplacingOccurrencesOfString:key withString:substitutions[key]];
    
    // Load the HTML
    NSURL *baseURL = [NSURL fileURLWithPath:[path stringByDeletingLastPathComponent] isDirectory:YES];
    [self loadHTMLString:template baseURL:baseURL];
    
    // Save the new orientation
    _interfaceOrientationForLayout = orientation;
    _didLayout = YES;
}

@end
