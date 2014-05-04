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
@property (nonatomic) NSValue *descriptionScrollStartingPoint;
@property (nonatomic) POPAnimatableProperty *descriptionViewBiggerProperty;
@property (nonatomic) POPAnimatableProperty *descriptionViewSmallerProperty;
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

    self.descriptionViewBiggerProperty = [POPAnimatableProperty propertyWithName:@"descriptionViewBigger" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(PageViewController *obj, CGFloat values[]) {
            values[0] = obj.descriptionView.frame.origin.y;
        };
        // write value
        prop.writeBlock = ^(PageViewController *obj, const CGFloat values[]) {
            float newY = values[0];
            
            [obj updateDescriptionViewsWithY:newY];
            
            float currentHeight = obj.descriptionView.frame.size.height - obj.origSmallFrame.size.height;
            float currentAlpha = [obj alphaForHeight:currentHeight];

            obj.descriptionView.alpha = DESCRIPTION_ALPHA - currentAlpha;
            obj.descriptionViewLong.alpha = currentAlpha;
        };
        // dynamics threshold
        prop.threshold = 1;
    }];
    
    self.descriptionViewSmallerProperty = [POPAnimatableProperty propertyWithName:@"descriptionViewSmaller" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(PageViewController *obj, CGFloat values[]) {
            values[0] = obj.descriptionViewLong.frame.origin.y;
        };
        // write value
        prop.writeBlock = ^(PageViewController *obj, const CGFloat values[]) {
            float newY = values[0];
            
            [obj updateDescriptionViewsWithY:newY];
            
            float currentHeight = obj.origLargeFrame.size.height - obj.descriptionView.frame.size.height;
            float currentAlpha = [obj alphaForHeight:currentHeight];
            
            obj.descriptionView.alpha = currentAlpha;
            obj.descriptionViewLong.alpha = DESCRIPTION_ALPHA - currentAlpha;
        };
        // dynamics threshold
        prop.threshold = 1;
    }];
}

- (void) updateDescriptionViewsWithY: (float) newY
{
    float newHeight = self.origSmallFrame.origin.y - newY + self.origSmallFrame.size.height;
    //            NSLog(@"newY: %f, newHeight: %f", newY, newHeight);
    CGRect origFrame = self.descriptionView.frame;
    CGRect newFrame = CGRectMake(origFrame.origin.x, newY, origFrame.size.width, newHeight);
    self.descriptionView.frame = newFrame;
    self.descriptionViewLong.frame = newFrame;
}

- (float) alphaForHeight: (float) currentHeight
{
    float midHeight = (self.origLargeFrame.size.height - self.origSmallFrame.size.height)/2;
    
    //    NSLog(@"Current height: %f, midpoint: %f", currentHeight, midHeight);
    if (currentHeight >= midHeight) {
        return DESCRIPTION_ALPHA;
    }
    else {
        float currentAlpha = DESCRIPTION_ALPHA * currentHeight / midHeight;
        //        NSLog(@"Current alpha: %f", currentAlpha);
        return currentAlpha;
    }
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
    
    [self prepareToShowLess];

    POPSpringAnimation *animation = [POPSpringAnimation animation];
//    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    animation.property = self.descriptionViewSmallerProperty;
//    animation.toValue = [NSValue valueWithCGRect:self.descriptionView.frame];
    animation.toValue = @(self.descriptionView.frame.origin.y);
//    animation.delegate = self;
    animation.springBounciness = 7.0;
    animation.springSpeed = 9.0;
    animation.name = @"less";
    animation.completionBlock = ^void (POPAnimation *anim, BOOL finished) {
        [self doneAnimatingSmaller];
    };

//    [self.descriptionViewLong pop_addAnimation:animation forKey:@"less"];
    [self pop_addAnimation:animation forKey:@"less"];
    
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
    
    [self prepareToShowMore];

    POPSpringAnimation *animation = [POPSpringAnimation animation];
//    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    animation.property = self.descriptionViewBiggerProperty;
//    animation.toValue = [NSValue valueWithCGRect:self.descriptionViewLong.frame];
    animation.toValue = @(self.descriptionViewLong.frame.origin.y);
//    animation.delegate = self;
    animation.springBounciness = 7.0;
    animation.springSpeed = 9.0;
    animation.name = @"more";
    animation.completionBlock = ^void (POPAnimation *anim, BOOL finished) {
        [self doneAnimatingBigger];
    };
    
//    [self.descriptionView pop_addAnimation:animation forKey:@"more"];
    [self pop_addAnimation:animation forKey:@"more"];
    self.showingFullDescription = YES;
}

