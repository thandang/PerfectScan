//
//  PSScanViewController.h
//  PerfectScan
//
//  Created by Than Dang on 6/4/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol ScanDelegate;
@class PSOverlayView;

@interface PSScanViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, weak) id<ScanDelegate> delegate;

@property (assign, nonatomic) BOOL touchToFocusEnabled;

@property (weak, nonatomic) PSOverlayView   *overlayView;

- (BOOL) isCameraAvailable;
- (void) startScanning:(NSString *)optionText;
- (void) stopScanning;
- (void) setTorch:(BOOL) aStatus;

@end

@protocol ScanDelegate <NSObject>

@optional

- (void) scanViewController:(PSScanViewController *) aCtler didTapToFocusOnPoint:(CGPoint) aPoint;
- (void) scanViewController:(PSScanViewController *) aCtler didSuccessfullyScan:(NSString *) aScannedValue;

- (void) scanDidClose;
