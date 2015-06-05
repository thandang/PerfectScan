//
//  PSOverlayView.m
//  PerfectScan
//
//  Created by Than Dang on 6/4/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "PSOverlayView.h"
#import "BFPaperButton.h"
#define kPadding    300.0f

@interface PSOverlayView () {
    __weak BFPaperButton *_cancelButton;
    float   _padding;
    __weak UILabel *_lblText;
}

@end

@implementation PSOverlayView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat cropSize = frame.size.width - kPadding * 2;
        _cropRect = CGRectMake(kPadding, (frame.size.height - cropSize)/2, cropSize, cropSize);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    
    [[UIColor clearColor] setFill];
    UIRectFill(rect);
    
    CGRect fullScreen = [UIScreen mainScreen].bounds;
    
    CGRect sampleRect = CGRectMake(0.0, 0.0, fullScreen.size.width, _cropRect.origin.y - 3);
    CGRect holdRect = CGRectIntersection(sampleRect, rect);
    //    [[UIColor whiteColor] setFill];
    [[UIColor colorWithWhite:1.000 alpha:0.250] setFill];
    UIRectFill(holdRect);
    
    CGRect sampleRect2 = CGRectMake(0.0, _cropRect.origin.y - 3, _cropRect.origin.x - 3, rect.size.height - _cropRect.origin.y);
    UIRectFill(sampleRect2);
    
    CGRect sampleRect3 = CGRectMake(0.0, _cropRect.size.height + _cropRect.origin.y + 3, rect.size.width - 3, rect.size.height - _cropRect.size.height);
    UIRectFill(sampleRect3);
    
    CGRect sampleRect4 = CGRectMake(_cropRect.size.width + _cropRect.origin.x + 3, _cropRect.origin.y - 3, rect.size.width - (_cropRect.size.width + _cropRect.origin.x), rect.size.height - _cropRect.origin.y);
    UIRectFill(sampleRect4);
    
    
    //draw line body
    CGContextBeginPath(c);
    CGFloat redColor[4] = {1.0f, 0.0f, 0.0f, 0.4f};
    CGContextSetStrokeColor(c, redColor);
    CGContextSetLineWidth(c, 8.0f);
    CGContextSetFillColor(c, redColor);
    CGContextMoveToPoint(c, _cropRect.origin.x + 25, _cropRect.origin.y + _cropRect.size.height/2);
    CGContextAddLineToPoint(c, _cropRect.origin.x + (_cropRect.size.width - 25), _cropRect.origin.y + _cropRect.size.height/2);
    CGContextStrokePath(c);
    
    //Draw center line
    CGContextBeginPath(c);
    CGContextSetStrokeColor(c, redColor);
    CGContextSetLineWidth(c, 4.0f);
    CGContextMoveToPoint(c, _cropRect.origin.x +  (_cropRect.size.width - 4.0)/2, _cropRect.origin.y + (_cropRect.size.height - 80.0)/2);
    CGContextAddLineToPoint(c, _cropRect.origin.x +  (_cropRect.size.width - 4.0)/2, _cropRect.origin.y + (_cropRect.size.height - 80.0)/2 + 80.0);
    
    CGContextStrokePath(c);
    
    CGFloat white[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetLineWidth(c, 7.0f);
    CGContextSetStrokeColor(c, white);
    CGContextSetFillColor(c, white);
    [self drawRect:_cropRect inContext:c];
    
    CGContextSaveGState(c);
    CGContextRestoreGState(c);
    
    if( nil != _points ) {
        CGFloat blue[4] = {0.0f, 1.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(c, blue);
        CGContextSetFillColor(c, blue);
        
        CGRect smallSquare = CGRectMake(0, 0, 10, 10);
        for( NSValue* value in _points ) {
            CGPoint point = [self map:[value CGPointValue]];
            smallSquare.origin = CGPointMake(
                                             _cropRect.origin.x + point.x - smallSquare.size.width / 2,
                                             _cropRect.origin.y + point.y - smallSquare.size.height / 2);
            [self drawRect:smallSquare inContext:c];
        }
    }
    
}

- (void) setDisplayedMessage:(NSString *)displayedMessage_ { //Custom
    if (displayedMessage_ && displayedMessage_.length) {
        _lblText.text = displayedMessage_;
    }
    _displayedMessage = displayedMessage_;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    float cancelOrinPlus = 55.0;
    
    if (screenSize.height > 480) {
        cancelOrinPlus = 65.0;
    }
    
    if (!_lblText) {
        UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 400)/2, (_cropRect.origin.y - 50) / 2 + 20, 400.0, 50)];
        lblText.font = [UIFont systemFontOfSize:17.0];
        lblText.textColor = kCOLOR_BACKGROUND;
        lblText.textAlignment = NSTextAlignmentCenter;
        lblText.numberOfLines = 2;
        [self addSubview:lblText];
        _lblText = lblText;
    }
    _lblText.text = self.displayedMessage;
    
    
    if (!_cancelButton) {
        CGSize theSize = CGSizeMake(100, 50);
        CGRect rect = self.frame;
        BFPaperButton *btn = [[BFPaperButton alloc] initFlatWithFrame:CGRectMake((rect.size.width - theSize.width) / 2, _cropRect.origin.y + _cropRect.size.height + cancelOrinPlus, theSize.width, theSize.height)];
        
        [btn setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:kCOLOR_BACKGROUND];
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor grayColor].CGColor;
        btn.layer.cornerRadius = 4.0;
        [btn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        _cancelButton = btn;
        
        [self bringSubviewToFront:_cancelButton];
    }
}

- (void) cancelClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(overlayDidCancel)]) {
        [self.delegate overlayDidCancel];
    }
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context {
    //instead draw 4 line, we will draw 8 line
    CGContextBeginPath(context);
    
    //first line
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width/5, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
    //second line
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height/5);
    
    //third line
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width * 4/5, rect.origin.y);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
    //fourth line
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height/5);
    
    //fifth line
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height * 4 / 5);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    //sixth line
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width * 4/5, rect.origin.y + rect.size.height);
    
    //seventh line
    CGContextMoveToPoint(context, rect.origin.x + rect.size.width/5, rect.origin.y + rect.size.height);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
    //eighth line
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height * 4/5);
    
    CGContextStrokePath(context);
}

- (CGPoint)map:(CGPoint)point {
    CGPoint center;
    center.x = _cropRect.size.width/2;
    center.y = _cropRect.size.height/2;
    float x = point.x - center.x;
    float y = point.y - center.y;
    int rotation = 90;
    switch(rotation) {
        case 0:
            point.x = x;
            point.y = y;
            break;
        case 90:
            point.x = -y;
            point.y = x;
            break;
        case 180:
            point.x = -x;
            point.y = -y;
            break;
        case 270:
            point.x = y;
            point.y = -x;
            break;
    }
    point.x = point.x + center.x;
    point.y = point.y + center.y;
    return point;
}

- (void) setPoints:(NSMutableArray*)pnts {
    _points = pnts;
    
    if (pnts != nil) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    }
    [self setNeedsDisplay];
}

- (void) setPoint:(CGPoint)point {
    if (!_points) {
        _points = [[NSMutableArray alloc] init];
    }
    if (_points.count > 3) {
        [_points removeObjectAtIndex:0];
    }
    [_points addObject:[NSValue valueWithCGPoint:point]];
    [self setNeedsDisplay];
}

@end
