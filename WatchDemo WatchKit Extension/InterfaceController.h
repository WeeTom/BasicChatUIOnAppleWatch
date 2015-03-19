//
//  InterfaceController.h
//  WatchDemo WatchKit Extension
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (strong, nonatomic) NSMutableArray *chats;
@end
