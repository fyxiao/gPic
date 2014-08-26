//
//  FYXPhotoViewController.m
//  gPic
//
//  Created by Frank Xiao on 8/10/14.
//  Copyright (c) 2014 Frank Xiao. All rights reserved.
//

#import "FYXPhotoView.h"
#import "FYXPhotoViewController.h"

@interface FYXPhotoViewController ()

@end

@implementation FYXPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPhotoPath:(NSString *)path
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        //NSLog(@"In the initWithPhotoPath for FYXPhotoViewController");
        // Custom initialization
        NSURL *requestURL = [NSURL URLWithString:path];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
        //UIImageView *view = [[UIImageView alloc] initWithImage:image];
        
        FYXPhotoView *photoView = [[FYXPhotoView alloc] initWithImage:image];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [photoView addGestureRecognizer:tapRecognizer];
        
        self.view = photoView;
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)gr
{
    //NSLog(@"Recognized a tap in a FYXPhotoViewController!");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
