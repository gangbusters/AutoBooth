//
//  AutoBoothCameraViewController.m
//  Autobooth
//
//  Created by Paul Kim on 1/20/14.
//  Copyright (c) 2014 Paul Kim. All rights reserved.
//

#import "AutoBoothCameraViewController.h"
#import "PictureResultViewController.h"
#import "AutoBoothAppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AutoBoothCameraViewController ()
@property (strong, nonatomic) UIImagePickerController *camera;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *picsArray;
@property (assign, nonatomic) int numPics;
@property (assign, nonatomic) int timerCount;
@end

@implementation AutoBoothCameraViewController


-(int) timerCount { //getter with for timer count
    if (_timerCount <= 0) {
        self.timerLabel.alpha = 0;
    }
    else{
        self.timerLabel.alpha = 1;
        self.timerLabel.text = [NSString stringWithFormat:@"%d", _timerCount];
    }
    return _timerCount;
}

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
    self.timerCount = 5;
    self.numPics = 0;
    self.picsArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsTakingPicture:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
   
    self.camera = [[UIImagePickerController alloc] init];
    self.camera.delegate = self;
    self.camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.camera.showsCameraControls = NO;
    self.camera.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float cameraAspectRatio = 4.0 / 3.0;
    float imageWidth = floorf(screenSize.width * cameraAspectRatio);
    float scale = ceilf((screenSize.height / imageWidth) * 12.5) / 10.0;
    self.camera.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
    
    [self.view addSubview:self.camera.view];
    
    [self.view bringSubviewToFront:self.timerLabel];

}

#pragma mark - Camera Actions
-(void) takePic{
    if (self.numPics > 2) {
        [self.timer invalidate];
        [self dismissViewControllerAnimated:YES completion:^{}];
        return;
    }
    if ( self.timerCount == 0)
        [self.camera takePicture];
    
    self.timerCount--;
}

-(void) cameraIsTakingPicture:(NSNotification *) notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(takePic) userInfo:nil repeats:YES];
        [self.timer fire];
    });
}

#pragma mark - UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.timerCount = 5;
    self.numPics++;
    
    [self.timer fire];
    
    UIImage *currentImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.picsArray addObject:currentImage];
    
    if (self.numPics > 2) {
        [self.delegate providePicturesArray:self.picsArray];
    }
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
