//
//  EWModelController.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (PageViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(PageViewController *)viewController;

@end
