//
//  RecordController.m
//  MingdaoV2
//
//  Created by Wee Tom on 15/3/13.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "RecordController.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordController() <AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *statusLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *ringImage;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) NSString *path;
@property (assign, nonatomic) BOOL recording, recorded, uploading, uploaded;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int recordTime;
@end


@implementation RecordController
- (void)dealloc
{
    [_recorder stop];
    _recorder = nil;
    _path = nil;
    [_timer invalidate];
    _timer = nil;
}

- (void)awakeWithContext:(id<RecordControllerDelegate>)context {
    [super awakeWithContext:context];
    _delegate = context;
    [_statusLabel setText:@"Tap to start"];
    // Configure interface objects here.
    NSDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    // You can change the settings for the voice quality
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *filePathAndDirectory = [[path stringByReplacingOccurrencesOfString:@"file://" withString:@""] stringByAppendingFormat:@"%@/", @"record"];
    NSError *error1 = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error1])
    {
        //        NSLog(@"Create directory error: %@", error1);
    }
    NSDateFormatter *fm = [[NSDateFormatter alloc] init];
    [fm setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@.pcm", filePathAndDirectory, [fm stringFromDate:[NSDate date]]];
    _path = urlString;
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *err = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if (!_recorder) {
        NSLog(@"%@", err);
    }
    [self btnPressed];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)btnPressed {
    if (!_recording) {
        [_timer invalidate];
        _timer = nil;
        _recordTime = 1;
        [_statusLabel setText:@"Tap to Send"];
        [_ringImage setImageNamed:@"ring"];
        [_ringImage startAnimatingWithImagesInRange:NSMakeRange(1, 60) duration:60 repeatCount:1];
        _recording = YES;
        [_recorder record];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
    } else {
        [_timer invalidate];
        _timer = nil;
        [_statusLabel setText:@"Uploading"];
//        [_ringImage stopAnimating];
        NSString *imageFileName = [NSString stringWithFormat:@"ring%02d.png", _recordTime];
        NSLog(@"%@", imageFileName);
        [_ringImage setImageNamed:imageFileName];
        _recorded = YES;
        _recording = NO;
        [_recorder stop];
        [self uploadVoice];
    }
}

- (void)updateMeters {
    _recordTime += 1;
    if (_recordTime > 59) {
        [self btnPressed];
    }
}

- (void)uploadVoice
{
    _uploading = NO;
    _uploaded = YES;
    [_delegate recordControllerDidFinishRecording:self localPath:_path];
}
@end