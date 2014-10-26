//
//  FYXPhotoView.h
//  gPic
//
//  Created by Frank Xiao on 8/9/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYXPhotoView : UIImageView

@property (strong, nonatomic) UILabel *link;
@property (strong, nonatomic) UILabel *caption;

- (id)initWithImage:(UIImage *)image link:(NSString *)link caption:(NSString *)caption;

@end
