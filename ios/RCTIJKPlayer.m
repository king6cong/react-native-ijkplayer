#import "RCTBridge.h"
#import "RCTIJKPlayer.h"
#import "RCTIJKPlayerManager.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"

#import "UIView+React.h"

@interface RCTIJKPlayer ()

@property (nonatomic, weak) RCTIJKPlayerManager *manager;
@property (nonatomic, weak) RCTBridge *bridge;

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

@end
