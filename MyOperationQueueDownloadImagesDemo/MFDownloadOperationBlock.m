//
//  MFDownloadOperationBlock.m
//  MyOperationQueueDownloadImagesDemo
//
//  Created by chang on 2016/12/20.
//  Copyright © 2016年 chang. All rights reserved.
//

#import "MFDownloadOperationBlock.h"
#import "ReadAndWriteSandBox.h"

@interface MFDownloadOperationBlock ()
@property(nonatomic, strong) ReadAndWriteSandBox *sandbox;
@end

@implementation MFDownloadOperationBlock

-(ReadAndWriteSandBox *)sandbox
{
    if (!_sandbox) {
        _sandbox = [[ReadAndWriteSandBox alloc] init];
    }
    
    return _sandbox;
}

-(void)main
{
    @autoreleasepool {
        
        if (self.isCancelled) {
            return;
        }
        self.webImage = [self downloadWebImageWithUrl:self.url Indexpath:self.indexPath];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.myBlock(self);
        }];
        
    }
}

- (void)downloadImageWithBlock:(downloadImageBlock)blk
{
    if (blk) {
        self.myBlock = blk;
    }
}

// 下载网络图片
- (UIImage *)downloadWebImageWithUrl:(NSString *)urlString Indexpath:(NSIndexPath *)indexPath
{
    if (self.isCancelled) {
        return nil;
    }
    NSLog(@"Block模式:downloadWebImage");
    //[NSThread sleepForTimeInterval:10];
    
    // 根据 urlString 获得统一资源定位符
    NSURL *url = [NSURL URLWithString:urlString];
    // 下载网络图片,获得图片的二进制流数据
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (self.isCancelled) {
        return nil;
    }
    if (data) {
        NSString *file = [self.sandbox getSandboxCachesByAddFilename:urlString];
        [data writeToFile:file atomically:YES];
    }
    if (self.isCancelled) {
        return nil;
    }
    // 根据下载好的图片二进制流数据转换为图片
    UIImage *image = [UIImage imageWithData:data];
    // 返回下载好的网络图片
    return image;
}

@end







