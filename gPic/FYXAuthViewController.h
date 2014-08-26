//
//  FYXInstagramAuthenticatorViewController.h
//  gPic
//
//  Created by Frank Xiao on 7/27/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXAuthView.h"
#import "FYXMapViewController.h"
#import <UIKit/UIKit.h>

@interface FYXAuthViewController : UIViewController

@property (nonatomic, strong) FYXAuthView *authView;
@property (nonatomic, copy) NSString *instagramToken;

@end
