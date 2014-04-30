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

@interface PageViewController ()

@property (strong, nonatomic) IBOutlet ImageScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet DescriptionView *descriptionView;
@property (nonatomic) BOOL showingFullDescription;

@property (nonatomic) BOOL hidingDescriptionViewForAutoLayout;
@end

@implementation PageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
        
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    
    //load the main image
    self.imageScrollView.maxImageZoom = 2;
    self.imageScrollView.imageURL = [NSURL URLWithString:tabletItem[@"url"]];


    self.descriptionView.descriptionField.delegate = self;
    //self.descriptionView.descriptionField.shouldSizeAccurate = false;
    self.descriptionView.descriptionField.shouldSizeAccurate = false;

    //load title and description
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if([appDelegate.pageShowingMore[@(self.dataIndex)] boolValue])
        [self showMore];
    else
        [self showLess];
    
    //setup the look of the views
    self.descriptionView.layer.cornerRadius = 10;
    self.descriptionView.layer.borderWidth = 0.4;
    self.descriptionView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.descriptionView.layer.masksToBounds = YES;
    
    self.descriptionView.infoButton.layer.cornerRadius = 5;
    
    self.navigationItem.title = @"CDLI Tablet";
    
    self.hidingDescriptionViewForAutoLayout = NO;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    // NSLog(@"Saving state at index %d to: %d", self.dataIndex, self.showingFullDescription);
    appDelegate.pageShowingMore[@(self.dataIndex)] = @(self.showingFullDescription);
}

- (void) showLess
{
    self.descriptionView.titleLabel.text = self.dataObject[@"blurb-title"];
    [self.descriptionView.descriptionField loadHTMLString:[self htmlFromText:self.dataObject[@"blurb"] andDate:self.dataObject[@"date"]] baseURL:nil];
    [self.descriptionView.infoButton setTitle:@"More" forState:UIControlStateNormal];
    //self.descriptionView.descriptionField.hidden = YES;
    self.showingFullDescription = NO;
}

- (void) showMore
{
    self.descriptionView.titleLabel.text = self.dataObject[@"full-title"];
    //self.descriptionView.descriptionField.text = tabletItem[@"full-info"];
    [self.descriptionView.descriptionField loadHTMLString:[self htmlFromText:self.dataObject[@"full-info"] andDate:@""] baseURL:nil];
    [self.descriptionView.infoButton setTitle:@"Less" forState:UIControlStateNormal];
    //self.descriptionView.descriptionField.hidden = YES;
    self.showingFullDescription = YES;
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
        BOOL finalNavbarHidden = !self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:finalNavbarHidden animated:YES];
        //description view and nav bar are displayed synchronously
        float originalAlpha = self.descriptionView.alpha;
        float startingAlpha = finalNavbarHidden?originalAlpha:0;
        float endingAlpha = finalNavbarHidden?0:originalAlpha;
        self.descriptionView.alpha = startingAlpha;
        
        POPBasicAnimation *animation = [POPBasicAnimation animation];
        animation.property = [POPAnimatableProperty propertyWithName:kPOPViewAlpha];
        
        if(!finalNavbarHidden)
            self.descriptionView.hidden = NO;
                
//        [UIView animateWithDuration:0.24
//                         animations:^{
//                             self.descriptionView.alpha = endingAlpha;
//                         }
//                         completion:^(BOOL finished) {
//                             if(finalNavbarHidden) {
//                                 self.descriptionView.hidden = YES;
//                                 self.descriptionView.alpha = originalAlpha;
//                             }
//                         }];

     
        animation.toValue = [NSNumber numberWithFloat:endingAlpha];

        animation.completionBlock = ^void(POPAnimation *a, BOOL finished) {
            if(finalNavbarHidden) {
                self.descriptionView.hidden = YES;
                self.descriptionView.alpha = originalAlpha;
            }
        };
            
        [self.descriptionView pop_addAnimation:animation forKey:@"toggleNav"];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //keep nav bar and description view in sync
    //they might go out of sync of another page removes the nav bar and we come back to this one
    self.descriptionView.hidden = self.navigationController.navigationBarHidden;
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
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - Buttons

- (void) infoButtonTapped:(id)sender
{
    if(!self.showingFullDescription) {
        self.descriptionView.descriptionField.shouldSizeAccurate = false;
        [self showMore];
    }
    else {
        self.descriptionView.descriptionField.shouldSizeAccurate = true;
        [self showLess];
    }
}

#pragma mark - UIWebView delegate

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //TODO: hack. If blurb is more than full, then the animation goes haywire
    if([self.dataObject[@"blurb"] length] >= [self.dataObject[@"full-info"] length]) {
        return;
    }
    
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    self.hidingDescriptionViewForAutoLayout = YES;
    
    animation.fromValue = [NSValue valueWithCGRect:self.descriptionView.frame];
    
    self.descriptionView.hidden = YES;
    [self.descriptionView invalidateIntrinsicContentSize];
    
    animation.delegate = self;
    
    animation.springBounciness = 7.0;
    animation.springSpeed = 9.0;
    
    [self.descriptionView pop_addAnimation:animation forKey:@"sizing"];
    
//    [UIView animateWithDuration:0.20 animations:^{
//        self.descriptionView.frame = self.descriptionView.bounds; //TODO: hack to make the animation work
//        [self.descriptionView invalidateIntrinsicContentSize];
//        [self.descriptionView layoutIfNeeded];
//        //self.descriptionView.descriptionField.hidden = NO;
//    }];
    
}

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    if(self.hidingDescriptionViewForAutoLayout) {
        self.descriptionView.hidden = NO;
        self.hidingDescriptionViewForAutoLayout = NO;
    }
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
