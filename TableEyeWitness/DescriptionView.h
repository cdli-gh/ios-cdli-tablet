//
//  DescriptionView.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DescriptionWebView.h"

@interface DescriptionView : UIView

@property (strong, nonatomic) IBOutlet DescriptionWebView *descriptionField;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

@end
