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

@interface AutoBoothCameraViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *picsArray;
@property (assign, nonatomic) int numPics;
@property (assign, nonatomic) int timerCount;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *videoDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureVideoDataOutput *frameOutput;
@property (strong, nonatomic) AVCaptureConnection *myConnect;


@property (weak, nonatomic) IBOutlet UIImageView *videoOutputImage;
@property (strong, nonatomic) CIContext *context;

@end

@implementation AutoBoothCameraViewController

-(CIContext *) context{
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    
    return _context;
}

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
   

    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray *theDevices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in theDevices) {
        if (device.position == AVCaptureDevicePositionBack)
            self.videoDevice = [AVCaptureDevice deviceWithUniqueID:device.uniqueID];
    }
    
    NSError *error;
    if ([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [self.videoDevice lockForConfiguration:&error]) {
        [self.videoDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    
    
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    self.frameOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    self.frameOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
    
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.frameOutput];
    
    
    [self.session startRunning];
    
    [self.frameOutput setSampleBufferDelegate:((id<AVCaptureVideoDataOutputSampleBufferDelegate>)self) queue:dispatch_get_main_queue()];
    
    [self.view bringSubviewToFront:self.timerLabel];

}

#pragma mark - AVCapture Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    self.myConnect = connection;
    
    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pb];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIHueAdjust"];
    [filter setDefaults];
    [filter setValue:ciImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputAngle"];
    
    CIImage *result = [filter valueForKey:@"outputImage"];
    
    
    CGImageRef ref = [self.context createCGImage:ciImage fromRect:ciImage.extent];

    
    self.videoOutputImage.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];
    CGImageRelease(ref);
}


#pragma mark - Rotate Delegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.videoOutputImage.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    
    [self.myConnect setVideoOrientation:AVCaptureVideoOrientationPortrait];

}

#pragma mark - Camera Actions
-(void) takePic{
    if (self.numPics > 2) {
        [self.timer invalidate];
        return;
    }
    if ( self.timerCount == 0)
        //[self.camera takePicture];
    
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
    
    if (self.numPics >  2) {
        [self performSegueWithIdentifier:@"presentPictureResult" sender:self];

    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([[segue identifier] isEqualToString:@"presentPictureResult"]) {
        PictureResultViewController *cameraViewController = ((PictureResultViewController *)[segue destinationViewController]);
        cameraViewController.picArray = self.picsArray;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
