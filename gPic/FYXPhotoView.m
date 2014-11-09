//
//  FYXImageView.m
//  gPic
//
//  Created by Frank Xiao on 8/9/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXAppDelegate.h"
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
    self = [super initWithImage:image];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    
    return self;
}

- (id)initWithImage:(UIImage *)image link:(NSString *)linkURL caption:(NSString *)captionText
{
    self = [super initWithImage:image];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor blackColor];
    
    // Display the link to the post above the image.
    FYXAppDelegate *appDelegate = (FYXAppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect linkFrame = appDelegate.window.bounds;
    linkFrame.origin.y = 0;
    linkFrame.size.height *= 0.1;
    _link = [[UILabel alloc] initWithFrame:linkFrame];
    _link.text = linkURL;
    _link.textColor = [UIColor whiteColor];
    _link.adjustsFontSizeToFitWidth = YES;
    _link.numberOfLines = 0;
    [self addSubview:_link];
    
    // Display the image caption.
    CGRect captionFrame = appDelegate.window.bounds;
    captionFrame.origin.y = captionFrame.size.height * 0.8;
    captionFrame.size.height *= 0.2;
    _caption = [[UILabel alloc] initWithFrame:captionFrame];
    _caption.text = captionText;
    _caption.textColor = [UIColor whiteColor];
    _caption.adjustsFontSizeToFitWidth = YES;
    _caption.numberOfLines = 0;
    [self addSubview:_caption];
    
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
