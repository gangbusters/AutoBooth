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
@property (weak, nonatomic) IBOutlet UIView *menuView;

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
    CGRect myFrame = self.view.frame;
    self.pictureScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height * [self.picArray count]);
    self.pictureScrollView.scrollEnabled = YES;
    self.pictureScrollView.pagingEnabled = YES;
    self.pictureScrollView.bounces = NO;
    for (UIImage *image in self.picArray) {
        UIImageView *picImageView = [[UIImageView alloc] initWithImage:image];
        CGFloat frameMultiple = self.view.frame.size.width/image.size.width;
        picImageView.frame = CGRectMake(0, 0, image.size.width *frameMultiple, image.size.height * frameMultiple);
        picImageView.center = CGPointMake(picImageView.center.x, self.view.frame.size.height/2);
        
        UIView *imageViewBaseView = [[UIView alloc] initWithFrame:myFrame];
        imageViewBaseView.backgroundColor = [UIColor blackColor];
        [imageViewBaseView addSubview:picImageView];
        [self.pictureScrollView addSubview:imageViewBaseView];
        myFrame.origin.y += myFrame.size.height;
    }
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu:)];
    [swipeRight setDirection: UISwipeGestureRecognizerDirectionRight];
    self.pictureScrollView.userInteractionEnabled = YES;
    [self.pictureScrollView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
    [swipeRight setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.pictureScrollView addGestureRecognizer:swipeLeft];
    
}

#pragma mark - Menu Buttons
- (IBAction)separatePIcturesButton:(id)sender {
    NSLog(@"separate pictures");
}

- (IBAction)singlePictureButton:(id)sender {
    NSLog(@"single picture");
    
    
}
- (IBAction)videoButton:(id)sender {
    
}

- (IBAction)shareButton:(id)sender {

    
    
}



#pragma mark - Gesture Recognizer Selector
-(void) hideMenu:(UISwipeGestureRecognizer *) swipe{
    
    if (self.menuView.frame.origin.x == self.view.frame.size.width) {
        CGRect menuFrame = self.menuView.frame;
        menuFrame.origin.x -= 80;
        [UIView animateWithDuration:0.5 animations:^{self.menuView.frame = menuFrame;}];
    }
}

-(void) showMenu:(UISwipeGestureRecognizer *) swipe{
    if (self.menuView.frame.origin.x < self.view.frame.size.width) {
        CGRect menuFrame = self.menuView.frame;
        menuFrame.origin.x = self.view.frame.size.width;
        [UIView animateWithDuration:0.5 animations:^{self.menuView.frame = menuFrame;}];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
