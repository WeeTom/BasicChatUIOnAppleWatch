//
//  ChatRowController.h
//  WatchDemo
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#include <WatchKit/WatchKit.h>

@interface ChatRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceImage *avatarImage;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *nameLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *unreadLabel;

@end
