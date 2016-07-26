#import "RCTBridge.h"
#import "RCTIJKPlayer.h"
#import "RCTIJKPlayerManager.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"

#import "UIView+React.h"

#import <AVFoundation/AVFoundation.h>

//#include "IJKPlayerSDK.h"
#import "LiveHelper.h"

#define  kControlHeight  44
#define  kControlWidth  62

@interface RCTIJKPlayer () <IJKPlayerStreamerDelegate>

@property (nonatomic, weak) RCTIJKPlayerManager *manager;
@property (nonatomic, weak) RCTBridge *bridge;

//Live
@property (nonatomic,strong)IJKPlayerStreamer * streamer;
@property (nonatomic, assign) int               bitrate;
@property (nonatomic, assign) int               fps;

@property (nonatomic,strong)UIView * canvasView;

@property (nonatomic,strong)UIView *optionsView;//操作面板

@property (nonatomic,assign)BOOL useAutoEstimateBitrate;//自动切换码率
@property (nonatomic,assign)BOOL useDebugMode;
@property (nonatomic,strong)NSURL *hostURL;
@property (nonatomic,strong)UISlider *cameraZoomSlider;

@property (nonatomic,assign)BOOL isDisconnecting;


@end

@implementation RCTIJKPlayer
{
}

- (id)initWithManager:(RCTIJKPlayerManager*)manager bridge:(RCTBridge *)bridge
{

  if ((self = [super init])) {
    self.manager = manager;
    self.bridge = bridge;

    self.fps = 15;
    self.bitrate = 500000;

    self.useAutoEstimateBitrate = YES;
    self.useDebugMode = NO;
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  return;
  NSLog(@"bounds.origin.x: %f", self.bounds.origin.x);
  NSLog(@"bounds.origin.y: %f", self.bounds.origin.y);
  NSLog(@"bounds.size.width: %f", self.bounds.size.width);
  NSLog(@"bounds.size.height: %f", self.bounds.size.height);
  self.optionsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width,
                                                              [[UIScreen mainScreen] applicationFrame].size.height)];

  // self.optionsView = [[UIView alloc]initWithFrame:self.bounds];
  [self addSubview:self.optionsView];
  [self sendSubviewToBack:self.optionsView];

  [self.optionsView addSubview:[LiveHelper createButton:@"退出" target:self action:@selector(dismiss)]];

  UIButton * debugButton = [LiveHelper createButton:@"调试" target:self action:@selector(debugButtonClicked:)];
  [debugButton setTitle:self.useDebugMode?@"调试":@"未调试" forState:UIControlStateNormal];
  [self.optionsView addSubview:debugButton];

  [self.optionsView addSubview:[LiveHelper createButton:@"开始" target:self action:@selector(start)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"停止" target:self action:@selector(stop)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"摄像头" target:self action:@selector(switchCameraButtonClicked:)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"切换滤镜" target:self action:@selector(switchFilterButtonClicked:)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"无滤镜" target:self action:@selector(useFilterNormalButtonClicked:)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"闪光灯" target:self action:@selector(flashButtonClicked:)]];
  //fps
  [self.optionsView addSubview:[LiveHelper createButton:@"帧率++" target:self action:@selector(fpsIncrease:)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"帧率--" target:self action:@selector(fpsDecrease:)]];
  //码率
  [self.optionsView addSubview:[LiveHelper createButton:@"码率++" target:self action:@selector(bitrateIncrease:)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"码率--" target:self action:@selector(bitrateDecrease:)]];

  UIButton * bitrateButton = [LiveHelper createButton:@"固定码率" target:self action:@selector(useAutoEstimateBitrateClicked:)];
  [bitrateButton setTitle:self.useAutoEstimateBitrate?@"动态码率":@"固定码率" forState:UIControlStateNormal];
  [self.optionsView addSubview:bitrateButton];

  //水印操作
  [self.optionsView addSubview:[LiveHelper createButton:@"添加水印" target:self action:@selector(addWartMakeButtonClicked:)]];
  [self.optionsView addSubview:[LiveHelper createButton:@"移除水印" target:self action:@selector(removeWarterMarkButtonClicked:)]];

  //静音
  [self.optionsView addSubview:[LiveHelper createButton:@"收音" target:self action:@selector(muteOutputButtonClicked:)]];

  [self createSliderView];
  [self layoutUI];

  [self addObservers];
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
  [self insertSubview:view atIndex:atIndex + 1];
  return;
}

- (void)removeReactSubview:(UIView *)subview
{
  [subview removeFromSuperview];
  return;
}

- (void)removeFromSuperview
{
  [self stop];
  [super removeFromSuperview];
}

