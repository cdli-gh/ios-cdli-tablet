//
//  Utils.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/29/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "Utils.h"
#import "OHURLLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSArray *colorMap = nil;

@implementation Utils

+ (void) initialize
{
    colorMap = @[[UIColor whiteColor], [UIColor orangeColor], [UIColor lightGrayColor], [UIColor cyanColor], [UIColor purpleColor], [UIColor redColor], [UIColor greenColor], [UIColor magentaColor]];
}

+ (NSArray *) fetchTabletItemsAtURL: (NSString *)url
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSArray *tabletItems = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    //NSLog(@"Tablet items: %@", tabletItems);
    
    for (NSMutableDictionary *item in tabletItems) {
        item[@"full-info"] = [item[@"full-info"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        item[@"blurb"] = [item[@"blurb"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    }
    //NSLog(@"Got feed: %@", tabletItems);
    return tabletItems;
}

+ (NSString *) cachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return cachePath;
}

+ (NSString *) JSONCachedPath
{
    return [[Utils cachePath] stringByAppendingPathComponent:@"cached.json"];
}

+ (void) cacheJSON: (NSData *) json
{
    NSString *filePath =  [Utils JSONCachedPath];
    [json writeToFile:filePath atomically:YES];
}

+ (NSData *) loadCachedJSON
{
    NSString *filePath = [Utils JSONCachedPath];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:nil error:&error];
    if(error != nil)
        return nil;
    
    return data;
}

+ (void) assignColors: (NSArray *) entries
{
    NSMutableDictionary *distinctThemes = [[NSMutableDictionary alloc] init];
    for (NSMutableDictionary *item in entries) {
        NSString *theme = item[@"theme"];
        if(distinctThemes[theme] == nil)
            distinctThemes[theme] = @(1);
        else
            distinctThemes[theme] = [NSNumber numberWithInt:[distinctThemes[theme] intValue] + 1];
    }
    
    
    NSArray *keys = [distinctThemes allKeys];
    
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [distinctThemes objectForKey:a];
        NSString *second = [distinctThemes objectForKey:b];
        //sort descending
        return -1 * [first compare:second];
    }];
    
    NSMutableDictionary *themeColor = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [sortedKeys count] && i < [colorMap count]; i++) {
        themeColor[sortedKeys[i]] = colorMap[i];
    }
    
    //if we have fewer distinct colors than we have themes, we use the default color assigned to them i.e. lightGrey
    
    for (NSMutableDictionary *item in entries) {
        if(themeColor[item[@"theme"]] != nil)
            item[@"color"] = themeColor[item[@"theme"]];
    }
}

+ (NSArray *) loadJSONData: (NSData *)JSONData
{
    NSError *error = nil;
    NSArray *tabletItems = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&error];
    
    //NSLog(@"Tablet items: %@", tabletItems);
    
    for (NSMutableDictionary *item in tabletItems) {
        item[@"full-info"] = [item[@"full-info"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        item[@"blurb"] = [item[@"blurb"] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        item[@"color"] = [UIColor lightGrayColor];
    }
    
    [Utils assignColors:tabletItems];
    
    return tabletItems;
}


+ (void) refreshDataAtURL: (NSString *)feedURL withHandler:(id<FetchedEntries>)refreshHandler
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:feedURL]];
    
    OHURLLoader* loader = [OHURLLoader URLLoaderWithRequest:request];
	[loader startRequestWithCompletion:^(NSData* receivedData, NSInteger httpStatusCode) {
		NSLog(@"Refreshed");
        NSArray *tabletItems = [Utils loadJSONData:receivedData];
        [Utils cacheJSON:receivedData];
        [refreshHandler fetchedEntries:tabletItems];
        
	} errorHandler:^(NSError* error) {
		NSLog(@"Could not referesh data!!! %@", error);
        if([refreshHandler respondsToSelector:@selector(fetchedEntriesFailedWithError:)]) {
            [refreshHandler fetchedEntriesFailedWithError:error];
        }
	}];
}

+ (void) downloadImageAtURL: (NSString *)imageURL
{
    //NSLog(@"Downloading: %@", imageURL);
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:imageURL]
                     options:0
                    progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
     }];
}

@end
