//
//  FYXInstagramAuthenticatorView.m
//  gPic
//
//  Created by Frank Xiao on 7/27/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXAuthView.h"
#import "Constants.h"

@implementation FYXAuthView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self authorize];
    }
    return self;
}

- (void)authorize
{
    NSString *url = [NSString stringWithFormat:INSTAGRAM_AUTH_BASE_URI, INSTAGRAM_CLIENT_ID, INSTAGRAM_SCOPE, INSTAGRAM_REDIRECT_URI];
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

@end