- (void) saveDescriptionViewFrames
{
    self.origSmallFrame = self.descriptionView.frame;
    self.origLargeFrame = self.descriptionViewLong.frame;
}

- (void) prepareToShowMore
{
    [self saveDescriptionViewFrames];
    self.descriptionViewLong.hidden = NO;
    self.descriptionViewLong.alpha = 0;
}

- (void) prepareToShowLess
{
    [self saveDescriptionViewFrames];
    self.descriptionView.hidden = NO;
    self.descriptionView.alpha = 0;
}

- (void) restoreDescriptionViewFrames
{
    self.descriptionView.frame = self.origSmallFrame;
    self.descriptionView.alpha = DESCRIPTION_ALPHA;
    self.descriptionViewLong.frame = self.origLargeFrame;
    self.descriptionViewLong.alpha = DESCRIPTION_ALPHA;
}

// midHeight -> DESCRIPTION_ALPHA
// currentHeight -> ?
//- (void) animateBigger
//{
//    self.descriptionViewLong.frame = self.descriptionView.frame;
//    float midHeight = (self.origLargeFrame.size.height - self.origSmallFrame.size.height)/2;
//    float currentHeight = self.descriptionView.frame.size.height - self.origSmallFrame.size.height;
////    NSLog(@"Current height: %f, midpoint: %f", currentHeight, midHeight);
//    if (currentHeight >= midHeight) {
//        self.descriptionView.alpha = 0;
//        self.descriptionViewLong.alpha = DESCRIPTION_ALPHA;
//    }
//    else {
//        float currentAlpha = DESCRIPTION_ALPHA * currentHeight / midHeight;
////        NSLog(@"Current alpha: %f", currentAlpha);
//        self.descriptionView.alpha = DESCRIPTION_ALPHA - currentAlpha;
//        self.descriptionViewLong.alpha = currentAlpha;
//    }
//}

//- (void) animateSmaller
//{
//    self.descriptionView.frame = self.descriptionViewLong.frame;
//    float midHeight = (self.origLargeFrame.size.height - self.origSmallFrame.size.height)/2;
//    float currentHeight = self.origLargeFrame.size.height - self.descriptionView.frame.size.height;
//    //    NSLog(@"Current height: %f, midpoint: %f", currentHeight, midPoint);
//    if (currentHeight >= midHeight) {
//        self.descriptionViewLong.alpha = 0;
//        self.descriptionView.alpha = DESCRIPTION_ALPHA;
//    }
//    else {
//        float currentAlpha = DESCRIPTION_ALPHA * currentHeight / midHeight;
//        self.descriptionView.alpha = currentAlpha;
//        self.descriptionViewLong.alpha = DESCRIPTION_ALPHA - currentAlpha;
//    }
//}

- (void) doneAnimatingBigger
{
    self.descriptionView.hidden = YES;
    //[self.descriptionViewLong.descriptionField.scrollView setContentOffset:CGPointZero animated:NO];
    [self restoreDescriptionViewFrames];
}

- (void) doneAnimatingSmaller
{
    self.descriptionViewLong.hidden = YES;
    //[self.descriptionView.descriptionField.scrollView setContentOffset:CGPointZero animated:NO];
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

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"Drag began");
    self.descriptionScrollStartingPoint = nil;
}

