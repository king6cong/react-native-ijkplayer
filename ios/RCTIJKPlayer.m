#import "RCTBridge.h"
#import "RCTIJKPlayer.h"
#import "RCTIJKPlayerManager.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"

#import "UIView+React.h"
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>

@interface RCTIJKPlayer ()

@property (nonatomic, weak) RCTIJKPlayerManager *manager;
@property (nonatomic, weak) RCTBridge *bridge;
@property(nonatomic,strong)IJKFFMoviePlayerController * player;

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

    IJKFFOptions *options = [IJKFFOptions optionsByDefault]; //使用默认配置
    // NSURL * url = [NSURL URLWithString:@"/Users/cong/Downloads/111.mov"];
    NSURL * url = [NSURL URLWithString:@"/Users/cong/Downloads/222.mkv"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options]; //初始化播放器，播放在线视频或直播(RTMP)
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width,
                             [[UIScreen mainScreen] applicationFrame].size.height);
    self.player.view.frame = self.bounds;

    self.player.scalingMode = IJKMPMovieScalingModeAspectFit; //缩放模式
    self.player.shouldAutoplay = YES; //开启自动播放

    self.autoresizesSubviews = YES;
    [self addSubview:self.player.view];
    [self.player prepareToPlay];
    // Do any additional setup after loading the view, typically from a nib.


  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  self.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width,
                             [[UIScreen mainScreen] applicationFrame].size.height);

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

@end
