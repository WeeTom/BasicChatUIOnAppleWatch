//
//  WKInterfaceImage+ParentLoad.m
//  WatchDemo
//
//  Created by Wee Tom on 15/3/19.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import "WKInterfaceImage+ParentLoad.h"

@implementation WKInterfaceImage (ParentLoad)
- (void)loadImageWithURLString:(NSString *)urlString placeholder:(UIImage *)image
{
    [self setImage:image];
    if (!urlString) {
        return;
    }
    [WKInterfaceController openParentApplication:@{@"key":@"loadImage", @"urlString":urlString} reply:^(NSDictionary *replyInfo, NSError *error) {
        NSData *data = replyInfo[@"result"];
        [self setImageData:data];
    }];
}
@end
