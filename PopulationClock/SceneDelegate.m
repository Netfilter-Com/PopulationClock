//
//  SceneDelegate.m
//  PopulationClock
//
//  Copyright (c) 2026 NetFilter. All rights reserved.
//

#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "NFCarouselViewController.h"
#import "SimulationEngine.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }

    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // On the iPhone, we need to manually assemble the carousel from the storyboard
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        self.window.rootViewController = [[NFCarouselViewController alloc] initWithViewControllers:@[
            [storyboard instantiateViewControllerWithIdentifier:@"countryInfoViewController"],
            [storyboard instantiateInitialViewController],
            [storyboard instantiateViewControllerWithIdentifier:@"countryListViewController"]
        ]];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self.window.rootViewController = [storyboard instantiateInitialViewController];
    }

    [self.window makeKeyAndVisible];
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate requestReviewIfAppropriateInScene:(UIWindowScene *)scene];
    }
}

@end
