//
//  LandingViewController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 3/12/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "LandingViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "OHURLLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>
#include "TargetConditionals.h"

@interface LandingViewController ()

@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, strong) NSArray *cachedItems;

@end

@implementation LandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Views are processed in the order given by this array for animations
	// To animate them one row at a time
    
//    self.imageViews = @[self.i00, self.i01, self.i02,
//                        self.i10, self.i11, self.i12,
//                        self.i20, self.i21, self.i22];

    // For a circular kind of animation
//    self.imageViews = @[self.i00, self.i01, self.i02,
//                        self.i12, self.i22, self.i21,
//                        self.i20, self.i10, self.i11];

    NSMutableArray *allImageViews = [[NSMutableArray alloc] initWithObjects:
                                                                self.i00, self.i01, self.i02,
                                                                self.i10, self.i11, self.i12,
                                                                self.i20, self.i21, self.i22
    
                                      , nil];
    
    
    //randomize image placement
    
    [self shuffleArray:allImageViews];
    self.imageViews = allImageViews;
    
    NSData *JSONData = [Utils loadCachedJSON];
    if(JSONData != nil) {
        self.cachedItems = [Utils loadJSONData:JSONData];
        //NSLog(@"Total items in json cache: %d", self.cachedItems.count);
    }
    else {
        NSLog(@"No cached data");
        self.cachedItems = @[];
    }
    
    [self initializeImages];
}

- (void)shuffleArray:(NSMutableArray *)array
{
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = (arc4random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    float delay = 0;

    //perform faster animations on the simulator

#if !(TARGET_IPHONE_SIMULATOR)
    float duration = 0.4;
#else
    float duration = 0.1;
#endif
    
    for(int i = 0; i < self.imageViews.count; i++) {
        UIImageView *iv = self.imageViews[i];
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             iv.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             if(i == self.imageViews.count - 1) {
                                 AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                                 delegate.noThumbnails = YES;
                                 [self performSegueWithIdentifier:@"ShowRoot" sender:self];
                             }
                         }
         ];
        
        delay += duration + 0.05;
    }
}

- (void) initializeImages
{
    int cachedImagesIndex = 0;
    
    for (UIImageView *iv in self.imageViews) {
        iv.alpha = 0;
        if(cachedImagesIndex < self.cachedItems.count) {
            NSMutableDictionary *item = self.cachedItems[cachedImagesIndex];
            [[SDImageCache sharedImageCache]
                queryDiskCacheForKey:item[@"thumbnail-url"]
                done:^(UIImage *image, SDImageCacheType type) {
                    if(image != nil) {
                        // NSLog(@"Found cache for %@", item[@"blurb-title"]);
                        [iv setImage:image];
                    }
                    else
                        NSLog(@"No cached imaged for: %@ (URL: %@)", item[@"blurb-title"], item[@"thumbnail-url"]);
                }
             ];
            
            cachedImagesIndex++;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
