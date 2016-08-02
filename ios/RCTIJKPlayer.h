#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
/* @class IJKMediaControl; */

@class RCTIJKPlayerManager;

@interface RCTIJKPlayer : UIView

@property(atomic,strong) NSURL *url;
@property(atomic, retain) id<IJKMediaPlayback> player;
//@property(nonatomic,strong) IBOutlet IJKMediaControl *mediaControl;


- (id)initWithManager:(RCTIJKPlayerManager*)manager bridge:(RCTBridge *)bridge;
- (void)startWithOptions:(NSDictionary *)options;
- (void)stop;
- (void)resume;
- (void)pause;
- (void)shutdown;
- (void)seekTo:(NSTimeInterval)currentPlaybackTime;
@end
