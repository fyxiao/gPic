//
//  FYXMapViewController.h
//  gPic
//
//  Created by Frank Xiao on 7/20/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "FYXThumbnailsTableViewController.h"

@interface FYXMapViewController : UITableViewController <GMSMapViewDelegate, NSURLSessionDataDelegate, FYXPreviewSelectDelegate>

@property (nonatomic, strong) NSString *instagramToken;
@property (nonatomic, strong) FYXThumbnailsTableViewController *ttvc;

- (void)setDefaultMapView;

@end
