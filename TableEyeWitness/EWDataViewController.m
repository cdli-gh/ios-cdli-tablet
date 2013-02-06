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
#import <SDWebImage/UIImageView+WebCache.h>

#define BLURB_HEIGHT_MULTIPLIER 0.2
#define FULL_HEIGHT_MULTIPLIER 0.8

@interface EWDataViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet DescriptionView *descriptionView;
@property (nonatomic) BOOL showingFullDescription;
@property (nonatomic, strong) NSLayoutConstraint *currentHeightConstraint;
@end

@implementation EWDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showingFullDescription = NO;
//    NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:self.descriptionView
//                                                          attribute:NSLayoutAttributeLeft
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeCenterX
//                                                         multiplier:1.0
//                                                           constant:-10];
    //[self.view addConstraint:cn];

    self.currentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:BLURB_HEIGHT_MULTIPLIER
                                                                 constant:0];
    [self.view addConstraint:self.currentHeightConstraint];

    self.imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
    
    NSString *imageNameToLoad = @"loading";
    NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"gif"];
    UIImage *placeholderImage = [[UIImage alloc] initWithContentsOfFile:pathToImage];
    
    EWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *baseURL = appDelegate.baseURL;
    
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", baseURL, tabletItem[@"url"]];
    NSLog(@"BigPhoto: Trying to fetch %@", urlString);
    
    [self.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholderImage];
    
    self.descriptionView.titleLabel.text = tabletItem[@"blurb-title"];
    self.descriptionView.descriptionField.text = tabletItem[@"blurb"];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - InterfaceOrientationMethods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

//This will try to fit the entire descriptionView so that the descriptionField will not have to scroll
//This is done by increasing the height until it reaches a maximum of 80% of the entire view
//This is only done when full details are being displayed
//TODO: See if this can be done automatically by auto layout
- (void) setDescriptionTextHeightWithFullText: (BOOL) fullText
{
    float finalHeightMultiplier = 0;
    
    if(fullText) {
        float extraHeight = self.descriptionView.descriptionField.contentSize.height - CGRectGetHeight(self.descriptionView.descriptionField.frame);
        //NSLog(@"Extra height: %f", extraHeight);
        float mult = (CGRectGetHeight(self.descriptionView.frame) + extraHeight) / CGRectGetHeight(self.view.frame);
        //NSLog(@"Optimal mult: %f", mult);
        finalHeightMultiplier = MIN(mult, FULL_HEIGHT_MULTIPLIER);
        
    }
    else {
        finalHeightMultiplier = BLURB_HEIGHT_MULTIPLIER;
    }
    

    [self.view removeConstraint:self.currentHeightConstraint];
    self.currentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:self.view
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:finalHeightMultiplier
                                                                 constant:0];
    

    
    [self.view addConstraint:self.currentHeightConstraint];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.25 animations:^{
        [self.descriptionView layoutIfNeeded];
    }];
    //NSLog(@"Has ambigous layout? %d", self.view.hasAmbiguousLayout);

}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(self.showingFullDescription)
        [self setDescriptionTextHeightWithFullText:YES];
}

#pragma mark - Buttons

- (void) infoButtonTapped:(id)sender
{
//    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    
    NSString *buttonTitle;
    
    if(!self.showingFullDescription) {
        self.descriptionView.titleLabel.text = tabletItem[@"full-title"];
        self.descriptionView.descriptionField.text = tabletItem[@"full-info"];
        buttonTitle = @"Less";
        [self setDescriptionTextHeightWithFullText:YES];
    }
    else {
        self.descriptionView.descriptionField.text = tabletItem[@"blurb"];
        self.descriptionView.titleLabel.text = tabletItem[@"blurb-title"];
        buttonTitle = @"More";
        [self setDescriptionTextHeightWithFullText:NO];
    }

    [self.descriptionView.infoButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self.descriptionView.descriptionField sizeToFit];
    self.showingFullDescription = !self.showingFullDescription;
}

@end
