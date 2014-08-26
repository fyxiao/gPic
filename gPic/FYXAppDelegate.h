//
//  FYXAppDelegate.h
//  gPic
//
//  Created by Frank Xiao on 7/20/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYXAuthViewController.h"
#import "FYXMapViewController.h"

@interface FYXAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FYXAuthViewController *avc;
@property (strong, nonatomic) FYXMapViewController *mvc;

@end
