//
//  EWModelController.h
//  TableEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EWDataViewController;

@interface EWModelController : NSObject <UIPageViewControllerDataSource>

- (EWDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(EWDataViewController *)viewController;

@end
