//
//  EWDataViewController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "PageViewController.h"
#import "AppDelegate.h"
#import "DescriptionView.h"
#import "ImageScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "POP.h"

#define BLURB_HEIGHT_MULTIPLIER 0.2
#define FULL_HEIGHT_MULTIPLIER 0.8

#define DESCRIPTION_ALPHA 0.7

@interface PageViewController ()

@property (strong, nonatomic) IBOutlet ImageScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet DescriptionView *descriptionView;
@property (strong, nonatomic) IBOutlet DescriptionView *descriptionViewLong;

@property (nonatomic) BOOL showingFullDescription;

@property (nonatomic) CGRect origSmallFrame;
@property (nonatomic) CGRect origLargeFrame;

@end

@implementation PageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self prepareDescriptionViewForLess:self.descriptionView];
    [self prepareDescriptionViewForMore:self.descriptionViewLong];

    //toggle nav bar when the imageview is tapped
    self.imageScrollView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.imageScrollView addGestureRecognizer:tapGestureRecognizer];
        
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    
    //load the main image
    self.imageScrollView.maxImageZoom = 2;
    self.imageScrollView.imageURL = [NSURL URLWithString:tabletItem[@"url"]];

    //load title and description
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    if([appDelegate.pageShowingMore[@(self.dataIndex)] boolValue]) {
        self.descriptionView.hidden = YES;
        self.descriptionViewLong.hidden = NO;
        self.showingFullDescription = YES;
    }
    else {
        self.descriptionView.hidden = NO;
        self.descriptionViewLong.hidden = YES;
        self.showingFullDescription = NO;
    }
    
    [self populateLessInDescriptionView:self.descriptionView];
    [self populateMoreInDescriptionView:self.descriptionViewLong];
    
    self.navigationItem.title = @"CDLI Tablet";
    
}

- (void) prepareDescriptionView: (DescriptionView *) descriptionView
{
    //setup the look of the views
    descriptionView.layer.cornerRadius = 10;
    descriptionView.layer.borderWidth = 0.4;
    descriptionView.layer.borderColor = [[UIColor grayColor] CGColor];
    descriptionView.layer.masksToBounds = YES;
    
    descriptionView.infoButton.layer.cornerRadius = 5;

    
    descriptionView.descriptionField.shouldSizeAccurate = true;
    descriptionView.descriptionField.delegate = self;
    descriptionView.descriptionField.scrollView.delegate = self;
}

- (void) prepareDescriptionViewForMore: (DescriptionView *) descriptionView
{
    [self prepareDescriptionView:descriptionView];
    //description view width is one third of the main view's width
    NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.33
                                                           constant:0];
    [self.view addConstraint:cn];
    
    //set a maximum height
    cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationLessThanOrEqual
                                         toItem:self.view
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:FULL_HEIGHT_MULTIPLIER
                                       constant:0];
    [self.view addConstraint:cn];
    
    cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                      attribute:NSLayoutAttributeTrailing
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                      attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                       constant:-20];
    [self.view addConstraint:cn];
    
    cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                       constant:0];
    
    [self.view addConstraint:cn];
}

- (void) prepareDescriptionViewForLess: (DescriptionView *) descriptionView
{
    [self prepareDescriptionView:descriptionView];
    
    //description view width is one third of the main view's width
    NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:0.33
                                                           constant:0];
    [self.view addConstraint:cn];
    
    //set a minimum height
    cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationGreaterThanOrEqual
                                         toItem:self.view
                                      attribute:NSLayoutAttributeHeight
                                     multiplier:BLURB_HEIGHT_MULTIPLIER
                                       constant:0];
    [self.view addConstraint:cn];
    
    
    cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                      attribute:NSLayoutAttributeTrailing
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                      attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                       constant:-20];
    [self.view addConstraint:cn];
    
    cn = [NSLayoutConstraint constraintWithItem:descriptionView
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.view
                                      attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                       constant:0];
    
    [self.view addConstraint:cn];
    
