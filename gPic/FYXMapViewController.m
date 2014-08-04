//
//  FYXMapViewController.m
//  gPic
//
//  Created by Frank Xiao on 7/20/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation FYXMapViewController

- (void)viewDidLoad {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.3487
                                                            longitude:-74.6591
                                                                 zoom:17];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    self.view = _mapView;
    
    // Initialize photos.
    _photos = [[NSMutableArray alloc] init];
    
    // Create a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(40.3487, -74.6591);
    marker.title = @"Princeton";
    marker.snippet = @"NJ";
    marker.map = _mapView;
    marker.tappable = YES;
    
    // Set up session.
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    NSLog(@"Recognized a tap at %f latitude and %f longitude", latitude, longitude);
    
    [self fetchPhotos:coordinate];
    for (int i = 0; i < [_photos count]; i++) {
        NSDictionary *photoDict = _photos[i];
        NSDictionary *photoLocation = photoDict[@"location"];
        CLLocationDegrees photoLatitude = [photoLocation[@"latitude"] doubleValue];
        CLLocationDegrees photoLongitude = [photoLocation[@"longitude"] doubleValue];
        NSLog(@"Photo coordinates are (%f, %f)", photoLatitude, photoLongitude);
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(photoLatitude, photoLongitude);
        marker.map = _mapView;
        marker.snippet = photoDict[@"link"];
        NSDictionary *photos = photoDict[@"images"];
        NSDictionary *targetImage = photos[@"thumbnail"];
        marker.title = targetImage[@"url"];
        NSLog(@"%@", [NSString stringWithFormat:@"Got the standard resolution photo link at %@", marker.title]);
        marker.tappable = YES;
        
    }
}

- (void)fetchPhotos:(CLLocationCoordinate2D)coordinate
{
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    NSString *requestString = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/search?lat=%f&lng=%f&access_token=%@", latitude, longitude, self.instagramToken];
    //NSLog(@"%@", requestString);
    
    NSURL *requestURL = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:requestURL];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _photos = responseData[@"data"];
    }];
    [dataTask resume];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    NSURL *requestURL = [NSURL URLWithString:marker.title];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    NSLog(@"%@", [NSString stringWithFormat:@"Finished downloading photo from %@", requestURL]);
    NSLog(@"%@", [NSString stringWithFormat:@"Link is %@", marker.snippet]);
    return view;
}

@end
