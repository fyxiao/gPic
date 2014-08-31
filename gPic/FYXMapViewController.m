//
//  FYXMapViewController.m
//  gPic
//
//  Created by Frank Xiao on 7/20/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXAppDelegate.h"
#import "FYXAuthViewController.h"
#import "FYXMapViewController.h"
#import "FYXMarkerInformation.h"
#import "FYXPhotoView.h"
#import "FYXPhotoViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface FYXMapViewController ()

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic) CGRect menuRect;
@property (nonatomic) UIButton *button;

@end

@implementation FYXMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_button addTarget:self action:@selector(logoutFromApp) forControlEvents:UIControlEventTouchUpInside];
    [_button setTitle:@"Logout of gPic" forState:UIControlStateNormal];
    [_button setBackgroundColor:[UIColor whiteColor]];
    
    return self;
}

- (void)viewDidLoad {
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.3487
                                                            longitude:-74.6591
                                                                 zoom:17];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    
    // Create rectangle on the bottom of the map view to detect user taps that will bring up the menu.
    FYXAppDelegate *appDelegate = (FYXAppDelegate *)[[UIApplication sharedApplication] delegate];
    _menuRect = appDelegate.window.bounds;
    _menuRect.origin.y = _menuRect.size.height * 0.9;
    _menuRect.size.height *= 0.1;
    
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
    
}

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint tappedPoint = [mapView.projection pointForCoordinate:coordinate];
    if (CGRectContainsPoint(_menuRect, tappedPoint)) {
        _button.frame = _menuRect;
        [self.view addSubview:_button];
    } else { // hide
        [_button removeFromSuperview];
    }
}

- (void)logoutFromApp
{
    // clear the button
    [_button removeFromSuperview];
    
    FYXAppDelegate *appDelegate = (FYXAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mvc.instagramToken = @"";
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    appDelegate.avc = [[FYXAuthViewController alloc] init];
    
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    
    appDelegate.window.rootViewController = appDelegate.avc;
}


- (instancetype)init
{
    self = [super init];
    
    // Set up session.
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
    
    return self;
}


// Whenever the user long presses a location on the map, we'll get photos that were geotagged near that location.
- (void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // Clear the previous photos retrieved.
    [_mapView clear];
    
    [self fetchPhotos:coordinate];
}

// The method that actually fetches the photos.
- (void)fetchPhotos:(CLLocationCoordinate2D)coordinate
{
    CLLocationDegrees latitude = coordinate.latitude;
    CLLocationDegrees longitude = coordinate.longitude;
    NSString *requestString = [NSString stringWithFormat:@"https://api.instagram.com/v1/media/search?lat=%f&lng=%f&access_token=%@", latitude, longitude, self.instagramToken];
    //NSLog(@"%@", requestString);
    
    NSURL *requestURL = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:requestURL];
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //NSLog(@"Sending a query to %@", requestString);
            NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            _photos = responseData[@"data"];
            
            for (int i = 0; i < [_photos count]; i++) {
                NSDictionary *photoDict = _photos[i];
                NSDictionary *photoLocation = photoDict[@"location"];
                CLLocationDegrees photoLatitude = [photoLocation[@"latitude"] doubleValue];
                CLLocationDegrees photoLongitude = [photoLocation[@"longitude"] doubleValue];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(photoLatitude, photoLongitude);
                marker.map = _mapView;

                NSDictionary *photos = photoDict[@"images"];
                // different photo options
                NSDictionary *targetImageThumb = photos[@"thumbnail"];
                NSDictionary *targetImageStd = photos[@"standard_resolution"];
                
                // get the caption
                NSDictionary *caption = photoDict[@"caption"];
                NSString *captionToDisplay = ([caption isKindOfClass:[NSNull class]]) ? @"No caption found." : caption[@"text"];
                
                marker.tappable = YES;
                marker.userData = [[FYXMarkerInformation alloc] initWithLink:photoDict[@"link"] thumbnailURL:targetImageThumb[@"url"] standardURL:targetImageStd[@"url"] caption:captionToDisplay];
            }
        }];
    }];
    [dataTask resume];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    FYXMarkerInformation *markerInfo = (FYXMarkerInformation *)marker.userData;
    NSURL *requestURL = [NSURL URLWithString:markerInfo.thumbnailURL];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    //NSLog(@"%@", [NSString stringWithFormat:@"Finished downloading photo from %@", requestURL]);
    return view;
}

// Return a view of the full image when the user taps the small thumbnail view.
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //NSLog(@"User tapped a thumbnail view!");
    FYXMarkerInformation *markerInfo = (FYXMarkerInformation *)marker.userData;
    FYXPhotoViewController *pvc = [[FYXPhotoViewController alloc] initWithPhotoPath:markerInfo.standardURL];
    pvc.photoPath = markerInfo.standardURL;
    [self presentViewController:pvc animated:NO completion:NULL];
    
}

@end
