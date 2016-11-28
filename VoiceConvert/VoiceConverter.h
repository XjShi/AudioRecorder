//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath;

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;

+ (NSString *)amrToWav:(NSString*)filePath;
+ (NSString *)wavToAmr:(NSString*)filePath;

//3gp转wav
+ (NSString *)threegpToWav:(NSString*)filePath;
//wav转3gp
+ (NSString *)wavTo3gp:(NSString *)filePath;
@end
