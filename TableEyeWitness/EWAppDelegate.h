//
//  EWAppDelegate.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@interface EWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//tablet items are sent in the background from utils
@property (strong, atomic) NSArray *tabletItems;
//@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSMutableDictionary *pageShowingMore;
@property (strong, nonatomic) id<FetchedEntries> refreshResponder;

@end