//    cn = [NSLayoutConstraint constraintWithItem:descriptionView
//                                      attribute:NSLayoutAttributeTop
//                                      relatedBy:NSLayoutRelationEqual
//                                         toItem:self.view
//                                      attribute:NSLayoutAttributeTop
//                                     multiplier:1
//                                       constant:768];
//    cn.priority = 100;
    
    [self.view addConstraint:cn];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // NSLog(@"Saving state at index %d to: %d", self.dataIndex, self.showingFullDescription);
    appDelegate.pageShowingMore[@(self.dataIndex)] = @(self.showingFullDescription);
}


- (void) populateLessInDescriptionView: (DescriptionView *) descriptionView
{
    descriptionView.titleLabel.text = self.dataObject[@"blurb-title"];
    [descriptionView.descriptionField loadHTMLString:[self htmlFromText:self.dataObject[@"blurb"] andDate:self.dataObject[@"date"]] baseURL:nil];
    [descriptionView.infoButton setTitle:@"More" forState:UIControlStateNormal];
}

- (void) showLess
{
    if([self.descriptionView pop_animationForKey:@"more"] != nil){
        NSLog(@"Pending animation, not showing less");
        return;
    }

    [self saveDescriptionViewFrames];
    self.descriptionView.hidden = NO;
    self.descriptionView.alpha = 0;
    
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    animation.toValue = [NSValue valueWithCGRect:self.descriptionView.frame];
    animation.delegate = self;
    animation.springBounciness = 7.0;
    animation.springSpeed = 9.0;
    animation.name = @"less";
    [self.descriptionViewLong pop_addAnimation:animation forKey:@"less"];
    
    self.showingFullDescription = NO;
}

- (void) populateMoreInDescriptionView: (DescriptionView *) descriptionView
{
    descriptionView.titleLabel.text = self.dataObject[@"full-title"];
    [descriptionView.descriptionField loadHTMLString:[self htmlFromText:self.dataObject[@"full-info"] andDate:@""] baseURL:nil];
    [descriptionView.infoButton setTitle:@"Less" forState:UIControlStateNormal];
}

- (void) showMore
{
    if([self.descriptionViewLong pop_animationForKey:@"less"] != nil){
        NSLog(@"Pending animation, not showing more");
        return;
    }
    
    [self saveDescriptionViewFrames];
    self.descriptionViewLong.hidden = NO;
    self.descriptionViewLong.alpha = 0;

    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    animation.toValue = [NSValue valueWithCGRect:self.descriptionViewLong.frame];
    animation.delegate = self;
    animation.springBounciness = 7.0;
    animation.springSpeed = 9.0;
    animation.name = @"more";
    [self.descriptionView pop_addAnimation:animation forKey:@"more"];
    
    self.showingFullDescription = YES;
}

- (void) saveDescriptionViewFrames
{
    self.origSmallFrame = self.descriptionView.frame;
    self.origLargeFrame = self.descriptionViewLong.frame;
}

- (void) restoreDescriptionViewFrames
{
    self.descriptionView.frame = self.origSmallFrame;
    self.descriptionView.alpha = DESCRIPTION_ALPHA;
    self.descriptionViewLong.frame = self.origLargeFrame;
    self.descriptionViewLong.alpha = DESCRIPTION_ALPHA;
}

- (void) pop_animationDidApply:(POPAnimation *)anim
{
    if([anim.name isEqualToString:@"more"]) {
        [self animateBigger];
    }
    else if([anim.name isEqualToString:@"less"]) {
        [self animateSmaller];
    }
}

- (void) animateBigger
{
    self.descriptionViewLong.frame = self.descriptionView.frame;
    if(self.descriptionView.alpha >= 0) {
        self.descriptionView.alpha -= 0.05;
    }
    
    if(self.descriptionViewLong.alpha <= DESCRIPTION_ALPHA) {
        self.descriptionViewLong.alpha += 0.05;
    }
}

- (void) animateSmaller
{
    self.descriptionView.frame = self.descriptionViewLong.frame;
    if(self.descriptionViewLong.alpha >= 0) {
        self.descriptionViewLong.alpha -= 0.05;
    }
    
    if(self.descriptionView.alpha <= DESCRIPTION_ALPHA) {
        self.descriptionView.alpha += 0.05;
    }
}