- (void)layoutUI
{
    CGFloat btnHeight = kControlHeight;
    CGFloat btnWidth  = kControlWidth;

    CGRect content = CGRectInset(self.optionsView.bounds, 0, 20);
    NSInteger row = CGRectGetHeight(content)/btnHeight;//行数
    NSInteger col = CGRectGetWidth(content)/btnWidth;//列数
    NSArray *subViews = [self.optionsView subviews];
    CGRect lastControlFrame = CGRectZero;
    for (int index = 0; index < [subViews count]; index++) {
        UIControl*  control = subViews[index];
        if ([control isKindOfClass:[UIButton class]]) {
            CGRect frame = [LiveHelper frameForItemAtIndex:index+1/*从1开始*/ contentArea:content rows:row cols:col itemHeight:btnHeight itemWidth:btnWidth];
            control.frame = CGRectInset(frame, 1, 1);
            lastControlFrame = control.frame;
        }
    }

    self.cameraZoomSlider.frame = CGRectMake(20, CGRectGetMaxY(lastControlFrame)+130, CGRectGetWidth(self.optionsView.frame)-40, 50);
}

- (void)createSliderView
{
    self.cameraZoomSlider = [[UISlider alloc]initWithFrame:CGRectZero];
    self.cameraZoomSlider.continuous = YES;
    self.cameraZoomSlider.minimumValue = 1.f;
    self.cameraZoomSlider.maximumValue = 1.f;
    self.cameraZoomSlider.value = 1.0;
    self.cameraZoomSlider.userInteractionEnabled = YES;
    [self.cameraZoomSlider addTarget:self action:@selector(scrubberIsScrolling:) forControlEvents:UIControlEventValueChanged];//滑块拖动时的事件
    [self.optionsView addSubview:self.cameraZoomSlider];

    self.cameraZoomSlider.enabled = NO;
}

- (void)resetCameraZoomInfo
{
    if (!_streamer) {
        return;
    }
    self.cameraZoomSlider.enabled = YES;
    if ([_streamer cameraZoomSupported]) {
        self.cameraZoomSlider.minimumValue = 1.0;
        self.cameraZoomSlider.maximumValue = [_streamer cameraMaxZoomFactor];
        self.cameraZoomSlider.value = self.cameraZoomSlider.minimumValue;
    }else{
        self.cameraZoomSlider.minimumValue = 1.0;
        self.cameraZoomSlider.maximumValue = 1.0;
        self.cameraZoomSlider.value = self.cameraZoomSlider.minimumValue;
    }
}

- (void)dismiss
{
    //[self dismissViewControllerAnimated:YES completion:nil];
}

//MARK: IJKPlayerStreamer调用

- (void)startWithURL:(NSString *)pushURL
{
    [self stop];
    // self.canvasView = [[UIView alloc]initWithFrame:self.bounds];
    self.canvasView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width,
                                                                [[UIScreen mainScreen] applicationFrame].size.height)];

    [self addSubview:self.canvasView];
    [self sendSubviewToBack:self.canvasView];

    NSString *rtmpURL = pushURL;
    self.hostURL = [NSURL URLWithString:rtmpURL];
    NSLog(@"========>推流地址 %@",rtmpURL);
    _streamer = [[IJKPlayerStreamer alloc]initWithURL:[NSURL URLWithString:rtmpURL] with:self.canvasView capturePosition:LiveCapturePositionBack audioSource:LiveAudioSourceMix filterType:LiveFilterTypeFaceBeauty outputCallback:nil];;

    _streamer.videoSize = CGSizeMake(640, 360);
    _streamer.streamerDelegate = self;

    _streamer.videoInitBitrate = 300000;
    _streamer.videoMaxBitrate = 500000;
    _streamer.videoMinBitrate = 200000;
    _streamer.debugMode = self.useDebugMode;
    _streamer.autoAppleEstimateBitrate = self.useAutoEstimateBitrate;

#if 0  //如下配置，参考文档说明使用
    _streamer.autoAppleReducesLatency = YES;
    _streamer.shouldEnableLogReport = YES;
    _streamer.reportTimeInterval = 5;
    [_streamer setLogBlock:^(NSDictionary * jsonDict) {
        if ([jsonDict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"推流日志 %@",jsonDict);
        }
    }];
#endif

#if 0  //台标水印
        CGSize size = _streamer.videoSize;
        UIImage *wartmarkImage = [LiveHelper imageWithBezierPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 256, 256) cornerRadius:0] fill:YES fillColor:[UIColor greenColor] stroke:YES strokeColor:[UIColor yellowColor]];
        [_streamer addWatermarkWithImage:wartmarkImage withRect:CGRectMake( size.width - 25, 25, 50, 50) type:LiveWaterMakeTypeLogo];
#endif

    [_streamer start];
}


