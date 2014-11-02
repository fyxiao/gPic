//
//  FYXThumbnailsTableViewController.h
//  gPic
//
//  Created by Frank Xiao on 10/25/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FYXPreviewSelectDelegate;

@interface FYXThumbnailsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *thumbnailPhotos;
@property (nonatomic, strong) NSMutableArray *captions;
@property (nonatomic, weak) id<FYXPreviewSelectDelegate> delegate;

@end

// Protocol so the FYXMapViewController knows the user selected a thumbnail
@protocol FYXPreviewSelectDelegate <NSObject>

- (void)previewController:(FYXThumbnailsTableViewController *)previewController selectedRow:(NSIndexPath *)indexPath;

@end
