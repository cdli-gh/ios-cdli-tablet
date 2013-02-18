//
//  DescriptionField.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 2/6/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "DescriptionField.h"

@implementation DescriptionField

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

- (CGSize) intrinsicContentSize
{
    CGSize size;
    if(self.frame.size.height <= 0) {
        //NSLog(@"Not giving any intrinsicContentSize");
        size.width = UIViewNoIntrinsicMetric;
        size.height = UIViewNoIntrinsicMetric;
    }
    else {
        //NSLog(@"Intrinsic height: %f for text: %@, length: %d", self.contentSize.height, self.text, self.text.length);
        //NSLog(@"Frame height: %f", self.frame.size.height);
        size.width = self.contentSize.width;
        size.height = self.contentSize.height;
    }
    return size;
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self invalidateIntrinsicContentSize];
}

- (void) setText:(NSString *)text
{
    [super setText:text];
    [self invalidateIntrinsicContentSize];
}

@end
