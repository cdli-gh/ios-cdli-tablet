//
//  LandingViewController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 3/12/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "LandingViewController.h"
#import "EWAppDelegate.h"
#import "Utils.h"
#import "OHURLLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LandingViewController ()

@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, strong) NSArray *cachedItems;

@end

@implementation LandingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self refreshData];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self refreshData];
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
    self.imageViews = @[self.i00, self.i01, self.i02,
                        self.i12, self.i22, self.i21,
                        self.i20, self.i10, self.i11];

    
    NSData *JSONData = [Utils loadCachedJSON];
    if(JSONData != nil) {
        self.cachedItems = [self loadJSONData:JSONData];
        //NSLog(@"Total items in json cache: %d", self.cachedItems.count);
    }
    else {
        NSLog(@"No cached data");
        self.cachedItems = @[];
    }
    
    [self initializeImages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    float delay = 0;
    float duration = 0.4;
    
    for(int i = 0; i < self.imageViews.count; i++) {
        UIImageView *iv = self.imageViews[i];
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             iv.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                             if(i == self.imageViews.count - 1)
                                 [self performSegueWithIdentifier:@"ShowRoot" sender:self];
                         }
         ];
        
        delay += duration + 0.05;
    }
}

- (void) initializeImages
{
    int cachedImagesIndex = self.cachedItems.count - 1;
    
    for (UIImageView *iv in self.imageViews) {
        iv.alpha = 0;
        if(cachedImagesIndex >= 0) {
            NSMutableDictionary *item = self.cachedItems[cachedImagesIndex];
            [[SDImageCache sharedImageCache]
                queryDiskCacheForKey:item[@"thumbnail-url"]
                done:^(UIImage *image, SDImageCacheType type) {
                    if(image != nil)
                        [iv setImage:image];
                    else
                        NSLog(@"No cached imaged for: %@", item[@"thumbnail-url"]);
                }
             ];
            
            cachedImagesIndex--;
        }
    }
}

- (void)refreshData {
    EWAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSString *feedURL = [NSString stringWithFormat:@"http://www.cdli.ucla.edu/cdlisearch/search/ipadweb/json?all=true"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:feedURL]];
    
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest:request];
	[loader startRequestWithCompletion:^(NSData* receivedData, NSInteger httpStatusCode) {
		NSLog(@"Refreshed");

        NSArray *tabletItems = [self loadJSONData:receivedData];
        
        delegate.tabletItems = tabletItems;
        delegate.pageShowingMore = [[NSMutableDictionary alloc] initWithCapacity:[tabletItems count]];
        for(int i = 0; i < [delegate.tabletItems count]; i++)
            delegate.pageShowingMore[@(i)] = @(false);
        
        [Utils cacheJSON:receivedData];

	} errorHandler:^(NSError* error) {
		NSLog(@"Could not referesh data!!! %@", error);
	}];
}

- (NSArray *) loadJSONData: (NSData *)JSONData
{
    NSError *error = nil;
    NSArray *tabletItems = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&error];
    
    //NSLog(@"Tablet items: %@", tabletItems);
    
    for (NSMutableDictionary *item in tabletItems) {
        item[@"full-info"] = [item[@"full-info"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        item[@"blurb"] = [item[@"blurb"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    
    return tabletItems;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