typedef enum {UP, DOWN} Direction;

- (void) trackDirection: (Direction) direction
{
    DescriptionView *currentDescriptionView = direction == UP ? self.descriptionView : self.descriptionViewLong;
    
    float currentHeight = [currentDescriptionView.descriptionField.scrollView.panGestureRecognizer translationInView:self.view].y;
    float deltaHeight = [self.descriptionScrollStartingPoint CGPointValue].y - currentHeight;
    CGRect frame = direction == UP ? self.origSmallFrame : self.origLargeFrame;
    float newY = frame.origin.y - deltaHeight;

//    NSLog(@"Current height: %f, Delta height: %f", currentHeight,deltaHeight);
//    CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y - deltaHeight, frame.size.width, frame.size.height + deltaHeight);
    POPBasicAnimation *animation = [POPBasicAnimation animation];
//    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    animation.property = direction == UP ? self.descriptionViewBiggerProperty : self.descriptionViewSmallerProperty;
//    animation.toValue = [NSValue valueWithCGRect:newFrame];
    animation.toValue = @(newY);
    animation.delegate = self;

    NSString *name = direction == UP ? @"more" : @"less";
    animation.name = name;
    animation.duration = 0.05;
    [self pop_addAnimation:animation forKey:name];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!scrollView.tracking)
        return;
    
    [self pop_removeAllAnimations];
    
    if(!self.showingFullDescription) {
        float scrolledHeight = scrollView.contentOffset.y + scrollView.frame.size.height;
        float totalHeight = scrollView.contentSize.height;
        
        if(scrolledHeight >= totalHeight) {
            if(self.descriptionScrollStartingPoint == nil) {
                self.descriptionScrollStartingPoint = [NSValue valueWithCGPoint:[scrollView.panGestureRecognizer translationInView:self.view]];
                
                [self prepareToShowMore];
            }
            
            [self.descriptionView pop_removeAllAnimations];
            [self trackDirection:UP];
        }
    }
    else {
        float deltaHeight = scrollView.contentOffset.y;
        if(deltaHeight < 0) {
            if(self.descriptionScrollStartingPoint == nil) {
                self.descriptionScrollStartingPoint = [NSValue valueWithCGPoint:[scrollView.panGestureRecognizer translationInView:self.view]];
                
                [self prepareToShowLess];
            }
            
            [self.descriptionViewLong pop_removeAllAnimations];
            [self trackDirection:DOWN];
        }
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    NSLog(@"dragging ended");
    [self pop_removeAllAnimations];
    
    if(self.descriptionScrollStartingPoint == nil) {
        return;
    }

    self.descriptionScrollStartingPoint = nil;

    float velocity = [scrollView.panGestureRecognizer velocityInView:self.view].y;
    Direction direction = velocity < 0 ? UP : DOWN;

    POPSpringAnimation *animation = [POPSpringAnimation animation];
//    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewFrame];
    animation.toValue = @(direction == UP ? self.origLargeFrame.origin.y: self.origSmallFrame.origin.y);
//    animation.delegate = self;
    animation.springBounciness = 7.0;
    animation.springSpeed = 9.0;
    animation.completionBlock = ^void (POPAnimation *anim, BOOL finished) {
//        NSLog(@"animation done");
        if(direction == UP)
            [self doneAnimatingBigger];
        else
            [self doneAnimatingSmaller];
    };

    animation.velocity = @(velocity);
    
    if(!self.showingFullDescription) {
        //animation.name = @"more";
        animation.property = self.descriptionViewBiggerProperty;
        [self pop_addAnimation:animation forKey:@"more"];
    }
    else {
//        animation.name = @"less";
        animation.property = self.descriptionViewSmallerProperty;
        [self pop_addAnimation:animation forKey:@"less"];
    }
    
    if(direction == UP) {
        self.showingFullDescription = YES;
    }
    else {
        self.showingFullDescription = NO;
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
