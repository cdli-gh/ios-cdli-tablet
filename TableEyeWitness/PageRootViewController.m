//
//  EWRootViewController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "PageRootViewController.h"
#import "ModelController.h"
#import "PageViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface PageRootViewController () <MFMailComposeViewControllerDelegate>
@property (readonly, strong, nonatomic) ModelController *modelController;

- (IBAction)showEmail:(id)sender;
@end

@implementation PageRootViewController

@synthesize modelController = _modelController;

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;

    PageViewController *startingViewController = [self.modelController viewControllerAtIndex:self.startIndex storyboard:self.storyboard];
    
    if(startingViewController == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"Could not load entries, check your internet connection"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    self.pageViewController.dataSource = self.modelController;

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];

    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[infoButton addTarget:self action:@selector(showAbout:) forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                          target:nil
                                                                          action:nil];
    space.width = 15;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                               initWithTitle:@"Share"
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(showEmail:)];
    
//    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc]
//                               initWithTitle:@"About"
//                               style:UIBarButtonItemStylePlain
//                               target:self
//                               action:@selector(showAbout:)];
    
    NSArray *arrBtns = [[NSArray alloc]initWithObjects:aboutButton, space, shareButton, nil];

    self.navigationItem.rightBarButtonItems = arrBtns;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ModelController *) modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[ModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

/*
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}
 */

//- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
//{
//    if (UIInterfaceOrientationIsPortrait(orientation)) {
//        // In portrait orientation: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
//        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
//        NSArray *viewControllers = @[currentViewController];
//        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
//        
//        self.pageViewController.doubleSided = NO;
//        return UIPageViewControllerSpineLocationMin;
//    }
//
//    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
//    PageViewController *currentViewController = self.pageViewController.viewControllers[0];
//    NSArray *viewControllers = nil;
//
//    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
//    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
//        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
//        viewControllers = @[currentViewController, nextViewController];
//    } else {
//        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
//        viewControllers = @[previousViewController, currentViewController];
//    }
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
//
//
//    return UIPageViewControllerSpineLocationMid;
//}

#pragma mark - Button actions

- (IBAction) showAbout: (id)sender
{
    [self performSegueWithIdentifier:@"ShowAboutPage" sender:self];
}

- (IBAction) showEmail: (id)sender
{
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot send email"
                                                        message:@"Cannot send email through this device. Please check your settings"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    PageViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSDictionary *tabletItem = (NSDictionary *)currentViewController.dataObject;
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSString *subject = [NSString stringWithFormat:@"%@ - cdli tablet", tabletItem[@"blurb-title"]];
    [picker setSubject:subject];
    
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat:@
                           "I saw this entry on the iPad app \"cdli tablet\" and wanted to share it with you:<br/><br/>"
                           "<img src=%@ /> <br /><br />"
                           "\"%@\" <br /> <br />"
                           "<a href=\"http://cdli.ucla.edu/cdlisearch/search/ipadweb/showcase?date=%@\"> Visit this page on the web</a> <br /><br />"
                           "<a href=\"https://itunes.apple.com/us/app/cdli-tablet/id636437023?ls=1&mt=8\"> Download the free \"cdli tablet\" app </a>",
                           tabletItem[@"thumbnail-url"], tabletItem[@"blurb"], tabletItem[@"date"]];
    
    [picker setMessageBody:emailBody isHTML:YES];
    //picker.modalPresentationStyle = UIModalPresentationPageSheet;
    
    [self presentViewController:picker animated:YES completion:^{}];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
