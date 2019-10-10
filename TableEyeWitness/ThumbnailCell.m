//
//  ThumbnailCell.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "ThumbnailCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ThumbnailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//http://www.omnigroup.com/blog/entry/ipad_drop_shadow_performance_test
//- (void)willMoveToWindow:(UIWindow *)newWindow;
//{
//    [super willMoveToWindow:newWindow];
//    
//    if (newWindow) {
//        self.layer.shouldRasterize =  YES;
//        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    }
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
