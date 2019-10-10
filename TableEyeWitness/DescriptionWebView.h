//
//  DescriptionWebView.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 2/27/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DescriptionWebView : UIWebView

//setting this to true will take longer time to get the right size
@property (nonatomic) BOOL shouldSizeAccurate;
@property (nonatomic) CGFloat maxHeight;

@end
