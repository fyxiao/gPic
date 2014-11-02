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
@property (nonatomic, strong) UITableView *thumbnailsView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbnailPhotos;
@property (nonatomic, strong) NSMutableArray *markers;
@property (nonatomic, strong) NSMutableArray *captions;
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
    [self setDefaultMapView];
}

- (void)setDefaultMapView
{
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
    
    // Initialize arrays to hold photo information.
    _photos = [[NSMutableArray alloc] init];
    self.ttvc.thumbnailPhotos = [[NSMutableArray alloc] init];
    _markers = [[NSMutableArray alloc] init];
    
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
    // hide the preview controller
    [self hideContentController:self.ttvc];
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
    
    appDelegate.avc = [appDelegate.avc init];
    
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
            [self.ttvc.thumbnailPhotos removeAllObjects];
            [self.ttvc.captions removeAllObjects];
            [_markers removeAllObjects];
            
            for (int i = 0; i < [_photos count]; i++) {
                NSDictionary *photoDict = _photos[i];
                NSDictionary *photoLocation = photoDict[@"location"];
                CLLocationDegrees photoLatitude = [photoLocation[@"latitude"] doubleValue];
                CLLocationDegrees photoLongitude = [photoLocation[@"longitude"] doubleValue];
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(photoLatitude, photoLongitude);
                marker.map = _mapView;

                NSDictionary *photos = photoDict[@"images"];
                // Different photo options.
                NSDictionary *targetImageThumb = photos[@"thumbnail"];
                NSDictionary *targetImageStd = photos[@"standard_resolution"];
                
                // Get the caption.
                NSDictionary *caption = photoDict[@"caption"];
                NSString *captionToDisplay = ([caption isKindOfClass:[NSNull class]]) ? @"No caption found." : caption[@"text"];
                
                marker.tappable = YES;
                marker.userData = [[FYXMarkerInformation alloc] initWithLink:photoDict[@"link"] thumbnailURL:targetImageThumb[@"url"] standardURL:targetImageStd[@"url"] caption:captionToDisplay
                                                                         lat:photoLatitude lon:photoLongitude];
                
                [_markers addObject:marker];
                
                // Save photos for use in the preview.
                NSURL *requestURL = [NSURL URLWithString:targetImageThumb[@"url"]];
                [self.ttvc.thumbnailPhotos addObject: [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]]];
                [self.ttvc.captions addObject:captionToDisplay];
            }
            
            // Present the controller for the thumbnails view
            
            // Set up the preview controller
            [self addChildViewController:self.ttvc];
            [self displayContentController:self.ttvc];
            [self.ttvc.tableView reloadData];
            self.ttvc.delegate = self;
            
            [self displayThumbnails];
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
    
    // Display the preview controller
    [self displayContentController:self.ttvc];
    [self.ttvc.tableView reloadData];
    self.ttvc.delegate = self;
    
    return view;
}

// Return a view of the full image when the user taps the small thumbnail view.
- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    //NSLog(@"User tapped a thumbnail view!");
    FYXMarkerInformation *markerInfo = (FYXMarkerInformation *)marker.userData;
    //FYXPhotoViewController *pvc = [[FYXPhotoViewController alloc] initWithPhotoPath:markerInfo.standardURL];
    FYXPhotoViewController *pvc = [[FYXPhotoViewController alloc] initWithPhotoPath:markerInfo.standardURL linkURL:markerInfo.link captionText:markerInfo.caption];
    
    pvc.photoPath = markerInfo.standardURL;
    [self presentViewController:pvc animated:NO completion:NULL];
}

- (void)displayThumbnails
{
    FYXAppDelegate *appDelegate = (FYXAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect thumbFrame = appDelegate.window.frame;
    thumbFrame.origin.x += (0.75) * thumbFrame.size.width;
    thumbFrame.size.width *= 0.25;
    
    [self.view addSubview:self.thumbnailsView];
}

- (void) displayContentController:(UIViewController *)content
{
    [self addChildViewController:content];
    FYXAppDelegate *appDelegate = (FYXAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect thumbFrame = appDelegate.window.frame;
    thumbFrame.origin.x += (0.75) * thumbFrame.size.width;
    thumbFrame.size.width *= 0.25;
    
    content.view.frame = thumbFrame;
    
    [self.view addSubview:self.ttvc.view];
    [content didMoveToParentViewController:self];
}

- (void) hideContentController:(UIViewController *)content
{
    [content willMoveToParentViewController:nil];  // 1
    [content.view removeFromSuperview];            // 2
    [content removeFromParentViewController];      // 3
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //NSLog(@"Returning %lu captions!", (unsigned long)[self.captions count]);
    return [self.captions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    cell.textLabel.text = @"test";
    cell.textLabel.text = [self.captions objectAtIndex:indexPath.row];
    return cell;
}

- (void)previewController:(FYXThumbnailsTableViewController *)previewController selectedRow:(NSIndexPath *)indexPath
{
    FYXMarkerInformation *marker = ((GMSMarker *)[_markers objectAtIndex:indexPath.row]).userData;
    GMSCameraPosition *photoPosition = [GMSCameraPosition cameraWithLatitude:marker.latitude longitude:marker.longitude zoom:17];
    //NSLog(@"Moving camera to latitude %f and longitude %f, the caption is %@!", marker.latitude, marker.longitude, marker.caption);
    [_mapView setCamera:photoPosition];
    [_mapView setSelectedMarker:[_markers objectAtIndex:indexPath.row]];
}

@end
