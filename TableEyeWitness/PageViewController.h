//
//  EWDataViewController.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POPAnimation.h"

@interface PageViewController : UIViewController <UIScrollViewDelegate, UIWebViewDelegate, POPAnimationDelegate>
- (IBAction) infoButtonTapped: (id) sender;

@property (strong, nonatomic) id dataObject;
@property (nonatomic) NSUInteger dataIndex;
@property (strong, nonatomic) NSString *baseURL;

@end