- (void) pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if([anim.name isEqualToString:@"more"]) {
        self.descriptionView.hidden = YES;
        [self.descriptionViewLong.descriptionField.scrollView setContentOffset:CGPointZero animated:NO];
    }
    else if([anim.name isEqualToString:@"less"]) {
        self.descriptionViewLong.hidden = YES;
        [self.descriptionView.descriptionField.scrollView setContentOffset:CGPointZero animated:NO];
    }
    
    [self restoreDescriptionViewFrames];
}

- (NSString *) htmlFromText: (NSString *)text andDate: (NSString *) date
{
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    NSString *html = [NSString stringWithFormat:
                      @"<html><head>"
                      @"<style type=\"text/css\">"
                        @"body { font-family: Optima, \"Gill Sans\", sans-serif; font-size: 1em }"
                        @"a:link { color:#AD90FF; } "
                      @"</style>"
                      @"</head><body text=\"white\"> %@"
                      "<p align=\"right\"><font size=\"-1\"><i>%@</i></font></p>"
                      "</body></html>",
                      text, date];
    
    return html;
}

- (void) didReceiveMemoryWarning
{
    NSLog(@"Got memory warning!");
    [super didReceiveMemoryWarning];
}

- (void) toggleNavigationBar:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        DescriptionView *currentDescriptionView = self.showingFullDescription ? self.descriptionViewLong : self.descriptionView;
        
        BOOL finalNavbarHidden = !self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:finalNavbarHidden animated:YES];
        //description view and nav bar are displayed synchronously
        float originalAlpha = currentDescriptionView.alpha;
        float startingAlpha = finalNavbarHidden?originalAlpha:0;
        float endingAlpha = finalNavbarHidden?0:originalAlpha;
        currentDescriptionView.alpha = startingAlpha;
        
        POPBasicAnimation *animation = [POPBasicAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
        
        if(!finalNavbarHidden)
            currentDescriptionView.hidden = NO;
                
        animation.toValue = [NSNumber numberWithFloat:endingAlpha];

        animation.completionBlock = ^void(POPAnimation *a, BOOL finished) {
            if(finalNavbarHidden) {
                currentDescriptionView.hidden = YES;
                currentDescriptionView.alpha = originalAlpha;
            }
        };
        
        [currentDescriptionView pop_addAnimation:animation forKey:@"toggleNav"];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //keep nav bar and description view in sync
    //they might go out of sync of another page removes the nav bar and we come back to this one
    DescriptionView *currentDescriptionView = self.showingFullDescription ? self.descriptionViewLong : self.descriptionView;
    
    currentDescriptionView.hidden = self.navigationController.navigationBarHidden;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - InterfaceOrientationMethods

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.descriptionView.descriptionField.shouldSizeAccurate = true;
    self.descriptionViewLong.descriptionField.shouldSizeAccurate = true;
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Buttons

- (void) infoButtonTapped:(id)sender
{
    if(!self.showingFullDescription) {
        [self showMore];
    }
    else {
        [self showLess];
    }
}

#pragma mark - UIScrollView delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.tracking) {
        //NSLog(@"Scroll view scrolled to: %@", NSStringFromCGPoint(scrollView.contentOffset));
        
        if(!self.showingFullDescription && scrollView.contentOffset.y >= 40) {
            //[scrollView setContentOffset:CGPointZero animated:NO];
            //self.descriptionView.descriptionField.shouldSizeAccurate = false;
            [self showMore];
        }
        
        if(self.showingFullDescription && scrollView.contentOffset.y <= -80) {
            //[scrollView setContentOffset:CGPointZero animated:NO];
            //self.descriptionView.descriptionField.shouldSizeAccurate = true;
            [self showLess];
        }
    }
}

#pragma mark - UIWebView delegate

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self.descriptionView invalidateIntrinsicContentSize];
    [self.descriptionView layoutIfNeeded];
    [self.descriptionViewLong invalidateIntrinsicContentSize];
    [self.descriptionViewLong layoutIfNeeded];
}


- (BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
