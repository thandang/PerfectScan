//
//  PSMainViewController.m
//  PerfectScan
//
//  Created by Than Dang on 6/3/15.
//  Copyright (c) 2015 Than Dang. All rights reserved.
//

#import "PSMainViewController.h"
#import "BannerViewController.h"

@interface PSMainViewController ()

@end

@implementation PSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBeginBannerViewActionNotification:) name:BannerViewActionWillBegin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishBannerViewActionNotification:) name:BannerViewActionDidFinish object:nil];
    }
    return self;
}

- (void) loadView {
    [super loadView];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)willBeginBannerViewActionNotification:(NSNotification *)notification {
//    [self stopTimer];
    //Begin show banner
}

- (void)didFinishBannerViewActionNotification:(NSNotification *)notification {
//    [self startTimer];
    
}


@end
