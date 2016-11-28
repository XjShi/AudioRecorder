//
//  VoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"

@implementation VoiceConverter

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath{
    
    if (! DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0;
    
    return 1;
}

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath{
    
    if (EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    
    return 1;
}

+ (NSString *)amrToWav:(NSString*)filePath{
    
    
    
    NSString *savePath = [filePath stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"];
    
    if (! DecodeAMRFileToWAVEFile([filePath cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return nil;
    
    return savePath;
}

+ (NSString *)wavToAmr:(NSString *)filePath{
    
    
    
    // WAVE音频采样频率是8khz
    // 音频样本单元数 = 8000*0.02 = 160 (由采样频率决定)
    // 声道数 1 : 160
    //        2 : 160*2 = 320
    // bps决定样本(sample)大小
    // bps = 8 --> 8位 unsigned char
    //       16 --> 16位 unsigned short
    
    
    NSString *savePath = [filePath stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"];     
    if (EncodeWAVEFileToAMRFile([filePath cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return savePath;
    
    
    return nil;
}
//3gp转wav
+ (NSString *)threegpToWav:(NSString*)filePath{
    
    
    
    NSString *savePath = [filePath stringByReplacingOccurrencesOfString:@"3gp" withString:@"wav"];
    
    if (! DecodeAMRFileToWAVEFile([filePath cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return nil;
    
    return savePath;
}
//wav转3gp
+ (NSString *)wavTo3gp:(NSString *)filePath{
    
    
    
    // WAVE音频采样频率是8khz
    // 音频样本单元数 = 8000*0.02 = 160 (由采样频率决定)
    // 声道数 1 : 160
    //        2 : 160*2 = 320
    // bps决定样本(sample)大小
    // bps = 8 --> 8位 unsigned char
    //       16 --> 16位 unsigned short
    
    
    NSString *savePath = [filePath stringByReplacingOccurrencesOfString:@"wav" withString:@"3gp"];
    NSLog(@"预期存储路径:%@",savePath);
    if (EncodeWAVEFileToAMRFile([filePath cStringUsingEncoding:NSASCIIStringEncoding], [savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return savePath;
    
    
    return nil;
}

@end
