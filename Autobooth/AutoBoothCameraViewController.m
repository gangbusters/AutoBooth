//
//  AutoBoothCameraViewController.m
//  Autobooth
//
//  Created by Paul Kim on 1/20/14.
//  Copyright (c) 2014 Paul Kim. All rights reserved.
//

#import "AutoBoothCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AutoBoothCameraViewController ()
@property (strong, nonatomic) UIImagePickerController *camera;
@property (weak, nonatomic) IBOutlet UIButton *takePicButton;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) int numPics;

@end

@implementation AutoBoothCameraViewController

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
    self.numPics = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsTakingPicture:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraIsFinishedTakingPicture:)
                                                 name:AVCaptureSessionDidStopRunningNotification object:nil];
   
    
	// Do any additional setup after loading the view.
    self.camera = [[UIImagePickerController alloc] init];
    self.camera.delegate = self;
    self.camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.camera.showsCameraControls = NO;
    
    CGRect cameraFrame = self.camera.view.frame;
    self.camera.view.frame = cameraFrame;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    float cameraAspectRatio = 4.0 / 3.0;
    float imageWidth = floorf(screenSize.width * cameraAspectRatio);
    float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
    
    self.camera.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
    
    
    [self.view addSubview:self.camera.view];
    [self.view bringSubviewToFront:self.takePicButton];
    
    
    
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self doCountdown];
}



-(void) doCountdown {
   /* [UIView animateWithDuration:3.0
                     animations:^{
                             
                     } completion:^(BOOL finished){
                     }];*/
}
-(void) takePic{
    if (self.numPics > 2) {
        [self.timer invalidate];
        
        
        return;
    }
    
    
    [self.camera takePicture];
    self.numPics++;

}


-(void) cameraIsTakingPicture:(NSNotification *) notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(takePic) userInfo:nil repeats:YES];
        [self.timer fire];
    });
}


-(void) cameraIsFinishedTakingPicture:(NSNotification *) notification{
    NSLog(@"camera finished taking picture");
}

#pragma mark - UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"info: %@", info);
}

#pragma mark - Camera Actions

- (IBAction)takePicButtonMethod:(id)sender {
    [self.camera takePicture];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
