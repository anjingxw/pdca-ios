#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVAudioPlayer.h>
#import <UIKit/UIKit.h>

#import "XHMacro.h"

@protocol XHAudioPlayerHelperDelegate <NSObject>

@optional
- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer;
- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer;
- (void)didAudioPlayerTimer:(AVAudioPlayer*)audioPlayer;
- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer;

@end

@interface XHAudioPlayerHelper : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, copy) NSString *playingFileName;

@property (nonatomic, assign) id <XHAudioPlayerHelperDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *playingIndexPathInFeedList;//给动态列表用

@property (nonatomic, strong) NSTimer *timer;

+ (XHAudioPlayerHelper*)shareInstance;

- (AVAudioPlayer*)player;
- (BOOL)isPlaying;

- (void)managerAudioWithFileName:(NSString*)amrName toPlay:(BOOL)toPlay;
- (void)pausePlayingAudio;//暂停
- (void)stopAudio;//停止



@end


