//
//  FYXMarkerInformation.h
//  gPic
//
//  Created by Frank Xiao on 8/29/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYXMarkerInformation : NSObject

@property NSString *link;
@property NSString *thumbnailURL;
@property NSString *standardURL;
@property NSString *caption;

- (instancetype)initWithLink:(NSString *)link
                thumbnailURL:(NSString *)thumbnail
                 standardURL:(NSString *)standard
                     caption:(NSString *)caption;
@end
