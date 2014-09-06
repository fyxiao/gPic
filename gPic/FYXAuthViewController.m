//
//  FYXInstagramAuthenticatorViewController.m
//  gPic
//
//  Created by Frank Xiao on 7/27/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "Constants.h"
#import "FYXAppDelegate.h"
#import "FYXAuthViewController.h"

@interface FYXAuthViewController () <UIWebViewDelegate>

@end

@implementation FYXAuthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        FYXAuthView *authView = [[FYXAuthView alloc] init];
        authView.delegate = self;
        self.view = authView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
    NSRange tokenLoc = [urlString rangeOfString:INSTAGRAM_TOKEN];
    if (tokenLoc.location != NSNotFound) {
        NSString *instagramToken = [urlString substringFromIndex:(tokenLoc.location + tokenLoc.length + 1)];
        NSLog(@"%@", instagramToken);
        FYXAppDelegate *appDelegate = (FYXAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.mvc.instagramToken = instagramToken;
        
        [appDelegate.mvc setDefaultMapView];
        
        [self presentViewController:appDelegate.mvc animated:YES completion:^{ }];
    }
	return YES;
}


@end