- (void)start
{
    [self stop];
    self.canvasView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:self.canvasView];
    [self sendSubviewToBack:self.canvasView];

    NSString *rtmpURL = @"rtmp://120.132.75.127/live/2016.0413";
    self.hostURL = [NSURL URLWithString:rtmpURL];
    NSLog(@"========>推流地址 %@",rtmpURL);
    _streamer = [[IJKPlayerStreamer alloc]initWithURL:[NSURL URLWithString:rtmpURL] with:self.canvasView capturePosition:LiveCapturePositionFront audioSource:LiveAudioSourceMix filterType:LiveFilterTypeNormal outputCallback:nil];;
    _streamer.streamerDelegate = self;

    _streamer.videoInitBitrate = 300000;
    _streamer.videoMaxBitrate = 500000;
    _streamer.videoMinBitrate = 200000;
    _streamer.videoFPS = self.fps;
    _streamer.debugMode = self.useDebugMode;
    _streamer.autoAppleEstimateBitrate = self.useAutoEstimateBitrate;


#if 0  //如下配置，参考文档说明使用
    _streamer.autoAppleReducesLatency = YES;
    _streamer.shouldEnableLogReport = YES;
    _streamer.reportTimeInterval = 5;
    [_streamer setLogBlock:^(NSDictionary * jsonDict) {
        if ([jsonDict isKindOfClass:[NSDictionary class]]) {
            NSLog(@"推流日志 %@",jsonDict);
        }
    }];
#endif

#if 0  //台标水印
        CGSize size = _streamer.videoSize;
        UIImage *wartmarkImage = [LiveHelper imageWithBezierPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 256, 256) cornerRadius:0] fill:YES fillColor:[UIColor greenColor] stroke:YES strokeColor:[UIColor yellowColor]];
        [_streamer addWatermarkWithImage:wartmarkImage withRect:CGRectMake( size.width - 25, 25, 50, 50) type:LiveWaterMakeTypeLogo];
#endif

    [_streamer start];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:YES];
  NSLog(@"viewWillAppear");
}

- (void)stop
{
    NSLog(@"stop");
    if (_streamer) {
        NSLog(@"stream true, stop");
        [_streamer stop];
        _streamer = nil;
    }

    [self.canvasView removeFromSuperview];
    self.canvasView = nil;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)mute
{
    if (self.streamer) {
        self.streamer.muteOutput = !self.streamer.muteOutput;
        NSLog(@"self.streamer.muteOutput %d",self.streamer.muteOutput);
    }
}

- (void)resume
{
    if (_streamer && self.isDisconnecting == YES ) {
        [_streamer startStream:self.hostURL];
    }
}

- (IBAction)scrubberIsScrolling:(id)sender
{

    UISlider * slider = (UISlider *)sender;
    NSLog(@"scrubberIsScrolling %f min %f,max %f",slider.value,slider.minimumValue,slider.maximumValue);
    if(slider == self.cameraZoomSlider) {
        [self.streamer cameraRampToZoomFactor:slider.value];
    }
}

- (IBAction)muteOutputButtonClicked:(id)sender
{
    if (self.streamer) {
        self.streamer.muteOutput = !self.streamer.muteOutput;

        NSLog(@"self.streamer.muteOutput %d",self.streamer.muteOutput);
        UIButton *button = (UIButton*)sender;
        [button setTitle:(self.streamer.muteOutput?@"静音":@"收音") forState:UIControlStateNormal];
    }
}



- (IBAction)addWartMakeButtonClicked:(id)sender
{
    CGFloat r = (arc4random() % 256) /255.0;
    CGFloat g = (arc4random() % 256) /255.0;
    CGFloat b = (arc4random() % 256) /255.0;
    NSLog(@" %f %f %f",r,g,b);
    UIImage *wartmarkImage = [LiveHelper imageWithBezierPath:[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 256, 32) cornerRadius:0] fill:YES fillColor:[UIColor colorWithRed:r green:g blue:b alpha:1.0] stroke:YES strokeColor:[UIColor yellowColor]];
    CGSize imageSize = wartmarkImage.size;
    [_streamer addWatermarkWithImage:wartmarkImage withRect:CGRectMake( imageSize.width/2, CGRectGetMaxY(self.cameraZoomSlider.frame)+60, imageSize.width, imageSize.height) type:LiveWaterMakeTypeTitle];
}

- (IBAction)removeWarterMarkButtonClicked:(id)sender
{
    if (_streamer) {
        [_streamer removeWatermarkWithType:LiveWaterMakeTypeTitle];
    }
}

- (IBAction)debugButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.useDebugMode = !self.useDebugMode;
    if (_streamer) {
        _streamer.debugMode = self.useDebugMode;
        [button setTitle:self.useDebugMode?@"调试":@"未调试" forState:UIControlStateNormal];
    }
}

- (IBAction)useAutoEstimateBitrateClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.useAutoEstimateBitrate = !self.useAutoEstimateBitrate;
    if (_streamer) {
        _streamer.autoAppleEstimateBitrate = self.useAutoEstimateBitrate;
        [button setTitle:self.useAutoEstimateBitrate?@"动态码率":@"固定码率" forState:UIControlStateNormal];
    }
}

- (IBAction)switchCameraButtonClicked:(id)sender
{
    if (_streamer) {
        [_streamer switchCamera];
        [self resetCameraZoomInfo];
    }
}

- (IBAction)switchFilterButtonClicked:(id)sender
{
    if (_streamer) {
        LiveFilterType newType = (_streamer.activeFilterType +1)%LiveFilter_Counts ;
        [_streamer switchFilter:newType];
    }
}

- (IBAction)useFilterNormalButtonClicked:(id)sender
{
    if (_streamer) {
        [_streamer switchFilter:LiveFilterTypeNormal];
    }
}

- (IBAction)flashButtonClicked:(id)sender
{
    if (_streamer) {
        [_streamer switchFlash];
    }
}

//Increase Decrease
- (IBAction)fpsIncrease:(id)sender
{
    if (_streamer) {
        if (self.fps >=30.) {
            [LiveHelper arertMessage:@"帧率（30）不能再大了"];
            return;
        }
        self.fps +=5;
        _streamer.videoFPS = self.fps;
    }
}

- (IBAction)fpsDecrease:(id)sender
{
    if (_streamer) {
        if (self.fps <=5.) {
            [LiveHelper arertMessage:@"帧率（5）不能再小了"];
            return;
        }
        self.fps -=5;
        _streamer.videoFPS = self.fps;
    }
}

- (IBAction)bitrateIncrease:(id)sender
{
    if (_streamer) {
        if (self.bitrate >=1500000) {
            [LiveHelper arertMessage:@"码率（1500k）不能再大了"];
            return;
        }
        self.bitrate +=100000;
        _streamer.videoInitBitrate = self.bitrate;
    }
}

- (IBAction)bitrateDecrease:(id)sender
{
    if (_streamer) {
        if (self.bitrate <=100000) {
            [LiveHelper arertMessage:@"码率（100k）不能再小了"];
            return;
        }
        self.bitrate -=100000;
        _streamer.videoInitBitrate = self.bitrate;
    }
}

//MARK:IJKPlayerStreamerDelegate
- (void)flashModeChanged:(IJKPlayerStreamer *)streamer
{

}

- (void)liveStreamer:(IJKPlayerStreamer *)streamer streamStateDidChange:(LiveStreamState)state withError:(NSError *)error
{
    NSLog(@"streamStateDidChange %lu %@",(unsigned long)state,error);

    NSDictionary *event = @{
          @"state": [[NSNumber numberWithLong:state] stringValue],
        };
    [self.bridge.eventDispatcher sendAppEventWithName:@"LiveStateChange" body:event];


    if (state == LiveStreamStateReadyForPush || state == LiveStreamStatePreview) {
        [self resetCameraZoomInfo];
    }

    __weak typeof(self) weakSelf = self;
    if (state == LiveStreamStateConnected) {

        //连接成功
        self.isDisconnecting = NO;

    } else if(state == LiveStreamStatePreview) {

        //预览成功

    } else if(state == LiveStreamStateDisconnecting) {

        //断开直播，视情况重启直播

        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            // 断开连接时，业务层重连
            self.isDisconnecting = YES;
            // dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //     if (weakSelf.streamer && self.isDisconnecting == YES ) {
            //         [weakSelf.streamer startStream:weakSelf.hostURL];
            //     }
            // });
        }
    } else if(state == LiveStreamStateError) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {

#warning 当推流失败时，检查当前是否有网，如果无网，则交由 LiveStreamStateDisconnecting 状态尝试重连，其他错误退出直播 或重连，视需求而定
            /*
            if (!SSNetworkConnected()) {
                //检查网络，如果当前无网络，延时5秒重试
                //突然无网导致的err 不处理，交给 LiveStreamStateDisconnecting 状态去延时重连,SDK需要梳理状态上报，临时解决方案 by kk
                return;
            }
            */
            //其他错误导致的直播，直接退出
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self stop];
                _streamer = nil;
            });
        }
    }
}

//MARK: 前台、后台切换
- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appDidBecomeActive:(NSNotification *)notification
{
    // if (_streamer) {
    //     [_streamer startStream:self.hostURL];
    // }
}

- (void)appDidEnterBackground:(NSNotification *)notification
{

}

@end
