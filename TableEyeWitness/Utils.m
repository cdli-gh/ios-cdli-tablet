//
//  Utils.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSArray *) fetchTabletItemsAtURL: (NSString *)url
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *tabletItems = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    for (NSMutableDictionary *item in tabletItems) {
        item[@"full-info"] = [item[@"full-info"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        item[@"blurb"] = [item[@"blurb"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    //NSLog(@"Got feed: %@", tabletItems);
    return tabletItems;
}

@end
