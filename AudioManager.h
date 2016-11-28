//
//  AudioManager.h
//  Audio Recoder
//
//  Created by xjshi on 15/8/2015.
//  Copyright © 2015 sxj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AudioManager;
@protocol AudioManagerDelegate <NSObject>
@optional
/**
 *  音频播放完成
 *
 *  @param success YES:播放成功；NO:因为无法解码音频数据而停止播放
 */
- (void)audioManager:(AudioManager *)manager didFinishPlaySuccessfully:(BOOL)success;
/**
 *  录音完成
 */
- (void)audioManager:(AudioManager *)manager didFinishRecordSuccessfully:(BOOL)success;
/**
 *  播放进度
 *
 *  @param progress         已经播放的时间
 *  @param totalDuration    总时长
 */
- (void)audioManager:(AudioManager *)manager
        playProgress:(NSTimeInterval)progress
      totoalDuration:(NSTimeInterval)totalDuration;
@end

extern NSString *const AudioManagerRecordTimeLength;
extern NSString *const AudioManagerRecordPath;

@interface AudioManager : NSObject <AVAudioRecorderDelegate,AVAudioPlayerDelegate>

/**
 *  这个timer，在不在使用录音／播放功能时，需要释放
 **/
@property (nonatomic, strong, readonly) NSTimer *playTimer;

+ (AudioManager *)sharedInstance;
/**
 *  请求录音权限
 */
- (BOOL)requestRecordPermission;
/**
 *  开始录音
 */
- (void)startRecordingWithPath:(NSString *)path;
/**
 *  继续暂停的录音
 */
- (void)resumeRecording;
/**
 *  停止录音
 *
 *  @return 返回字典包含录音长度（AudioManagerRecordTimeLength），录音存放的路径(AudioManagerRecordPath)
 */
- (NSDictionary *)stopRecording;
/**
 *  暂停录音
 */
- (void)pauseRecording;
/**
 *  取消录音
 */
- (void)cancelRecording;
/**
 *  播放录音(仅支持amr)
 *
 *  @param path 录音文件的路径
 */
- (void)playAudioAtPath:(NSString *)path;
/**
 *  播放网络上的某个音频（仅支持amr）
 *
 * @param urlString 文件url
 * @param path      文件下载之后放的位置
 */
- (void)playAudioAtURLString:(NSString *)urlString locationToPath:(NSString *)path;
/**
 *  停止播放
 */
- (void)stopPlay;
/**
 *  暂停播放
 */
- (void)pausePlay;
/**
 *  继续播放
 */
- (void)resumePlay;

@property (nonatomic,weak) id<AudioManagerDelegate> delegate;
/**
 *  当前已经播放的时间
 */
@property (readonly) NSTimeInterval currentTimeOfPlay;
/**
 *  音频文件总时长
 */
@property (readonly) NSTimeInterval audioDuration;
/**
 *  当前录音时长
 */
@property (readonly) NSTimeInterval currentTimeOfRecording;
@end
