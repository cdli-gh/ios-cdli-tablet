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

@interface EWDataViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet DescriptionView *portraitDescriptionView;
@property (strong, nonatomic) IBOutlet DescriptionView *landscapeDescriptionView;
@property (strong, nonatomic) DescriptionView *descriptionView;
@end

@implementation EWDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.imageView.frame = self.view.bounds;
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationMaskPortraitUpsideDown) {
        [self changeTheViewToPortrait:YES andDuration:0];
    }
    else if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft)
    {
        [self changeTheViewToPortrait:NO andDuration:0];
    }
    //The simulator does not give a good value for this
    else {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            [self changeTheViewToPortrait:YES andDuration:0];
        }
        else {
            [self changeTheViewToPortrait:NO andDuration:0];
        }
    }    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleNavigationBar:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        BOOL finalNavbarState = !self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:finalNavbarState animated:YES];

        // NSLog(@"Got a tap");

    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
    
    NSString *imageNameToLoad = @"loading"; //[NSString stringWithFormat:@"%d_full", index%32];
    NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"gif"];
    //NSLog(@"Path to image: %@", pathToImage);
    UIImage *placeholderImage = [[UIImage alloc] initWithContentsOfFile:pathToImage];

    EWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *baseURL = appDelegate.baseURL;
    
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", baseURL, tabletItem[@"url"]];
    NSLog(@"BigPhoto: Trying to fetch %@", urlString);

    [self.imageView setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:placeholderImage];
    //NSLog(@"Now trying to set label of description");
    //self.descriptionView.label.text = tabletItem[@"blurb"];
    
}

- (void)setDescriptionViewTo:(DescriptionView *)target
{
    NSDictionary *tabletItem = (NSDictionary *)self.dataObject;
    target.label.text = tabletItem[@"blurb"];
    self.descriptionView = target;
//    NSLog(@"description view text: %@", self.descriptionView.label.text);
//    NSLog(@"target view text: %@", target.label.text);
}

#pragma mark - InterfaceOrientationMethods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        [self changeTheViewToPortrait:YES andDuration:duration];
    else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        [self changeTheViewToPortrait:NO andDuration:duration];
}

- (void)changeTheViewToPortrait:(BOOL)portrait andDuration:(NSTimeInterval)duration
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    
    if(portrait){
        self.portraitDescriptionView.hidden = NO;
        self.landscapeDescriptionView.hidden = YES;
        [self setDescriptionViewTo:self.portraitDescriptionView];
    }
    else{
        self.portraitDescriptionView.hidden = YES;
        self.landscapeDescriptionView.hidden = NO;
        [self setDescriptionViewTo:self.landscapeDescriptionView];
    }
    
    [UIView commitAnimations];
}
@end
