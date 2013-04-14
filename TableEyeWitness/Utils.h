//
//  Utils.h
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FetchedEntries <NSObject>

- (void) fetchedEntries:(NSArray *) entries;

@optional
- (void) fetchedEntriesFailedWithError:(NSError *) error;

@end

@interface Utils : NSObject

+ (NSData *) loadCachedJSON;
+ (void) cacheJSON: (NSData *) json;
+ (NSArray *) loadJSONData: (NSData *)JSONData;
+ (void) refreshDataAtURL: (NSString *)feedURL withHandler:(id<FetchedEntries>)refreshHandler;
+ (void) downloadImageAtURL: (NSString *)imageURL;

@end
