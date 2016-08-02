#import "RCTBridge.h"
#import "RCTIJKPlayer.h"
#import "RCTIJKPlayerManager.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"

#import "UIView+React.h"
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>
// #import "IJKMediaControl.h"

@interface RCTIJKPlayer ()

@property (nonatomic, weak) RCTIJKPlayerManager *manager;
@property (nonatomic, weak) RCTBridge *bridge;
//@property(nonatomic,strong)IJKFFMoviePlayerController * player;

@end

@implementation RCTIJKPlayer
{
}

- (id)initWithManager:(RCTIJKPlayerManager*)manager bridge:(RCTBridge *)bridge
{

  if ((self = [super init])) {
    self.manager = manager;
    self.bridge = bridge;
  }

    // IJKFFOptions *options = [IJKFFOptions optionsByDefault]; //使用默认配置
    // // NSURL * url = [NSURL URLWithString:@"/Users/cong/Downloads/111.mov"];
    // NSURL * url = [NSURL URLWithString:@"/Users/cong/Downloads/222.mkv"];
    // self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options]; //初始化播放器，播放在线视频或直播(RTMP)
    // self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // self.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width,
    //                          [[UIScreen mainScreen] applicationFrame].size.height);
    // self.player.view.frame = self.bounds;

    // self.player.scalingMode = IJKMPMovieScalingModeAspectFit; //缩放模式
    // self.player.shouldAutoplay = YES; //开启自动播放

    // self.autoresizesSubviews = YES;
    // [self addSubview:self.player.view];
    // [self.player prepareToPlay];
    // Do any additional setup after loading the view, typically from a nib.

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];

    // IJKFFOptions *options = [IJKFFOptions optionsByDefault];

    // self.url = [NSURL URLWithString:@"/Users/cong/Downloads/111.mov"];
    // self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    // self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    // self.player.view.frame = self.bounds;
    // self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    // self.player.shouldAutoplay = YES;

    // self.autoresizesSubviews = YES;
    // [self addSubview:self.player.view];
    // [self addSubview:self.mediaControl];

    // self.mediaControl.delegatePlayer = self.player;
    // [self installMovieNotificationObservers];

    // [self.player prepareToPlay];

  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  return;
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
  [super removeFromSuperview];
}

- (void)dismiss
{
    //[self dismissViewControllerAnimated:YES completion:nil];
}

// #pragma mark IBAction

// - (IBAction)onClickMediaControl:(id)sender
// {
//     [self.mediaControl showAndFade];
// }

// - (IBAction)onClickOverlay:(id)sender
// {
//     [self.mediaControl hide];
// }

// - (IBAction)onClickDone:(id)sender
// {
//     //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
// }

// - (IBAction)onClickHUD:(UIBarButtonItem *)sender
// {
//     if ([self.player isKindOfClass:[IJKFFMoviePlayerController class]]) {
//         IJKFFMoviePlayerController *player = self.player;
//         player.shouldShowHudView = !player.shouldShowHudView;

//         sender.title = (player.shouldShowHudView ? @"HUD On" : @"HUD Off");
//     }
// }

// - (IBAction)onClickPlay:(id)sender
// {
//     [self.player play];
//     [self.mediaControl refreshMediaControl];
// }

// - (IBAction)onClickPause:(id)sender
// {
//     [self.player pause];
//     [self.mediaControl refreshMediaControl];
// }

// - (IBAction)didSliderTouchDown
// {
//     [self.mediaControl beginDragMediaSlider];
// }

// - (IBAction)didSliderTouchCancel
// {
//     [self.mediaControl endDragMediaSlider];
// }

// - (IBAction)didSliderTouchUpOutside
// {
//     [self.mediaControl endDragMediaSlider];
// }

// - (IBAction)didSliderTouchUpInside
// {
//     self.player.currentPlaybackTime = self.mediaControl.mediaProgressSlider.value;
//     [self.mediaControl endDragMediaSlider];
// }

// - (IBAction)didSliderValueChanged
// {
//     [self.mediaControl continueDragMediaSlider];
// }

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    IJKMPMovieLoadState loadState = _player.loadState;

    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;

        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;

        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    NSDictionary *event = @{
        @"state": [[NSNumber numberWithInt:(int)_player.playbackState] stringValue],
        };
    [self.bridge.eventDispatcher sendAppEventWithName:@"PlayBackState" body:event];

    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

- (void)resume
{
    if (self.player) {
        [self.player play];
    }
}

- (void)pause
{
    if (self.player) {
        [self.player pause];
    }
}

- (void)shutdown
{
    if (self.player) {
        [self.player shutdown];
    }
}

- (void)stop
{
    if (self.player) {
        [self.player stop];
    }
}

- (void)seekTo:(NSTimeInterval)currentPlaybackTime
{
    if (self.player) {
      NSLog(@"(void)seekTo:(NSTimeInterval)currentPlaybackTime %f\n", currentPlaybackTime);
      self.player.currentPlaybackTime = currentPlaybackTime;
    }
}

- (void)startWithOptions:(NSDictionary *)options
{
  if (self.player) {
    self.player = nil;
  }
  NSString *URL = (NSString *)(options[@"url"]);
  NSLog(@"URL: %@", URL);

  self.url = [NSURL URLWithString:URL];

    IJKFFOptions *ijkOptions = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:ijkOptions];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    [self.player setPauseInBackground:YES];
    self.autoresizesSubviews = YES;
    [self addSubview:self.player.view];
    //[self addSubview:self.mediaControl];

    //self.mediaControl.delegatePlayer = self.player;
    [self installMovieNotificationObservers];

    [self.player prepareToPlay];
}
@end
