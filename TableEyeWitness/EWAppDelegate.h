//
//  EWAppDelegate.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *tabletItems;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSMutableDictionary *pageShowingMore;

@end
