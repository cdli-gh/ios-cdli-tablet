//
//  EWDataViewController.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController <UIScrollViewDelegate, UIWebViewDelegate>
- (IBAction) infoButtonTapped: (id) sender;

@property (strong, nonatomic) id dataObject;
@property (nonatomic) int dataIndex;
@property (strong, nonatomic) NSString *baseURL;

@end
