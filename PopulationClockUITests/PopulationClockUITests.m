//
//  PopulationClockUITests.m
//  PopulationClockUITests
//
//  Walks through the main screens with different text sizes and languages and
//  saves a screenshot of each one. Set TEST_RUNNER_SCREENSHOT_DIR to also
//  write the PNGs to a folder; they are always attached to the test result.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>

@interface PopulationClockUITests : XCTestCase
@end

@implementation PopulationClockUITests

- (void)setUp {
    self.continueAfterFailure = YES;
}

#pragma mark - Helpers

- (XCUIApplication *)launchWithLanguage:(NSString *)language contentSize:(NSString *)contentSize {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    if ([language isEqualToString:@"pt-BR"]) {
        [args addObjectsFromArray:@[ @"-AppleLanguages", @"(pt-BR)", @"-AppleLocale", @"pt_BR" ]];
    } else {
        [args addObjectsFromArray:@[ @"-AppleLanguages", @"(en)", @"-AppleLocale", @"en_US" ]];
    }
    if (contentSize) {
        [args addObjectsFromArray:@[ @"-UIPreferredContentSizeCategoryName", contentSize ]];
    }
    app.launchArguments = args;
    [app launch];
    return app;
}

- (void)capture:(NSString *)name tag:(NSString *)tag {
    XCUIScreenshot *shot = [[XCUIScreen mainScreen] screenshot];
    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:shot];
    attachment.name = [NSString stringWithFormat:@"%@_%@", tag, name];
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];

    NSString *dir = [[NSProcessInfo processInfo] environment][@"SCREENSHOT_DIR"];
    if (dir.length) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL];
        NSString *path = [dir stringByAppendingPathComponent:[attachment.name stringByAppendingString:@".png"]];
        [shot.PNGRepresentation writeToFile:path atomically:YES];
    }
}

// Taps the first button whose label contains one of the given texts
- (BOOL)tapButtonIn:(XCUIApplication *)app containing:(NSArray<NSString *> *)texts {
    for (NSString *text in texts) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label CONTAINS[c] %@", text];
        XCUIElement *button = [app.buttons matchingPredicate:predicate].firstMatch;
        if (button.exists && button.isHittable) {
            [button tap];
            [NSThread sleepForTimeInterval:1.0];
            return YES;
        }
    }
    XCTFail(@"No button containing any of %@", texts);
    return NO;
}

// The About dialog is dismissed with its Done button, whose title is not localized
- (void)dismissAboutIn:(XCUIApplication *)app {
    for (NSString *title in @[ @"Done", @"OK", @"Concluído", @"Fechar", @"Close" ]) {
        XCUIElement *button = app.buttons[title];
        if (button.exists && button.isHittable) {
            [button tap];
            [NSThread sleepForTimeInterval:1.0];
            return;
        }
    }
    // Fall back to the first button of the dialog's navigation bar
    XCUIElement *bar = app.navigationBars.firstMatch;
    if (bar.exists && bar.buttons.count > 0) {
        [bar.buttons.firstMatch tap];
        [NSThread sleepForTimeInterval:1.0];
    }
}

- (void)tapSegment:(XCUIApplication *)app titles:(NSArray<NSString *> *)titles {
    for (NSString *title in titles) {
        XCUIElement *segment = app.segmentedControls.buttons[title];
        if (segment.exists) {
            [segment tap];
            [NSThread sleepForTimeInterval:1.0];
            return;
        }
    }
    XCTFail(@"No segment with any of the titles %@", titles);
}

#pragma mark - VoiceOver

// Finds an element by its accessibility label, whatever its type
- (XCUIElement *)elementLabeled:(NSString *)label in:(XCUIApplication *)app {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"label == %@", label];
    return [[app descendantsMatchingType:XCUIElementTypeAny] matchingPredicate:predicate].firstMatch;
}

