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
#import "FYXPhotoView.h"
#import "FYXPhotoViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface FYXMapViewController ()

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic) CGRect menuRect;

@end

@implementation FYXMapViewController

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
    _menuRect.origin.y = _menuRect.size.height * 0.85;
    _menuRect.size.height *= 0.15;
    
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
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(logoutFromApp) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Logout of gPic" forState:UIControlStateNormal];
        button.frame = _menuRect;
        [self.view addSubview:button];
    }
}

- (void)logoutFromApp
{
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
            NSLog(@"Sending a query to %@", requestString);
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
                marker.snippet = photoDict[@"link"];
                NSDictionary *photos = photoDict[@"images"];
                // different photo options
                NSDictionary *targetImageThumb = photos[@"thumbnail"];
                //NSDictionary *targetImage = photos[@"low_resolution"];
                NSDictionary *targetImageStd = photos[@"standard_resolution"];
                marker.title = targetImageThumb[@"url"];
                marker.snippet = targetImageStd[@"url"];
                marker.tappable = YES;
            }
        }];
    }];
    [dataTask resume];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    NSURL *requestURL = [NSURL URLWithString:marker.title];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
    UIImageView *view = [[UIImageView alloc] initWithImage:image];
    NSLog(@"%@", [NSString stringWithFormat:@"Finished downloading photo from %@", requestURL]);
    //NSLog(@"%@", [NSString stringWithFormat:@"Link is %@", marker.snippet]);
    return view;
}

// Return a view of the full image when the user taps the small thumbnail view.
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSLog(@"User tapped a thumbnail view!");
    //NSURL *requestURL = [NSURL URLWithString:marker.snippet];
    //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
    //UIImageView *view = [[UIImageView alloc] initWithImage:image];
    
    FYXPhotoViewController *pvc = [[FYXPhotoViewController alloc] initWithPhotoPath:marker.snippet];
    pvc.photoPath = marker.snippet;
    [self presentViewController:pvc animated:YES completion:NULL];
    
}

@end
