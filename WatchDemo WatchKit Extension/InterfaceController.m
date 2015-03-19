//
//  InterfaceController.m
//  WatchDemo WatchKit Extension
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "InterfaceController.h"
#import "ChatRowController.h"
#import "WKInterfaceImage+ParentLoad.h"

@interface InterfaceController()
@end


@implementation InterfaceController
- (void)dealloc
{
    _chats = nil;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self loadData];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadData
{
    _chats = [@[@{@"id":@"1", @"avatar":@"http://tp3.sinaimg.cn/1657938842/180/5704612869/1", @"name":@"Tom", @"count":@(81)}, @{@"id":@"2", @"avatar":@"http://tp3.sinaimg.cn/1657938842/180/5704612869/1", @"name":@"Cruise", @"count":@(49)}, @{@"id":@"3", @"avatar":@"http://tp3.sinaimg.cn/1657938842/180/5704612869/1", @"name":@"Lily", @"count":@(1)}] mutableCopy];
    // do some api to load chat data and then:
    [_table setNumberOfRows:_chats.count withRowType:@"Chat"];
    for (int i = 0; i < _table.numberOfRows; i++) {
        ChatRowController *crc = [_table rowControllerAtIndex:i];
        
        NSDictionary *dic = self.chats[i];
        NSString *avatar = dic[@"avatar"];
        NSString *name = dic[@"name"];
        int count = [dic[@"count"] intValue];
        
        [crc.avatarImage loadImageWithURLString:avatar placeholder:nil];
        [crc.nameLabel setText:name];
        [crc.unreadLabel setText:[NSString stringWithFormat:@"%d unread", count]];
    }
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex
{
    return _chats[rowIndex];
}
@end



