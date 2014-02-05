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

#pragma mark - View Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect myFrame = self.view.frame;
    myFrame.size.height = myFrame.size.width *4/3;
    [self.view addSubview:self.pictureScrollView];
    self.pictureScrollView.contentSize = CGSizeMake(myFrame.size.width, myFrame.size.height * [self.picArray count]);
    self.pictureScrollView.scrollEnabled = YES;
    for (UIImage *image in self.picArray) {
        UIImageView *picImageView = [[UIImageView alloc] initWithImage:image];
        picImageView.frame = myFrame;
        [self.pictureScrollView addSubview:picImageView];
        myFrame.origin.y += myFrame.size.height;
    }
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnToMenu:)];
    self.pictureScrollView.userInteractionEnabled = YES;
    [self.pictureScrollView addGestureRecognizer:swipe];
    
}

#pragma mark - Swipe Recognizer Selector
-(void) returnToMenu:(UISwipeGestureRecognizer *) swipe{
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
