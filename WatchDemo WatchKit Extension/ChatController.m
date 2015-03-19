//
//  ChatController.m
//  WatchDemo
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "ChatController.h"
#import "MessageRowController.h"
#import "WKInterfaceImage+ParentLoad.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordController.h"

typedef enum {
    MessageSourceIncoming = 1,
    MessageSourceOutgoing = 2
} MessageSource;

typedef enum {
    MessageTypeText = 1,
    MessageTypeVoice = 2,
    MessageTypeImage = 3
} MessageType;

@interface ChatController () <AVAudioPlayerDelegate, RecordControllerDelegate>
@property (strong, nonatomic) NSString *shouldSendVoice;
@end

@implementation ChatController {
    NSDictionary *_chat;
    NSMutableArray *_messages;
    AVAudioPlayer *_player;
}

- (void)dealloc
{
    _chat = nil;
    _messages = nil;
    _player.delegate = nil;
    _player = nil;
}

- (void)awakeWithContext:(id)context
{
    _chat = context;
    [self setupTable];
}

- (void)willActivate
{
    [_table scrollToRowAtIndex:_table.numberOfRows - 1];
    if (_shouldSendVoice) {
        NSDictionary *messageDic = @{@"source":@(MessageSourceOutgoing), @"type":@(MessageTypeVoice), @"path":_shouldSendVoice};
        [_messages addObject:messageDic];
        [self insertRowForMessage:messageDic];
        _shouldSendVoice = nil;
    }
}

- (void)setupTable
{
    _messages = [NSMutableArray array];
    for (int i = 0; i < rand()%20; i++) {
        [_messages addObject:@{@"msg":@[@"Hi", @"OK", @"Nice to meet you", @"Fine"][rand()%4], @"source":@(rand()%2), @"type":@(rand()%3)}];
    }
    
    //先清空预置的row
    [_table removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _table.numberOfRows)]];
    for (int i = 0; i < _messages.count; i++) {
        NSDictionary *messageDic = _messages[i];
        [self insertRowForMessage:messageDic];
    }
}

- (void)insertRowForMessage:(NSDictionary *)messageDic
{
    [_table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:_table.numberOfRows] withRowType:[self rowTypeForMessage:messageDic]];
    MessageRowController *mrc = [_table rowControllerAtIndex:_table.numberOfRows - 1];
    if ([messageDic[@"type"] intValue] == MessageTypeText) {
        [mrc.label setText:messageDic[@"msg"]];
    } else if ([messageDic[@"type"] intValue] == MessageTypeVoice) {
        
    } else {
        [mrc.image loadImageWithURLString:@"http://tp3.sinaimg.cn/1657938842/180/5704612869/1" placeholder:nil];
    }
}

- (NSString *)rowTypeForMessage:(NSDictionary *)messageDic
{
    NSMutableString *rowType = [NSMutableString string];
    if ([messageDic[@"source"] intValue] == MessageSourceIncoming) {
        [rowType appendString:@"Incoming"];
    } else {
        [rowType appendString:@"Outgoing"];
    }
    
    if ([messageDic[@"type"] intValue] == MessageTypeText) {
        [rowType appendString:@"Text"];
    } else if ([messageDic[@"type"] intValue] == MessageTypeVoice) {
        [rowType appendString:@"Voice"];
    } else {
        [rowType appendString:@"Image"];
    }
    return rowType;
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSDictionary *messageDic = _messages[rowIndex];
    if ([messageDic[@"type"] intValue] == MessageTypeVoice)
    {
        NSError *error = nil;
        // 如果是网络语音，你需要下载语音，和图片一样，通过OpenParent下载好后传回来就行了，这里不多写了
        NSData *data = nil;
        if (messageDic[@"path"]) {
            data = [NSData dataWithContentsOfFile:messageDic[@"path"]];
        }
        if (!data) {
            data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"send" ofType:@"mp3"]];
        }
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&error];
        player.delegate = self;
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        [_player stop];
        _player = nil;
        [player play];
        _player = player;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{

}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{

}

- (IBAction)textBtnPressed {
    [self presentTextInputControllerWithSuggestions:@[@"Hello", @"Hi"] allowedInputMode:WKTextInputModeAllowAnimatedEmoji completion:^(NSArray *results) {
        if (results.count > 0) {
            NSDictionary *messageDic = @{@"msg":results.firstObject, @"source":@(MessageSourceOutgoing), @"type":@(MessageTypeText)};
            [_messages addObject:messageDic];
            [self insertRowForMessage:messageDic];
        }
    }];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier
{
    return self;
}

- (void)recordControllerDidFinishRecording:(RecordController *)controller localPath:(NSString *)localPath
{
    NSLog(@"%@", localPath);
    self.shouldSendVoice = localPath;
    [self dismissController];
}
@end
