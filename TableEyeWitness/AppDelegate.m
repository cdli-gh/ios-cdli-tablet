//
//  EWAppDelegate.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"

@interface AppDelegate () <FetchedEntries>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.refreshResponder = nil;
    self.noThumbnails = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    NSLog(@"Rereshing data (became active)");
    
    NSString *feedURL;
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"IsInternalBuild"] boolValue])
        feedURL = [NSString stringWithFormat:@"http://www.cdli.ucla.edu/cdlitablet/json?all=true"];
    else
        feedURL = [NSString stringWithFormat:@"http://www.cdli.ucla.edu/cdlitablet/json"];
    
    [Utils refreshDataAtURL:feedURL withHandler:self];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - FetchedEntries delegate
- (void) fetchedEntries:(NSArray *)tabletItems
{
    self.tabletItems = tabletItems;
    self.pageShowingMore = [[NSMutableDictionary alloc] initWithCapacity:[tabletItems count]];
    for(int i = 0; i < [self.tabletItems count]; i++)
        self.pageShowingMore[@(i)] = @(false);
    
    if(self.refreshResponder != nil)
        [self.refreshResponder fetchedEntries:self.tabletItems];
}

//TODO: implement the method to deal with fetch errors
@end
