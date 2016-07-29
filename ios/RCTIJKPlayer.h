#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@class RCTIJKPlayerManager;

@interface RCTIJKPlayer : UIView

- (id)initWithManager:(RCTIJKPlayerManager*)manager bridge:(RCTBridge *)bridge;
- (void)start;
- (void)startWithURL:(NSString *)pushURL;
- (void)stop;
- (void)mute;
- (void)resume;
@end
