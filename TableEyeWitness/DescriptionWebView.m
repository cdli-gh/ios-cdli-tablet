//
//  DescriptionWebView.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 2/27/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "DescriptionWebView.h"

@implementation DescriptionWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.shouldSizeAccurate = false;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.shouldSizeAccurate = false;
    }
    return self;
}

- (CGSize) intrinsicContentSize
{
    CGSize size;
    //NSLog(@"Intrinsic height: %f for text: %@, length: %d", self.contentSize.height, self.text, self.text.length);
    //NSLog(@"Frame height: %f", self.frame.size.height);
    
//        CGSize contentSize = CGSizeMake(
//                                        [[self stringByEvaluatingJavaScriptFromString:@"document.body.scrollWidth;"] floatValue],
//                                        [[self stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"] floatValue]);
    
//    CGSize contentSize = CGSizeMake(self.scrollView.contentSize.width,
//                                    [[self stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"] integerValue] + 10);

    //+10 is a hack, otherwise the bottom line gets chipped off

    CGSize contentSize;

//    float oldFrameHeight = self.frame.size.height;
//    CGRect frame = self.frame;
//    frame.size.height = 1;
//    contentSize = [self sizeThatFits:CGSizeZero];
//    frame.size.height = oldFrameHeight;
//    self.frame = frame;    

    if(!self.shouldSizeAccurate) {
        //contentSize = self.scrollView.contentSize;
        //hack because scrollView's contentSize is a bigger than what the required size 
        contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height - 10);
    }
    else
        contentSize = CGSizeMake(self.scrollView.contentSize.width,
                                [[self stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"] integerValue] + 10);
    
    
    size.width = contentSize.width;
    size.height = contentSize.height;
    
    //NSLog(@"Intrinsic height: %f, widght: %f", contentSize.height, contentSize.width);

    return size;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
}

- (void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self invalidateIntrinsicContentSize];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self invalidateIntrinsicContentSize];
}

@end
