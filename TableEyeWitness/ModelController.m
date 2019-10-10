//
//  EWModelController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "AppDelegate.h"
#import "ModelController.h"
#import "PageViewController.h"
#import "Utils.h"

#define CACHE_LIMIT 2

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface ModelController()
@property (strong, nonatomic) NSArray *pageData;
@end

@implementation ModelController

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.pageData = appDelegate.tabletItems;
    }
    return self;
}


- (PageViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"EWDataViewController"];
    dataViewController.dataObject = self.pageData[index];
    dataViewController.dataIndex = index;
    
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(PageViewController *)viewController
{   
     // Return the index of the given data view controller.
     // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}

#pragma mark - Page View Controller Data Source

//Also caches images for the next 'CACHE_LIMIT' viewcontrollers in the 'left' direction
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PageViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    for(NSUInteger i = index; i > 0 && i > index - CACHE_LIMIT; i--)
        [Utils downloadImageAtURL:self.pageData[i][@"url"]];

    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

//Also caches images for the next 'CACHE_LIMIT' viewcontrollers in the 'right' direction
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(PageViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    for(NSUInteger i = index; i < [self.pageData count] && i < index + CACHE_LIMIT; i++)
        [Utils downloadImageAtURL:self.pageData[i][@"url"]];

    
    if (index == [self.pageData count]) {
        return nil;
    }
 
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

@end
