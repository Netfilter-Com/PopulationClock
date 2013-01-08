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

- (void)adjustBigNumber:(NSNumber **)number suffix:(NSString **)suffix {
    // We want to divide into millions, billions and trillions
    float val = (*number).floatValue;
    if (val >= 1e12) {
        val /= 1e12;
        *suffix = NSLocalizedString(@" trillion", @"");
    }
    else if (val >= 1e9) {
        val /= 1e9;
        *suffix = NSLocalizedString(@" billion", @"");
    }
    else if (val >= 1e6) {
        val /= 1e6;
        *suffix = NSLocalizedString(@" million", @"");
    }
    else {
        *suffix = @"";
    }
    *number = @(val);
}

- (NSString *)formatBigMoney:(NSNumber *)number {
    // Adjust the big number and get a suffix
    NSString *suffix;
    [self adjustBigNumber:&number suffix:&suffix];
    
    // Apply the number formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = number.floatValue > 10 ? 1 : 2;
    formatter.currencyCode = @"USD";
    NSString *formatted = [formatter stringFromNumber:number];
    
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

- (NSString *)formatBigNumber:(NSNumber *)number {
    // Adjust the big number and get a suffix
    NSString *suffix;
    [self adjustBigNumber:&number suffix:&suffix];
    
    // Apply the number formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumFractionDigits = 0;
    formatter.maximumFractionDigits = 1;
    NSString *formatted = [formatter stringFromNumber:number];
    
    // Append the suffix and return
    return [formatted stringByAppendingString:suffix];
}

- (NSString *)formatSmallNumber:(NSNumber *)number {
    // Use a simple formatter
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = number.floatValue > 10 ? 1 : 2;
    return [formatter stringFromNumber:number];
}

- (NSString *)formatCO2Emissions:(NSNumber *)number {
    return [self formatBigNumber:@(number.floatValue * 1e3)];
}

- (NSString *)formatEnergyProduction:(NSNumber *)number {
    return [self formatBigNumber:@(number.floatValue * 1e3)];
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
    NSString *description = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla nunc nulla, facilisis id adipiscing id, egestas quis arcu. Fusce ut justo at lorem dapibus vulputate. Maecenas in est non erat molestie lacinia ac vitae sem. Nulla lobortis imperdiet nibh id dictum. Maecenas sit amet orci ipsum, vitae vestibulum lectus. Suspendisse tellus ligula, ultricies ut vulputate vel, fermentum eget enim. Suspendisse a neque lectus.\n    Nunc mollis condimentum mattis. Nam eros quam, tristique in semper non, ultricies tincidunt dui. Quisque risus felis, dictum id pulvinar blandit, consequat eu lorem. Pellentesque ullamcorper, mi eu tincidunt placerat, orci justo vulputate est, sodales tristique velit nibh eget tellus. Donec at elementum arcu. Etiam vel lectus ac libero mattis ullamcorper. Morbi feugiat dolor a eros varius id scelerisque augue feugiat. Duis sit amet metus id tellus facilisis aliquet vitae in justo.";
    
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
        ADD_STAT(@"birthRate", NSLocalizedString(@"Crude birth rate per 1,000 people", @""), formatSmallNumber);
        ADD_STAT(@"deathRate", NSLocalizedString(@"Crude death rate per 1,000 people", @""), formatSmallNumber);
        ADD_STAT(@"healthExpensePercentGDP", NSLocalizedString(@"Health expenditure % GDP", @""), formatPercentage);
        ADD_STAT(@"literacyRate", NSLocalizedString(@"Literacy rate", @""), formatPercentage);
        ADD_STAT(@"govtEducationExpensePercentGDP", NSLocalizedString(@"Govt. education expenditure % GDP", @""), formatPercentage);
        ADD_STAT(@"unemploymentRate", NSLocalizedString(@"Unenmployment rate", @""), formatPercentage);
        ADD_STAT(@"electricityAccess", NSLocalizedString(@"Access to electricity", @""), formatPercentage);
        ADD_STAT(@"co2Emissions", NSLocalizedString(@"CO2 emissions (kg/yr)", @""), formatCO2Emissions);
        ADD_STAT(@"forestArea", NSLocalizedString(@"Forest area", @""), formatPercentage);
        ADD_STAT(@"energyProduction", NSLocalizedString(@"Energy production (kg of oil equiv.)", @""), formatEnergyProduction);
        ADD_STAT(@"internetUsers", NSLocalizedString(@"Internet users", @""), formatPercentage);
        ADD_STAT(@"mobileUsersPer100", NSLocalizedString(@"Mobile phones per 100 people", @""), formatSmallNumber);
        ADD_STAT(@"passengerCarPer1000", NSLocalizedString(@"Passenger cars per 1,000 people", @""), formatSmallNumber);
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
