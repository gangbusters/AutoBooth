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

@property (strong, nonatomic) CIDetector *faceDetector;
@property (strong, nonatomic) UIImageView *glasses;


@property (weak, nonatomic) IBOutlet UIImageView *videoOutputImage;
@property (strong, nonatomic) CIContext *context;

@end

@implementation AutoBoothCameraViewController

-(CIDetector *) faceDetector{
    if (!_faceDetector) {
        NSDictionary *detectorOptions = @{CIDetectorAccuracy: CIDetectorAccuracyLow};  //, CIDetectorImageOrientation: [NSNumber numberWithInt:1]};

        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    }
    return _faceDetector;
}

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
    self.session.sessionPreset = AVCaptureSessionPresetLow;
    
    self.videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSArray *theDevices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in theDevices) {
        if (device.position == AVCaptureDevicePositionFront)
            self.videoDevice = [AVCaptureDevice deviceWithUniqueID:device.uniqueID];
    }
    
    NSError *error;
    if ([self.videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [self.videoDevice lockForConfiguration:&error]) {
        [self.videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    
    
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:nil];
    self.frameOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    self.frameOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithInteger:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]};
    
    [self.session addInput:self.videoInput];
    [self.session addOutput:self.frameOutput];
    
    
    [self.session startRunning];
    
    [self.frameOutput setSampleBufferDelegate:((id<AVCaptureVideoDataOutputSampleBufferDelegate>)self) queue:dispatch_get_main_queue()];
    
    self.myConnect = [self.frameOutput.connections objectAtIndex:0];

    [self.myConnect setVideoOrientation:AVCaptureVideoOrientationPortrait];
    [self.myConnect setVideoMirrored:YES];
    
    UIInterfaceOrientation phoneO = [[UIApplication sharedApplication] statusBarOrientation];
    AVCaptureVideoOrientation AVCaptureO = self.myConnect.videoOrientation;
    
    NSLog(@"phone orientation %d   AVCapture orientation %d",phoneO,AVCaptureO );
    
    
    [self.view bringSubviewToFront:self.timerLabel];
    
    
    self.glasses = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
    [self.glasses setHidden:YES];
    [self.view addSubview:self.glasses];
    
    
    

}

#pragma mark - AVCapture Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pb];
    
    
    
    //ciImage = [ciImage imageByApplyingTransform:transform];
    CGImageRef ref = [self.context createCGImage:ciImage fromRect:ciImage.extent];
    NSArray *features = [self.faceDetector featuresInImage:ciImage];
    BOOL faceFound = NO;
    for (CIFaceFeature *face in features) {
        NSLog(@"checking for features");
        if (face.hasLeftEyePosition && face.hasRightEyePosition) {
            CGPoint eyeCenter = CGPointMake(face.leftEyePosition.x*0.5 + face.rightEyePosition.x*0.5, face.leftEyePosition.y*0.5 + face.rightEyePosition.y*0.5);
            CGPoint leftEye = CGPointMake(face.leftEyePosition.x, face.leftEyePosition.y);
            
            NSLog(@"lefteye pos : %f %f",face.leftEyePosition.x, face.leftEyePosition.y );
            
            double scalex = self.videoOutputImage.bounds.size.height/ciImage.extent.size.width;
            double scaley = self.videoOutputImage.bounds.size.width/ciImage.extent.size.height;
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(ciImage.extent.size.height, 0.0f);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
            
            CGRect ciFrame = CGRectMake(ciImage.extent.origin.y*scaley, ciImage.extent.origin.x*scalex, ciImage.extent.size.height*scaley, ciImage.extent.size.width*scalex);
            
            
            
            
            NSLog(@"ciFrame   rect: %f %f %f %f", ciFrame.origin.x, ciFrame.origin.y, ciFrame.size.width, ciFrame.size.height);
            
            CGRect faceFrame = CGRectMake(face.bounds.origin.x*scalex, face.bounds.origin.y*scaley, face.bounds.size.height*scaley, face.bounds.size.width*scalex);
            UIView* faceView = [[UIView alloc] initWithFrame:faceFrame];
            faceView.layer.borderWidth = 1;
            faceView.layer.borderColor = [[UIColor redColor] CGColor];
            //[self.videoOutputImage addSubview:faceView];
            
            
        self.glasses.frame = CGRectMake(leftEye.y*scaley, leftEye.x*scalex, 40, 40);
        
        NSLog(@"heart   rect: %f %f %f %f", self.glasses.frame.origin.x, self.glasses.frame.origin.y, self.glasses.frame.size.width, self.glasses.frame.size.height);

        faceFound = YES;
        }
    }
    
    if (faceFound) {
        [self.glasses setHidden:NO];
    }
    //else
        //[self.glasses setHidden:YES];
    


    
    self.videoOutputImage.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationRight];

    //self.videoOutputImage.transform = CGAffineTransformMakeRotation(-M_PI/2);;
    //self.glasses.transform =CGAffineTransformMakeRotation(-M_PI/2);
    
    CGImageRelease(ref);
}


#pragma mark - Rotate Delegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.videoOutputImage.frame = CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width);
    [self.myConnect setVideoOrientation:toInterfaceOrientation+1];

}

#pragma mark - Camera Actions
-(void) takePic{
    if (self.numPics > 2) {
        [self.timer invalidate];
        return;
    }
    //if ( self.timerCount == 0)
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
