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
#import <CoreVideo/CoreVideo.h>
#import <MediaPlayer/MediaPlayer.h>

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

@property (strong, nonatomic) AVAssetWriter *videoWriter;
@property (strong, nonatomic) AVAssetWriterInput *assetWriterInput;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *assetWriterBuffer;

@property (strong, nonatomic) CIDetector *faceDetector;
@property (strong, nonatomic) UIImageView *glasses;


@property (weak, nonatomic) IBOutlet UIImageView *videoOutputImage;
@property (strong, nonatomic) CIContext *context;

@property (assign, nonatomic) CMTime time;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

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
    [self.view bringSubviewToFront:self.timerLabel];

    
    
    //Video Writer stuff
    
    NSString *urlString = [self applicationDocumentsDirectory];
    
    
    NSString *realURLString = [NSString stringWithFormat:@"%@/%@", urlString, @"video.mp4"];
    
    NSURL *url = [NSURL fileURLWithPath:realURLString];

    
    [self removeFile:url];

    
    NSError *e;
    self.videoWriter = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:&e];
    NSLog(@"video writer error %@", e);

    [self printDirectory];
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:320], AVVideoWidthKey,
                                   [NSNumber numberWithInt:573], AVVideoHeightKey,
                                   nil];
    
    self.assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    [self.videoWriter addInput:self.assetWriterInput];
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], kCVPixelBufferPixelFormatTypeKey, nil];

    
    self.assetWriterBuffer = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    self.assetWriterInput.expectsMediaDataInRealTime = YES;
    
    [self.videoWriter startWriting];
    
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
}


#pragma mark - AVCapture Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    CVPixelBufferRef pb = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pb];
    CGImageRef ref = [self.context createCGImage:ciImage fromRect:ciImage.extent];
    self.videoOutputImage.image = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationUp];
    
    if ([self.assetWriterBuffer.assetWriterInput isReadyForMoreMediaData]) {
        self.time = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        
        BOOL sampleWriterSuccess =  [self.assetWriterBuffer appendPixelBuffer:pb withPresentationTime:self.time];
        NSLog(@"sample writer success %d %@  %lld  %d",sampleWriterSuccess, [self.videoWriter.error description], self.time.value, self.time.timescale);
    }

    CGImageRelease(ref);
}


#pragma mark - Rotate Delegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    NSLog(@"device orientation: %d  video orientation %d", toInterfaceOrientation, self.myConnect.videoOrientation);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoOutputImage.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    });
    
    [self.myConnect setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];

}

#pragma mark - Camera Actions
-(void) takePic{
    if (self.numPics > 2) {
        [self.timer invalidate];
        return;
    }
    if ( self.timerCount == 0)
        [self getPicture];
    
    self.timerCount--;
}

-(void) cameraIsTakingPicture:(NSNotification *) notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(takePic) userInfo:nil repeats:YES];
        [self.timer fire];
    });
}

-(void) getPicture {
    self.timerCount = 3;
    self.numPics++;
    [self.timer fire];

    [self.picsArray addObject:self.videoOutputImage.image];
    
    if (self.numPics >  2) {
        [self.session stopRunning];
        [self.assetWriterInput markAsFinished];
        [self.videoWriter endSessionAtSourceTime:self.time];
        [self.videoWriter finishWritingWithCompletionHandler:^{

        
        }];
        

        NSString *urlString = [self applicationDocumentsDirectory];
        
        
        NSString *realURLString = [NSString stringWithFormat:@"%@/%@", urlString, @"video.mp4"];
        
        NSURL *url = [NSURL fileURLWithPath:realURLString];
        
        MPMoviePlayerViewController *movieVC = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        
        [self presentViewController:movieVC animated:YES completion:nil];
        
        //[self performSegueWithIdentifier:@"presentPictureResult" sender:self];
    }
    
}


#pragma mark - UIImagePickerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.timerCount = 3;
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
    
    if ([[segue identifier] isEqualToString:@"moviePlayerSegue"]) {
        MPMoviePlayerViewController *movieViewController = ((MPMoviePlayerController *)[segue destinationViewController]);

        //[movieViewController setContentURL:url];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *testFolder = [basePath stringByAppendingPathComponent:@"/temp"];

    NSError *e = nil;
    //if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
    BOOL b = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:testFolder isDirectory:&b]) {
       bool directorySuccess = [[NSFileManager defaultManager] createDirectoryAtPath:testFolder withIntermediateDirectories:NO attributes:nil error:&e];
        NSLog(@"directory success %d %@", directorySuccess, [e description]);
    }
    
    
    //}
    
    NSURL *url = [NSURL fileURLWithPath:testFolder];
    
    
    return testFolder;
}

-(void) printDirectory {

    NSError *e;
    
    NSString *urlString = [self applicationDocumentsDirectory];
    
    NSURL *url = [NSURL fileURLWithPath:urlString];
    
    NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"heart.png"]);

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [data writeToFile:[NSString stringWithFormat:@"%@/%@", urlString, @"myheart.png"] atomically:YES];

    });
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSLog(@"finished writing");
    NSArray *directory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url.relativePath error:&e];
    NSLog(@"directory %@ error %@", [directory description], [e description]);
    
    for (int i=0; i<directory.count; i++) {
        id object = [directory objectAtIndex:i];
        NSLog(@"object %@", [object description]);
    }
    
    
}
- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSLog(@"filepath %@", filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:filePath error:&error] == NO) {
            NSLog(@"removeItemAtPath %@ error:%@", filePath, error);
        }
    }
}
@end
