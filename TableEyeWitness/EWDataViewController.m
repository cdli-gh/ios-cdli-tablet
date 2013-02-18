//
//  EWDataViewController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "EWDataViewController.h"
#import "EWAppDelegate.h"
#import "DescriptionView.h"
#import "ImageScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>


#define BLURB_HEIGHT_MULTIPLIER 0.2
#define FULL_HEIGHT_MULTIPLIER 0.8

@interface EWDataViewController ()

@property (strong, nonatomic) IBOutlet ImageScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet DescriptionView *descriptionView;
@property (nonatomic) BOOL showingFullDescription;
@end

@implementation EWDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showingFullDescription = NO;
    
    //approximately center the view (with 10 point padding)
//    NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:self.descriptionView
//                                                          attribute:NSLayoutAttributeLeading
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.0
//                                                           constant:-10];
//    [self.view addConstraint:cn];

    //description view width is one third of the main view's width
    NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.33
                                                           constant:0];
    [self.view addConstraint:cn];

    //set a minimum height
    cn = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:BLURB_HEIGHT_MULTIPLIER
                                                                 constant:0];
    [self.view addConstraint:cn];
    

    //set a maximum height
    cn = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationLessThanOrEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:FULL_HEIGHT_MULTIPLIER
                                                                 constant:0];
    [self.view addConstraint:cn];

    //toggle nav bar when the imageview is tapped
    self.imageScrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.imageScrollView addGestureRecognizer:tapGestureRecognizer];
        
    //load the main image
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;

    self.imageScrollView.maxImageZoom = 2;
    self.imageScrollView.imageURL = [NSURL URLWithString:tabletItem[@"url"]];
    
    self.descriptionView.titleLabel.text = tabletItem[@"blurb-title"];
    self.descriptionView.descriptionField.text = tabletItem[@"blurb"];
    
    //setup the look of the views
    self.descriptionView.layer.cornerRadius = 10;
    self.descriptionView.layer.borderWidth = 0.4;
    self.descriptionView.layer.borderColor = CGColorRetain([[UIColor grayColor] CGColor]);
    self.descriptionView.layer.masksToBounds = YES;
    
    self.descriptionView.infoButton.layer.cornerRadius = 5;
    
    self.navigationItem.title = @"CDLI Tablet";

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)toggleNavigationBar:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        BOOL finalNavbarHidden = !self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:finalNavbarHidden animated:YES];
        //description view and nav bar are displayed synchronously
        float originalAlpha = self.descriptionView.alpha;
        float startingAlpha = finalNavbarHidden?originalAlpha:0;
        float endingAlpha = finalNavbarHidden?0:originalAlpha;
        self.descriptionView.alpha = startingAlpha;
        
        if(!finalNavbarHidden)
            self.descriptionView.hidden = NO;
        
        //NSLog(@"Staring alpha: %f, ending: %f", startingAlpha, endingAlpha);
        
        [UIView animateWithDuration:0.24
                         animations:^{
                             self.descriptionView.alpha = endingAlpha;
                         }
                         completion:^(BOOL finished) {
                             if(finalNavbarHidden) {
                                 self.descriptionView.hidden = YES;
                                 self.descriptionView.alpha = originalAlpha;
                             }
                         }];

//        float newScale = [self.scrollView zoomScale] * 1.5;
//        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[sender locationInView:sender.view]];
//        NSLog(@"Trying to zoom");
//        [self.scrollView zoomToRect:zoomRect animated:YES];

        // NSLog(@"Got a tap");
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //keep nav bar and description view in sync
    //they might go out of sync of another page removes the nav bar and we come back to this one
    self.descriptionView.hidden = self.navigationController.navigationBarHidden;
}

//This will try to fit the entire descriptionView so that the descriptionField will not have to scroll
- (void) setAppropriateDescriptionFieldHeight
{
    [self.descriptionView invalidateIntrinsicContentSize];
    [UIView animateWithDuration:0.25 animations:^{
        [self.descriptionView layoutIfNeeded];
    }];
    //NSLog(@"Has ambigous layout? %d", self.view.hasAmbiguousLayout);
}

#pragma mark - InterfaceOrientationMethods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Buttons

- (void) infoButtonTapped:(id)sender
{
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    
    NSString *buttonTitle;
    
    if(!self.showingFullDescription) {
        self.descriptionView.titleLabel.text = tabletItem[@"full-title"];
        self.descriptionView.descriptionField.text = tabletItem[@"full-info"];
        buttonTitle = @"Less";
    }
    else {
        self.descriptionView.descriptionField.text = tabletItem[@"blurb"];
        self.descriptionView.titleLabel.text = tabletItem[@"blurb-title"];
        buttonTitle = @"More";
    }

    [self setAppropriateDescriptionFieldHeight];
    [self.descriptionView.infoButton setTitle:buttonTitle forState:UIControlStateNormal];
    self.showingFullDescription = !self.showingFullDescription;
}

@end
