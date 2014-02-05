//
//  PictureResultViewController.m
//  Autobooth
//
//  Created by Paul Kim on 2/3/14.
//  Copyright (c) 2014 Paul Kim. All rights reserved.
//

#import "PictureResultViewController.h"

@interface PictureResultViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *pictureScrollView;
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
    
    NSLog(@"the pic array %@ in picture result", self.picArray);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
