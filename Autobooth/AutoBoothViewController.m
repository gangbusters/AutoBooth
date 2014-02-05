//
//  AutoBoothViewController.m
//  Autobooth
//
//  Created by Paul Kim on 1/17/14.
//  Copyright (c) 2014 Paul Kim. All rights reserved.
//

#import "AutoBoothViewController.h"
#import "PictureResultViewController.h"

@interface AutoBoothViewController ()
@property (nonatomic, assign) BOOL didPressCameraButton;
@property (strong, nonatomic) NSArray *finalPicArray;
@end

@implementation AutoBoothViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.didPressCameraButton) {
        [self performSegueWithIdentifier:@"presentPictureResult" sender:self];
    }
}
- (IBAction)didPushCameraButton:(id)sender {
    self.didPressCameraButton = YES;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"pushCamera"]) {
        AutoBoothCameraViewController *cameraViewController = ((AutoBoothCameraViewController *)[segue destinationViewController]);
        cameraViewController.delegate = self;
    }
    if ([[segue identifier] isEqualToString:@"presentPictureResult"]) {
        PictureResultViewController *cameraViewController = ((PictureResultViewController *)[segue destinationViewController]);
        cameraViewController.picArray = self.finalPicArray;
    
    }
    
}

-(void) providePicturesArray:(NSArray *)picArray{
    self.finalPicArray = picArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
