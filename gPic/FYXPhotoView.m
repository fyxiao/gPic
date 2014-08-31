//
//  FYXImageView.m
//  gPic
//
//  Created by Frank Xiao on 8/9/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXPhotoView.h"

@implementation FYXPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    NSLog(@"Initialized a FYXPhotoView!");
    self = [super initWithImage:image];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
