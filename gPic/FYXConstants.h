//
//  FYXConstants.h
//  gPic
//
//  Created by Frank Xiao on 7/27/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#ifndef gPic_Constants_h
#define gPic_Constants_h

// Google Maps API Key
static NSString *const GMS_API_KEY = @"<GMS_API_KEY_HERE>";

// All Instagram related constants.
static NSString *const INSTAGRAM_CLIENT_ID = @"<CLIENT_ID_HERE>";
static NSString *const INSTAGRAM_CLIENT_SECRET = @"<CLIENT_SECRET_HERE>";
static NSString *const INSTAGRAM_AUTH_BASE_URI = @"https://instagram.com/oauth/authorize/?client_id=%@&display=touch&%@&redirect_uri=%@&response_type=token";
static NSString *const INSTAGRAM_SCOPE = @"comments+relationships+likes";
static NSString *const INSTAGRAM_TOKEN = @"access_token";
static NSString *const INSTAGRAM_REDIRECT_URI = @"http://www.instagram.com";

// Thumbnail view width
static double const THUMBNAILS_VIEW_PROPORTION = 0.15;

#endif
