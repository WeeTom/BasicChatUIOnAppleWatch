#效果
![image](https://github.com/WeeTom/BasicChatUIOnAppleWatch/blob/master/images/demo.gif?raw=true)

#截图
![image](https://github.com/WeeTom/BasicChatUIOnAppleWatch/blob/master/images/iOS%20Simulator%20Screen%20Shot%20-%20Apple%20Watch%202015%E5%B9%B43%E6%9C%8819%E6%97%A5%2017.29.30.png?raw=true)![image](https://github.com/WeeTom/BasicChatUIOnAppleWatch/blob/master/images/iOS%20Simulator%20Screen%20Shot%20-%20Apple%20Watch%202015%E5%B9%B43%E6%9C%8819%E6%97%A5%2017.29.40.png?raw=true)![image](https://github.com/WeeTom/BasicChatUIOnAppleWatch/blob/master/images/iOS%20Simulator%20Screen%20Shot%20-%20Apple%20Watch%202015%E5%B9%B43%E6%9C%8819%E6%97%A5%2017.29.53.png?raw=true)![image](https://github.com/WeeTom/BasicChatUIOnAppleWatch/blob/master/images/iOS%20Simulator%20Screen%20Shot%20-%20Apple%20Watch%202015%E5%B9%B43%E6%9C%8819%E6%97%A5%2017.30.01.png?raw=true)![image](https://github.com/WeeTom/BasicChatUIOnAppleWatch/blob/master/images/iOS%20Simulator%20Screen%20Shot%20-%20Apple%20Watch%202015%E5%B9%B43%E6%9C%8819%E6%97%A5%2017.30.39.png?raw=true)


#1-3. 都是废话，删了
#4. Start
App结构：
	
	1. 消息列表 InterdaceController(IC) 用来展示未读消息总览
	2. 聊天页面 ChatController(CC) 用来聊天
	3. 语音录制 RecordController(RC) 用来录制语音


##4.1 消息列表
单一样式的Table就可以搞定，并没有难度。把Table元素加入到IC，并创引用， 我需要展示用户的头像，名称，未读消息数，那么每个Table Row需要一个Image，两个Label。如果你想要一个圆角的头像，那么一个Image就满足不了你，你需要在Image外面套一层Group，通过Group来实现圆角。

为了获取到这几个UI元素的Reference，我们不得不创建一个基于NSObject的子类，且叫ChatRowController（CRC）. 并在SB把Table Row Controller的类改为ChatRowController。需要注意都是，你需要在CRC中
`#include <WatchKit/WatchKit.h>`

每一个Table Row Controller都有一个RowType，在SB中叫做Identifier，这个值是Table在创建每个Row的时候必须要用到的

WApp中不存在类似UITableViewCell复用的情况，所以代码上可以省略很多不必要的考虑，但是性能上，你不可以一次性加载太多TableRow！可以分批按需加载。

###第一个问题来了 头像怎么加载？
WKInterfaceController 下有个方法是
	
	+ (BOOL)openParentApplication:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo, NSError *error)) reply;
	
为了方便，我们可以给WKInterfaceImage加一个Category，加入方法

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
	
同时到AppDelegate下重载，这里使用的是SDImageCache来管理图片缓存

	- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    	NSString *value = userInfo[@"key"];
	    if ([value isEqualToString:@"loadImage"]) {
    	    NSURL *url = [NSURL URLWithString:userInfo[@"urlString"]];
	        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url.absoluteString];
    	    NSData *data = nil;
        	BOOL cached = YES;
	        if (!image) {
    	        cached = NO;
        	    data = [NSData dataWithContentsOfURL:url];
            	image = [UIImage imageWithData:data];
	            [[SDImageCache sharedImageCache] storeImage:image forKey:url.absoluteString toDisk:YES];
    	    } else {
        	    data = UIImageJPEGRepresentation(image, 1);
	        }
    	    if (data) {
        	    reply(@{@"result":data, @"isFromCache":@(cached)});
	        }
	    }
	}

