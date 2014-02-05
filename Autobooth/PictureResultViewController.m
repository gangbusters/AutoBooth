//
//  PictureResultViewController.m
//  Autobooth
//
//  Created by Paul Kim on 2/3/14.
//  Copyright (c) 2014 Paul Kim. All rights reserved.
//

#import "PictureResultViewController.h"

@interface PictureResultViewController ()
@property (strong, nonatomic)  UIScrollView *pictureScrollView;
@end

@implementation PictureResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    

    
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"the pic array %@ in picture result", self.picArray);
    CGRect myFrame = self.view.frame;
    myFrame.size.height = myFrame.size.width *4/3;
    self.pictureScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.pictureScrollView];
    self.pictureScrollView.contentSize = CGSizeMake(myFrame.size.width, myFrame.size.height * [self.picArray count]);
    NSLog(@"picture scroll contentsize %f", self.pictureScrollView.contentSize.height);
    self.pictureScrollView.scrollEnabled = YES;
    for (UIImage *image in self.picArray) {
        UIImageView *picImageView = [[UIImageView alloc] initWithImage:image];
        picImageView.frame = myFrame;
        NSLog(@"scrollview height %f", myFrame.origin.y);

        [self.pictureScrollView addSubview:picImageView];
        
        myFrame.origin.y += myFrame.size.height;
        
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
