//
//  StatsBuilder.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "DataManager.h"
#import "StatsBuilder.h"

static NSString * const StatFormat = @"<div class=\"metric\"><span class=\"key\">%@</span><span class=\"value\">%@</span></div>";

@implementation StatsBuilder

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

- (NSString *)statsStringForCountryCode:(NSString *)countryCode
{
    NSDictionary *info = [DataManager sharedDataManager].countryData[countryCode];
    NSMutableString *stats = [NSMutableString string];
#define ADD_STAT(stkey, stname, fmtfunc) \
    do { \
        NSNumber *number = info[stkey]; \
        if (number) { \
            [stats appendFormat:StatFormat, stname, [self fmtfunc:number]]; \
        } \
    } while (0)
    ADD_STAT(@"gdp", NSLocalizedString(@"GDP", @""), formatBigMoney);
    ADD_STAT(@"gdpPerCapita", NSLocalizedString(@"GDP per capita", @""), formatSmallMoney);
    ADD_STAT(@"gdpGrowth", NSLocalizedString(@"GDP growth", @""), formatPercentage);
    ADD_STAT(@"lifeExpectancy", NSLocalizedString(@"Life expectancy", @""), formatYears);
    ADD_STAT(@"birthsPerWoman", NSLocalizedString(@"Births per woman", @""), formatSmallNumber);
    ADD_STAT(@"birthRate", NSLocalizedString(@"Crude birth rate (per 1,000 people)", @""), formatSmallNumber);
    ADD_STAT(@"deathRate", NSLocalizedString(@"Crude death rate (per 1,000 people)", @""), formatSmallNumber);
    ADD_STAT(@"growthRate", NSLocalizedString(@"Annual population growth", @""), formatPercentage);
    ADD_STAT(@"healthExpensePercentGDP", NSLocalizedString(@"Health expenditure (% GDP)", @""), formatPercentage);
    ADD_STAT(@"literacyRate", NSLocalizedString(@"Literacy rate", @""), formatPercentage);
    ADD_STAT(@"govtEducationExpensePercentGDP", NSLocalizedString(@"Govt. education expenditure (% GDP)", @""), formatPercentage);
    ADD_STAT(@"unemploymentRate", NSLocalizedString(@"Unenmployment rate", @""), formatPercentage);
    ADD_STAT(@"electricityAccess", NSLocalizedString(@"Access to electricity", @""), formatPercentage);
    ADD_STAT(@"co2Emissions", NSLocalizedString(@"CO<sub>2</sub> emissions (kg/yr)", @""), formatCO2Emissions);
    ADD_STAT(@"forestArea", NSLocalizedString(@"Forest area (% of land area)", @""), formatPercentage);
    ADD_STAT(@"energyProduction", NSLocalizedString(@"Energy prod. (kg of oil equiv.)", @""), formatEnergyProduction);
    ADD_STAT(@"internetUsers", NSLocalizedString(@"Internet users", @""), formatPercentage);
    ADD_STAT(@"mobileUsersPer100", NSLocalizedString(@"Mobile phones (per 100 people)", @""), formatSmallNumber);
    ADD_STAT(@"passengerCarPer1000", NSLocalizedString(@"Passenger cars (per 1,000 people)", @""), formatSmallNumber);
    ADD_STAT(@"roadsPaved", NSLocalizedString(@"Roads paved", @""), formatPercentage);
#undef ADD_STAT
    
    return stats;
}

@end
