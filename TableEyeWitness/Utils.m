//
//  Utils.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSArray *) fetchTabletItems
{
    NSString *url = @"http://cs.ucla.edu/~saideep/cldiwitness/info.json";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *tabletItems = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    //NSLog(@"Got feed: %@", tabletItems);
    return tabletItems;
}

@end
