# AudioRecorder
使用AVFoundation实现的录音、播放

### 说明
去年一个项目里用到了录音、播放功能，这个repo是从把当时的实现稍作了一些修改。因为在那个项目里，有音频、视频、图片多媒体资源，当时实现录音、播放功能跟这些多媒体资源的缓存管理结合比较紧密。音频文件的存放路径，直接从缓存管理模块中取。

另外，为了跟安卓端互通，同时减少音频文件的大小。所以，录音时，把录出来的wav格式转换成了amr格式。播放时，从服务器获取的是amr格式，转成amr格式后播放。

### 使用方法
实例化：

~~~objc
_audioManager = [AudioManager sharedInstance];
~~~

#### 录音
请求录音（访问麦克风）的权限：

~~~objc
[_audioManager requestRecordPermission];
~~~

开始录音:

~~~ojbc
[_audioManager startRecordingWithPath:path];
~~~

暂停录音：

~~~objc
[_audioManager pauseRecording];
~~~

继续暂停的录音：

~~~objc
[_audioManager resumeRecording];
~~~

停止录音：

~~~objc
NSDictionary *dict = [_audioManager stopRecording];
~~~

返回的字典中包含录音的时长、录音文件存放的路径，对应的key分别为`AudioManagerRecordTimeLength`、`AudioManagerRecordPath `。

取消录音:

~~~objc
[_audioManager cancelRecording];
~~~

#### 播放
注意：考虑到.wav格式的大小，及与Android互通的需求，所以，从服务器获取的、及录音后存在沙盒里的都是.amr格式。

播放设备上的录音（.amr)：

~~~objc
[_audioManager playAudioAtPath:audioPath];
~~~

从远端下载一个amr文件，并播放：

~~~objc
[_audioManger playDuioAtURLString:urlStr locationToPath:path];
~~~

停止播放：

~~~objc
[_auidoManager stopPlay];
~~~

暂停播放：

~~~objc
[_audioManger pausePlay];
~~~

继续播放：

~~~objc
[_audioManager resumePlay];
~~~

####`AudioManagerDelegate`协议
录音是否成功完成：

~~~objc
- (void)audioManager:(AudioManager *)manager didFinishRecordSuccessfully:(BOOL)success;
~~~

音频是否成功播放完成：

~~~objc
- (void)audioManager:(AudioManager *)manager didFinishPlaySuccessfully:(BOOL)success;
~~~

播放进度：

~~~objc
- (void)audioManager:(AudioManager *)manager
        playProgress:(NSTimeInterval)progress
      totoalDuration:(NSTimeInterval)totalDuration;
~~~