在Category的帮助下，我们只需要设定URLString就可以了
        
	[crc.avatarImage loadImageWithURLString:avatar placeholder:nil];

##4.2 聊天页面
我们需要支持展示聊天内容，播放聊天语音

###第二个问题来了 我的消息发出和收到，一个是靠左，一个是靠右对齐的，单一的TableRowController无法实现
我一度为这个问题难道，创建了非常复杂的RowController，企图通过设置多个透明的Group来帮助聊天消息的对齐走向，我太天真了。
可是微信已经实现了啊！难道他有特殊方法吗。。呵呵，其实是我的思维没打开，还是固定在iOS App上的开发方式，一个Table 用一类Cell解决所有UI。但是其实一个Table可以有多个RowController。当然其实这些RowController其实结构都一样，只不过部分元素在细节上不同，但代码是无法控制的！只能通过SB来创建不同的RowController，通过定义不同的Identifier来实现。但是这些RowController其实都可以是一个类。
	    
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
	        [_table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withRowType:[self rowTypeForMessage:messageDic]];
    	    MessageRowController *mrc = [_table rowControllerAtIndex:i];
	        if ([messageDic[@"type"] intValue] == MessageTypeText) {
    	        [mrc.label setText:messageDic[@"msg"]];
        	} else if ([messageDic[@"type"] intValue] == MessageTypeVoice) {
            	
	        } else {
    	        [mrc.image loadImageWithURLString:@"http://tp3.sinaimg.cn/1657938842/180/5704612869/1" 	placeholder:nil];
    	    }
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

###第三个问题来了 语音怎么播放？
首先你需要`#import <AVFoundation/AVFoundation.h>`然后就简单啦

	- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
	{
    	NSDictionary *messageDic = _messages[rowIndex];
	    if ([messageDic[@"type"] intValue] == MessageTypeVoice)
    	{
        	NSError *error = nil;
	        // 如果是网络语音，你需要下载语音，和图片一样，通过OpenParent下载好后传回来就行了，这里不多写了
    	    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"send" 	ofType:@"mp3"]];
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
	
网络语音和网络图片一样，都通过OpenParent来达到目的，具体缓存什么的都去AppDelegate里面写吧

###第四个问题来了 怎么文字回复？
WatchKit里有一个输入法，任何一个WKInterfaceController都可以调用

	- (void)presentTextInputControllerWithSuggestions:(NSArray *)suggestions allowedInputMode:(WKTextInputMode)inputMode completion:(void(^)(NSArray *results))completion; // results is nil if cancelled

至于用户怎么输入就不用管啦~

##4.3 录音页面
###唯一问题怎么录音
同样，引入`#import <AVFoundation/AVFoundation.h>`然后就简单啦

	_recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
	[_recorder record];
	
其实都和iPhone里一样~

#5. 总结以及其他坑
##5.1 当Controller不在可见屏幕内的时候，不要更新UI，因为会失败，等willActive后再更新UI

##5.2 把需要大量计算的工作交给iPhone，比如我需要将PCM转换为MP3，我需要下载图片，我需要缓存语音等等

##5.3 如果有两张图，一张叫ring1 一张叫ring10 当你尝试把使用[image setImageNamed:@"ring1"]的时候，出来的会是ring10！

##5.4 Apple Watch App 的功能点一定要简单和集中，不要试图把整个iOS App搬过来，苹果也不会喜欢太复杂的

##5.5 用更多的图片代替文字 让WApp显得高大上

##5.6 资源：[圆环指示器快速生成](http://hmaidasani.github.io/RadialChartImageGenerator/)

##5.7 Demo源码：[GitHub](https://github.com/WeeTom/BasicChatUIOnAppleWatch)

##5.8 [App主动与WApp沟通](http://stackoverflow.com/questions/28809226/notify-watchkit-app-of-an-update-without-the-watch-app-requesting-it)

