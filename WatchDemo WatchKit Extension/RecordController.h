//
//  RecordController.h
//  MingdaoV2
//
//  Created by Wee Tom on 15/3/13.
//  Copyright (c) 2015年 Mingdao. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@class RecordController;
@protocol RecordControllerDelegate <NSObject>
- (void)recordControllerDidFinishRecording:(RecordController *)controller localPath:(NSString *)localPath;
@end

@interface RecordController : WKInterfaceController
@property (strong, nonatomic) id<RecordControllerDelegate> delegate;
@end
