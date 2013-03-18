//
//  ThumbnailController.m
//  TabletEyeWitness
//
//  Created by Sai Deep Tetali on 1/26/13.
//  Copyright (c) 2013 Sai Deep Tetali. All rights reserved.
//

#import "ThumbnailController.h"
#import "EWRootViewController.h"
#import "EWAppDelegate.h"
#import "ThumbnailCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"

@interface ThumbnailController () <FetchedEntries>

@end

@implementation ThumbnailController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    EWAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.refreshResponder = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    EWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.tabletItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ThumbnailCell" forIndexPath:indexPath];
    
    EWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *imageNameToLoad = @"loading"; //[NSString stringWithFormat:@"%d_full", index%32];
    NSString *pathToImage = [[NSBundle mainBundle] pathForResource:imageNameToLoad ofType:@"gif"];
    UIImage *placeholderImage = [[UIImage alloc] initWithContentsOfFile:pathToImage];
    
    NSDictionary *tabletItem = appDelegate.tabletItems[indexPath.row];
    //NSLog(@"Thumnail: Trying to fetch %@", urlString);
    
    cell.layer.cornerRadius = 5;
    cell.layer.borderWidth = 3.5;
    cell.layer.borderColor = CGColorRetain([[UIColor darkGrayColor] CGColor]);
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:tabletItem[@"thumbnail-url"]] placeholderImage:placeholderImage];
    
    
    return cell;
}

// the user tapped a collection item, load and set the image on the detail view controller
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowDetail"])
    {
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        EWRootViewController *rootViewController = [segue destinationViewController];
        rootViewController.startIndex = selectedIndexPath.row;
    }
}

#pragma mark - FetchedEntries delegate

- (void)fetchedEntries:(NSArray *)entries
{
    //NSLog(@"Thumbnails refreshing");
    [[self collectionView] reloadData];
}
@end
