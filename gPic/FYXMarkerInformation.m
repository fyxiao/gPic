//
//  FYXMarkerInformation.m
//  gPic
//
//  Created by Frank Xiao on 8/29/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXMarkerInformation.h"

@implementation FYXMarkerInformation

- (instancetype)initWithLink:(NSString *)link thumbnailURL:(NSString *)thumbnail standardURL:(NSString *)standard caption:(NSString *)caption
{
    self.link = link;
    self.thumbnailURL = thumbnail;
    self.standardURL = standard;
    self.caption = caption;
    
    return self;
}

@end
