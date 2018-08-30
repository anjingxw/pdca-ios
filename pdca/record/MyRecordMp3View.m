//
//  MyRecordMp3View.m
//  pdca
//
//  Created by caowk on 2017/11/24.
//  Copyright © 2017年 glimlab. All rights reserved.
//

#import "MyRecordMp3View.h"
#import <UIKit/UIKit.h>
#import "XHVoiceRecordHUD.h"
#import "XHVoiceRecordHelper.h"
#import "XHFoundationMacro.h"
#import "XHAudioPlayerHelper.h"

typedef void(^FinishRecordMp3)(NSString* base64);

@interface MyRecordMp3View ()<XHAudioPlayerHelperDelegate>

@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UILabel *playIng;
@property (nonatomic, weak) XHVoiceRecordHUD *record;
@property (nonatomic, weak) UIButton *doAction;
@property (nonatomic, weak) UIButton *ok;
@property (nonatomic, weak) UIButton *cancel;
@property (nonatomic, strong) XHVoiceRecordHelper *voiceRecordHelper;

@property (nonatomic, weak) UIButton *close;
/**
 *  判断是不是超出了录音最大时长
 */
@property (nonatomic) BOOL isMaxTimeStop;
@property (nonatomic, assign) BOOL myRecord;
@property (nonatomic, assign) BOOL myRecordFinish;
@property (nonatomic, assign) BOOL myPlay;


@end

@implementation MyRecordMp3View

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self setUpListener];
    }
    return self;
}

- (void)startAtView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
    self.center = center;
    [view addSubview:self];
}


- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    
    if (!_close) {
        UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(190, 20, 40, 20)];
        close.backgroundColor = [UIColor grayColor];
        close.layer.masksToBounds = YES;
        close.layer.cornerRadius = 10;
        close.titleLabel.font =  [UIFont systemFontOfSize:12];
        [close setTitle:@"关闭" forState:UIControlStateNormal];
        [close setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [close setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:close];
        _close = close;
    }
    
    if (!_playIng) {
        UILabel *playIng= [[UILabel alloc] initWithFrame:CGRectMake(60, 40, 120, 20)];
        playIng.textColor = [UIColor blackColor];
        playIng.font = [UIFont systemFontOfSize:18];
        playIng.layer.masksToBounds = YES;
        playIng.layer.cornerRadius = 4;
        playIng.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        playIng.backgroundColor = [UIColor clearColor];
        playIng.text = @"播放";
        playIng.textAlignment = NSTextAlignmentCenter;
        [self addSubview:playIng];
        _playIng = playIng;
    }
    
    if (!_timeLabel) {
        UILabel *timeLabel= [[UILabel alloc] initWithFrame:CGRectMake(60, 70, 120, 20)];
        timeLabel.textColor = [UIColor blackColor];
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.layer.masksToBounds = YES;
        timeLabel.layer.cornerRadius = 4;
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"00:00";
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:timeLabel];
        _timeLabel = timeLabel;
    }
    
    if (!_doAction) {
        UIButton *doAction = [[UIButton alloc] initWithFrame:CGRectMake(60, 190, 120 ,120)];
        doAction.layer.masksToBounds = YES;
        doAction.layer.cornerRadius = 60;
        [doAction setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        doAction.backgroundColor = [UIColor grayColor];
        [doAction setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [doAction setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [doAction setTitle:@"按住说话" forState:UIControlStateNormal];
        [doAction setTitle:@"松开停止" forState:UIControlStateHighlighted];
        [self addSubview:doAction];
        _doAction = doAction;
        [XHAudioPlayerHelper shareInstance].delegate = self;
    }
    
    if (!_cancel) {
        UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(40, 330, 80, 35)];
        cancel.backgroundColor = [UIColor grayColor];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cancel.bounds   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft  cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = cancel.bounds;
        maskLayer.path = maskPath.CGPath;
        cancel.layer.mask = maskLayer;
        [self addSubview:cancel];
        _cancel = cancel;
    }
    if (!_ok) {
        UIButton *ok = [[UIButton alloc] initWithFrame:CGRectMake(120, 330, 80, 35)];
        ok.backgroundColor = [UIColor grayColor];
        [ok setTitle:@"确定" forState:UIControlStateNormal];
        [ok setBackgroundImage:[MyRecordMp3View createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [ok setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:ok.bounds   byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight  cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = ok.bounds;
        maskLayer.path = maskPath.CGPath;
        ok.layer.mask = maskLayer;
        [self addSubview:ok];
        _ok = ok;
    }
    self.playIng.hidden = YES;
    self.timeLabel.hidden = YES;
    self.ok.hidden = YES;
    self.cancel.hidden = YES;
}

- (void)setUpListener{
    [self.doAction  addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.doAction  addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.doAction  addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.doAction  addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.doAction  addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
    
    [self.cancel addTarget:self action:@selector(cancelRecord) forControlEvents:UIControlEventTouchDown];
    
    [self.ok addTarget:self action:@selector(finishRecord) forControlEvents:UIControlEventTouchDown];
    [self.close addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchDown];
}

-(void)finishRecord{
    if(_myRecordFinish){
        _finish([self mp3ToBASE64:self.voiceRecordHelper.recordPath]);
        [self cancelRecord];
        self.hidden = YES;
    }
}

+(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)startRecord {
    //[[XHAudioPlayerHelper shareInstance] stopAudio];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:^{
    }];
}

- (XHVoiceRecordHelper *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        
        WEAKSELF
        _voiceRecordHelper = [[XHVoiceRecordHelper alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            DLog(@"已经达到最大限制时间了，进入下一步的提示");
            weakSelf.isMaxTimeStop = YES;
            [weakSelf finishRecorded];
        };
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            weakSelf.record.peakPower = peakPowerForChannel;
        };
        _voiceRecordHelper.recondSecond = ^(int second, bool tip){
            weakSelf.record.remind2Label.text = [weakSelf timeFormatted:second];
            weakSelf.record.remind2Label.textColor = tip?[UIColor redColor]:[UIColor whiteColor];
        };
        _voiceRecordHelper.maxRecordTime = 120;
    }
    return _voiceRecordHelper;
}

- (void)finishRecorded {
    self.myRecord = NO;
    self.myRecordFinish  = YES;
    self.ok.hidden = NO;
    self.cancel.hidden = NO;
    [self.record stopRecordCompled:^(BOOL fnished) {
        self.record.hidden = YES;
        self.playIng.hidden = NO;
        self.timeLabel.hidden = NO;
    }];
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        self.timeLabel.text = [self timeFormattedD:self.voiceRecordHelper.recordDuration];
        [self.doAction setTitle:@"播放" forState:UIControlStateNormal];
        [self.doAction setTitle:@"播放" forState:UIControlStateHighlighted];
    }];
}
- (NSString *)getRecorderPath {
    NSString *recorderPath = nil;
    recorderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    recorderPath = [recorderPath stringByAppendingFormat:@"%@-MySound.wav", [dateFormatter stringFromDate:now]];
    NSLog(@"%@", recorderPath);
    return recorderPath;
}

