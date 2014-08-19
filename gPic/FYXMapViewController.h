//
//  FYXMapViewController.h
//  gPic
//
//  Created by Frank Xiao on 7/20/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface FYXMapViewController : UIViewController <GMSMapViewDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSString *instagramToken;

/*
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSString *instagramToken;
*/

@end