- (void)testVoiceOverLabels {
    XCUIApplication *app = [self launchWithLanguage:@"en" contentSize:nil];
    [NSThread sleepForTimeInterval:3.0];
    BOOL isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;

    // The map is not a silent picture
    XCTAssertTrue([self elementLabeled:@"World map" in:app].exists, @"map has no accessibility label");

    if (!isPad) {
        // Go to the Info pane, where the clock and the flag live
        [self tapButtonIn:app containing:@[ @"Info" ]];
    }

    // The clock is one element, with the population as its value
    NSPredicate *clockPredicate = [NSPredicate predicateWithFormat:@"label BEGINSWITH %@", @"Population of "];
    XCUIElement *clock = [[app descendantsMatchingType:XCUIElementTypeAny] matchingPredicate:clockPredicate].firstMatch;
    XCTAssertTrue(clock.exists, @"clock has no accessibility label");
    NSString *value = [clock.value description];
    // A number, grouped by the locale (the country may be a small one)
    NSPredicate *number = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9][0-9,. ]*"];
    XCTAssertTrue([number evaluateWithObject:value], @"clock value is '%@'", value);

    // The arrows have names
    XCTAssertTrue([self elementLabeled:@"Next country" in:app].exists, @"right arrow has no label");
    XCTAssertTrue([self elementLabeled:@"Previous country" in:app].exists, @"left arrow has no label");

    // The carousel toolbar buttons are not read with their padding spaces
    if (!isPad) {
        XCTAssertTrue(app.buttons[@"Map"].exists, @"carousel button label includes padding");
    }
}

#pragma mark - iPad landscape

- (void)testIPadLandscape {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        return;
    }
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    XCUIApplication *app = [self launchWithLanguage:@"en" contentSize:nil];
    [NSThread sleepForTimeInterval:3.0];
    [self capture:@"01_main" tag:@"ipad_landscape"];

    [self tapSegment:app titles:@[ @"Country", @"País" ]];
    XCUIElement *cell = app.tables.cells.allElementsBoundByIndex[6];
    if (cell.exists) {
        [cell tap];
        [NSThread sleepForTimeInterval:1.5];
    }
    [self capture:@"02_country" tag:@"ipad_landscape"];

    if ([self tapButtonIn:app containing:@[ @"About", @"Sobre" ]]) {
        [self capture:@"03_about" tag:@"ipad_landscape"];
    }
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
}

#pragma mark - Walkthrough

- (void)walkthroughWithLanguage:(NSString *)language contentSize:(NSString *)contentSize tag:(NSString *)tag {
    XCUIApplication *app = [self launchWithLanguage:language contentSize:contentSize];
    [NSThread sleepForTimeInterval:3.0];

    BOOL isPad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    NSArray *worldTitles = @[ @"World", @"Mundo" ];
    NSArray *countryTitles = @[ @"Country", @"País" ];

    [self capture:@"01_main" tag:tag];

    if (isPad) {
        [self tapSegment:app titles:worldTitles];
        [self capture:@"02_world" tag:tag];
        [self tapSegment:app titles:countryTitles];
        [self capture:@"03_country" tag:tag];

        if ([self tapButtonIn:app containing:@[ @"About", @"Sobre" ]]) {
            [self capture:@"04_about" tag:tag];
            [self dismissAboutIn:app];
        }
        XCUIElement *cell = app.tables.cells.allElementsBoundByIndex[6];
        if (cell.exists) {
            [cell tap];
            [NSThread sleepForTimeInterval:1.5];
            [self capture:@"05_list_selection" tag:tag];
        }
        return;
    }

    // iPhone: the carousel is Info <- Map -> List
    if ([self tapButtonIn:app containing:@[ @"Info" ]]) {
        [self capture:@"02_info_world" tag:tag];
        [self tapSegment:app titles:countryTitles];
        [self capture:@"03_info_country" tag:tag];
    }
    if ([self tapButtonIn:app containing:@[ @"Map", @"Mapa" ]]) {
        [self capture:@"04_map_again" tag:tag];
    }
    if ([self tapButtonIn:app containing:@[ @"List", @"Lista" ]]) {
        [self capture:@"05_list" tag:tag];
        if ([self tapButtonIn:app containing:@[ @"About", @"Sobre" ]]) {
            [self capture:@"06_about" tag:tag];
            [self dismissAboutIn:app];
        }
        XCUIElement *cell = app.tables.cells.allElementsBoundByIndex[6];
        if (cell.exists) {
            [cell tap];
            [NSThread sleepForTimeInterval:1.5];
            [self capture:@"07_list_selection" tag:tag];
        }
    }
}

- (void)testEnglishDefaultSize {
    [self walkthroughWithLanguage:@"en" contentSize:nil tag:@"en_default"];
}

- (void)testEnglishLargestAccessibilitySize {
    [self walkthroughWithLanguage:@"en" contentSize:@"UICTContentSizeCategoryAccessibilityXXXL" tag:@"en_axxxl"];
}

- (void)testPortugueseDefaultSize {
    [self walkthroughWithLanguage:@"pt-BR" contentSize:nil tag:@"pt_default"];
}

- (void)testPortugueseLargestAccessibilitySize {
    [self walkthroughWithLanguage:@"pt-BR" contentSize:@"UICTContentSizeCategoryAccessibilityXXXL" tag:@"pt_axxxl"];
}

@end