- (void)holdDownButtonTouchDown{
    if(self.myRecordFinish){
        if (!self.myPlay) {
            [[XHAudioPlayerHelper shareInstance] managerAudioWithFileName:self.voiceRecordHelper.recordPath toPlay:YES];
            self.myPlay = TRUE;
        }else{
            [[XHAudioPlayerHelper shareInstance] stopAudio];
            self.myPlay = NO;
        }
        return;
    }
    if (!self.myRecord) {
        [self.voiceRecordHelper prepareRecordingWithPath:[self getRecorderPath] prepareRecorderCompletion:^BOOL{
            [self startRecord];
            self.myRecord = YES;
            return true;
        }];
    }
}

-(void)holdDownButtonTouchUpOutside{
    if (self.myRecord) {
        [self.record stopRecordCompled:^(BOOL fnished) {
        }];
        self.myRecord = NO;
        [self cancelRecord];
    }
}

-(void)holdDownButtonTouchUpInside{
    if (self.myRecord) {
        [self finishRecorded];
        [self.record configRecoding:YES];
    }
}

- (void)holdDownDragOutside {
    if (self.myRecord) {
        [self.record resaueRecord];
    }

}

- (void)holdDownDragInside {
    if (self.myRecord) {
        [self.record pauseRecord];
    }
}

- (void)cancelRecord{
    self.myRecordFinish = NO;
    self.ok.hidden = YES;
    self.cancel.hidden = YES;
    [self.doAction setTitle:@"按住说话" forState:UIControlStateNormal];
    [self.doAction setTitle:@"松开停止" forState:UIControlStateHighlighted];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:^{
        self.playIng.hidden = YES;
        self.timeLabel.hidden = YES;
       [self.record removeFromSuperview];
        self.record = nil;
    }];
    [[XHAudioPlayerHelper shareInstance]stopAudio];
    self.hidden = YES;
}

- (XHVoiceRecordHUD*)record{
    if (!_record) {
        XHVoiceRecordHUD *record = [[XHVoiceRecordHUD alloc]initWithFrame:CGRectMake(50, 20, 140, 140)];
        [self addSubview:record];
        [record configRecoding:YES];
        _record = record;
    }
    return _record;
}
- (NSString *)timeFormatted:(int)totalSeconds{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}
- (NSString *)timeFormattedD:(NSTimeInterval)totalSeconds{
    NSInteger intS = totalSeconds;
    int seconds = intS % 60;
    int minutes = (intS / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
}

- (void)didAudioPlayerBeginPlay:(AVAudioPlayer*)audioPlayer{
    [self.doAction setTitle:@"暂停" forState:UIControlStateNormal];
    [self.doAction setTitle:@"暂停" forState:UIControlStateHighlighted];
}
- (void)didAudioPlayerStopPlay:(AVAudioPlayer*)audioPlayer{
    if (self.myPlay) {
        self.myPlay = NO;
        [self.doAction setTitle:@"播放" forState:UIControlStateNormal];
        [self.doAction setTitle:@"播放" forState:UIControlStateHighlighted];
        self.timeLabel.text = [self timeFormattedD:audioPlayer.duration];
    }
}
- (void)didAudioPlayerTimer:(AVAudioPlayer*)audioPlayer{
    NSString *test = [NSString stringWithFormat:@"%@/%@",[self timeFormattedD:audioPlayer.currentTime], [self timeFormattedD:audioPlayer.duration]];
    self.timeLabel.text = test;
}
- (void)didAudioPlayerPausePlay:(AVAudioPlayer*)audioPlayer{
    
}
- (NSString *)mp3ToBASE64:(NSString*) mp3Path{
    NSData *mp3Data = [NSData dataWithContentsOfFile:mp3Path];
    NSString *_encodedImageStr = [mp3Data base64Encoding];
    return _encodedImageStr;
}

-(void)closeSelf{
    if (_finish != nil) {
        _finish(nil);
    }
    self.hidden = YES;
}

@end
