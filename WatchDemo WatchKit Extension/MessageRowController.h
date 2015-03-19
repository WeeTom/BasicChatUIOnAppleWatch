//
//  MessageRowController.h
//  WatchDemo
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface MessageRowController : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *label;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;

@end
