//
//  FYXPhotoViewController.h
//  gPic
//
//  Created by Frank Xiao on 8/10/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYXPhotoViewController : UIViewController

@property (nonatomic, strong) NSString *photoPath;

- (id)initWithPhotoPath:(NSString *)path;

- (id)initWithPhotoPath:(NSString *)path linkURL:(NSString *)linkURL captionText:(NSString *)captionText;

@end
