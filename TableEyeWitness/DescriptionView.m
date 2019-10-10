//
//  DescriptionView.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

//This only exists to override intrinsicContentSize

#import "DescriptionView.h"

@implementation DescriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) invalidateIntrinsicContentSize
{
    [super invalidateIntrinsicContentSize];
    [self.descriptionField invalidateIntrinsicContentSize];
    [self.infoButton invalidateIntrinsicContentSize];
}

//- (CGSize) intrinsicContentSize
//{
//    CGSize actualSize = [super intrinsicContentSize];
//    if (actualSize.height >= 600) {
//        actualSize.height = 600;
//    }
//    
//    NSLog(@"Returning intrinsic size: %@", NSStringFromCGSize(actualSize));
//    return actualSize;
//}

@end
