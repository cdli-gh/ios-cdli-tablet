//
//  AboutPageController.m
//  cdli tablet
//
//  Created by Sai Deep Tetali on 3/25/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "AboutPageController.h"

@interface AboutPageController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *aboutPage;

@end

@implementation AboutPageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    //toggle nav bar when the imageview is tapped
    self.aboutPage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNavigationBar:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.aboutPage addGestureRecognizer:tapGestureRecognizer];

    self.aboutPage.delegate = self;
    
    //load about page
    
    NSURL *url;
    
    if([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"IsInternalBuild"] boolValue])
        url = [NSURL URLWithString:@"http://www.cdli.ucla.edu/cdlitablet/about/about.html"];
    else
        url = [NSURL URLWithString:@"http://www.cdli.ucla.edu/cdlitablet/about/about.html"];
        
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [self.aboutPage loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) toggleNavigationBar:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        BOOL finalNavbarHidden = !self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:finalNavbarHidden animated:YES];
    }
}

#pragma mark - WebView delegate
-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

@end
