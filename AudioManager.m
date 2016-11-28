//
//  AudioManager.m
//  Audio Recoder
//
//  Created by xjshi on 15/8/2015.
//  Copyright © 2015 sxj. All rights reserved.
//

#import "AudioManager.h"
#import "VoiceConverter.h"

#define kErrorLog(err) NSLog(@"error:%ld,%@",(long)err.code,err.localizedDescription);

NSString *const AudioManagerRecordTimeLength = @"recordTimeLength";
NSString *const AudioManagerRecordPath = @"recordPath";

@interface AudioManager ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSURL *recordPathURL;

@end

@implementation AudioManager

+ (AudioManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static AudioManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - 录音
/**
 *  请求录音权限
 *
 *  @return YES:允许。NO：拒绝
 */
- (BOOL)requestRecordPermission
{
    __block BOOL permission;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        permission = granted;
    }];
    return permission;
}

//开始录音
- (void)startRecordingWithPath:(NSString *)path
{
    if (![self requestRecordPermission] || _audioRecorder.recording) {
        return;
    }
    [self setAudioSessionCategory:AVAudioSessionCategoryRecord];
//    NSString *path = [[[EBCacheManager defaultManager] pathForCacheType:AudioCacheType] stringByAppendingPathComponent:[[self stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"wav"]];
    _recordPathURL = [NSURL URLWithString:path];
    NSError *err;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordPathURL settings:[self settingForRecordingSession] error:&err];
    if (_audioRecorder == nil) {
        NSLog(@"err:%@",err.localizedDescription);
        return;
    }
    _audioRecorder.delegate = self;
    
    [_audioRecorder prepareToRecord];
    [_audioRecorder record];
}

/**
 *  停止录音
 *
 *  @return 返回字典包含录音长度（AudioManagerRecordTimeLength），录音存放的路径(AudioManagerRecordPath)
 */
- (NSDictionary *)stopRecording
{
    if (!_audioRecorder.isRecording) {
        return nil;
    }
    NSTimeInterval timeLength = _audioRecorder.currentTime;
    if (timeLength < 1) {
        [_audioRecorder stop];
        return nil;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    @try {
        [dict setObject:[NSNumber numberWithDouble:timeLength] forKey:AudioManagerRecordTimeLength];
        [_audioRecorder stop];
        NSString *amrPath = [VoiceConverter wavToAmr:_recordPathURL.absoluteString];
        [dict setObject:amrPath forKey:AudioManagerRecordPath];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
    }
    @finally {
        
    }
    return dict;
}

//暂停录音
- (void)pauseRecording
{
    [_audioRecorder pause];
}

//重新开始录音
- (void)resumeRecording
{
    [_audioRecorder record];
}

/**
 *  取消录音
 */
- (void)cancelRecording
{
    [_audioRecorder stop];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err = nil;
    [fileManager removeItemAtURL:_recordPathURL error:&err];
}

//当前录音时间
- (NSTimeInterval)currentTimeOfRecording
{
    return [_audioRecorder currentTime];
}

#pragma mark - 播放
/**
 *  播放放在path处的音频文件
 *
 *  @param path 音频文件所在的绝对路径
 */
- (void)playAudioAtPath:(NSString *)path
{
    if (_audioPlayer != nil && _audioPlayer.isPlaying) {
        [_audioPlayer stop];
    }
    @try {
        [self setAudioSessionCategory:AVAudioSessionCategoryPlayback];
        NSError *err = nil;
        NSString *wavPath = [VoiceConverter amrToWav:path];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:wavPath] error:&err];
        _audioPlayer.delegate = self;
        if (_audioPlayer == nil) {
            kErrorLog(err);
        } else {
            [_audioPlayer prepareToPlay];
            [_audioPlayer play];
            [self initAndFirePlayTimer];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)playAudioAtURLString:(NSString *)urlString locationToPath:(NSString *)path
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *path = [[[EBCacheManager defaultManager] pathForCacheType:AudioCacheType] stringByAppendingPathComponent:[[self stringFromDate:[NSDate date]] stringByAppendingPathExtension:@"amr"]];
        if  ([data writeToFile:path atomically:YES]) {
//            NSString *wavPath = [VoiceConverter amrToWav:path];
            [self playAudioAtPath:path];
        }
    }];
    [dataTask resume];
}

/**
 *  停止播放
 */
- (void)stopPlay
{
    [_audioPlayer stop];
    [_playTimer invalidate];
}

/**
 *  暂停播放
 */
- (void)pausePlay
{
    [_audioPlayer pause];
    [_playTimer invalidate];
}

//重新开始播放
- (void)resumePlay
{
    [_audioPlayer play];
    [self initAndFirePlayTimer];
}

//音频时长
- (NSTimeInterval)audioDuration
{
    return _audioPlayer.duration;
}

//当前播放时间
- (NSTimeInterval)currentTimeOfPlay
{
    return _audioPlayer.currentTime;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_playTimer invalidate];
    if ([self.delegate respondsToSelector:@selector(audioManager:didFinishPlaySuccessfully:)]) {
        [self.delegate audioManager:self didFinishPlaySuccessfully:flag];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(audioManager:didFinishRecordSuccessfully:)]) {
        [self.delegate audioManager:self didFinishRecordSuccessfully:flag];
    }
}

#pragma mark - Private Method
- (BOOL)fileExistsAtPath:(NSString *)path
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    return [fileManger fileExistsAtPath:path];
}

- (void)setAudioSessionCategory:(NSString *)category
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *err = nil;
    if (![audioSession setActive:NO error:&err]) {
        kErrorLog(err);
    }
    if (![audioSession setCategory:category error:&err]) {
        kErrorLog(err);
    }
    if (![audioSession setActive:YES error:&err]) {
        kErrorLog(err);
    }
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    return [dateFormater stringFromDate:date];
}

/**
 *  录音设置
 */
- (NSDictionary *)settingForRecordingSession
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:8000],AVSampleRateKey,
            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
            nil];
}

/**
 *  重新启动播放录音的定时器
 */
- (void)initAndFirePlayTimer
{
    if (_playTimer != nil) {
        [_playTimer invalidate];
        
    }
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                  target:self
                                                selector:@selector(timerStart:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)timerStart:(NSTimer *)timer
{
    if ([self.delegate respondsToSelector:@selector(audioManager:playProgress:totoalDuration:)]) {
        [self.delegate audioManager:self playProgress:self.currentTimeOfPlay totoalDuration:self.audioDuration];
    }
}
@end

