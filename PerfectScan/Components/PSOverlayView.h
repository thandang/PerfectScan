//
//  PSOverlayView.h
//  PerfectScan
//
//  Created by Than Dang on 6/4/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OverlayDelegate;
@interface PSOverlayView : UIView {
    NSMutableArray *_points;
}

@property (nonatomic, strong) NSString *displayedMessage;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, weak) id<OverlayDelegate>delegate;
@property (nonatomic, assign) CGRect cropRect;

- (void)setPoint:(CGPoint)point;

@end

@protocol OverlayDelegate <NSObject>

- (void) overlayDidCancel;

@end