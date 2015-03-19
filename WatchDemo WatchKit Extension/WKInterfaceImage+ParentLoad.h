//
//  WKInterfaceImage+ParentLoad.h
//  WatchDemo
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface WKInterfaceImage (ParentLoad)
- (void)loadImageWithURLString:(NSString *)urlString placeholder:(UIImage *)image;
@end
