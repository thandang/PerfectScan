//
//  PSScanViewController.m
//  PerfectScan
//
//  Created by Than Dang on 6/4/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "PSScanViewController.h"
#import "PSOverlayView.h"

@interface PSScanViewController () <ScanDelegate>


@property (strong, nonatomic) AVCaptureDevice* device;
@property (strong, nonatomic) AVCaptureDeviceInput* input;
@property (strong, nonatomic) AVCaptureMetadataOutput* output;
@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* preview;

@property (strong, nonatomic) AVAudioPlayer* audioPlayer;

- (void) loadVoiceAlert;

@end

@implementation PSScanViewController

- (void) dealloc {
    //remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(![self isCameraAvailable]) {
        [self setupNoCameraView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadVoiceAlert {
    //    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep-beep" ofType:@"caf"];
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)evt {
    if(self.touchToFocusEnabled) {
        UITouch *touch=[touches anyObject];
        CGPoint pt= [touch locationInView:self.view];
        [self focus:pt];
    }
}

#pragma mark -
#pragma mark NoCamAvailable

- (void) setupNoCameraView {
    UILabel *labelNoCam = [[UILabel alloc] init];
    labelNoCam.text = @"No Camera available";
    labelNoCam.textColor = kCOLOR_BACKGROUND;
    [self.view addSubview:labelNoCam];
    [labelNoCam sizeToFit];
    labelNoCam.center = self.view.center;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]));
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else {
        AVCaptureConnection *con = self.preview.connection;
        con.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
}

#pragma mark -
#pragma mark AVFoundationSetup

- (void) setupScanner {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    self.session = [[AVCaptureSession alloc] init];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.session addOutput:self.output];
    [self.session addInput:self.input];
    
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.output.metadataObjectTypes = [self.output availableMetadataObjectTypes];//@[AVMetadataObjectTypeQRCode];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    AVCaptureConnection *con = self.preview.connection;
    
    con.videoOrientation = AVCaptureVideoOrientationLandscapeRight;//AVCaptureVideoOrientationLandscapeLeft;
    
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    if (!_overlayView) {
        PSOverlayView *ov = [[PSOverlayView alloc] initWithFrame:self.view.frame];
        [ov setBackgroundColor:[UIColor clearColor]];
        [ov setDelegate:self];
        [self.view addSubview:ov];
        _overlayView = ov;
    }
    [self.view bringSubviewToFront:_overlayView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBackground:) name:kNotificationAppEnterBackground object:nil];
}

- (void) appEnterBackground:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationAppEnterBackground object:nil];
    [self dismissViewControllerAnimated:NO completion:^{
        [self stopScanning];
    }];
}


#pragma mark - OverlayView Delegate
- (void) overlayDidCancel {
    [self.delegate scanDidClose];
}

#pragma mark -
#pragma mark Helper Methods

- (BOOL) isCameraAvailable {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)startScanning:(NSString *) optionText {
    _overlayView.displayedMessage = optionText;
    [self.session startRunning];
    
}

- (void) stopScanning {
    [self.session stopRunning];
}

- (void) setTorch:(BOOL) aStatus {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ( [device hasTorch] ) {
        if ( aStatus ) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
    }
    [device unlockForConfiguration];
}

- (void) focus:(CGPoint) aPoint {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if([device isFocusPointOfInterestSupported] &&
       [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        double screenWidth = screenRect.size.width;
        double screenHeight = screenRect.size.height;
        double focus_x = aPoint.x/screenWidth;
        double focus_y = aPoint.y/screenHeight;
        if([device lockForConfiguration:nil]) {
            if([self.delegate respondsToSelector:@selector(scanViewController:didTapToFocusOnPoint:)]) {
                [self.delegate scanViewController:self didTapToFocusOnPoint:aPoint];
            }
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [device setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark -
#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if([self.delegate respondsToSelector:@selector(scanViewController:didSuccessfullyScan:)]) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                if (_audioPlayer) {
                    [_audioPlayer play];
                }
                [self.delegate scanViewController:self didSuccessfullyScan:scannedValue];
            }
        }
    }
}

@end
