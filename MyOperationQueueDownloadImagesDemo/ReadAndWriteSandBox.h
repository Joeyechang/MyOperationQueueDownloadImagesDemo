//
//  ReadAndWriteSandBox.h
//  MyOperationQueueDownloadImagesDemo
//
//  Created by chang on 2016/12/20.
//  Copyright © 2016年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ReadAndWriteSandBox : NSObject

// 获取 Caches 路径
- (NSString *)getSandboxCachesByAddFilename:(NSString *)filename;
// 读取沙盒文件
- (UIImage *)readImageFromSandboxByFile:(NSString *)filename;
// 写入沙盒文件
- (void)writeImage:(UIImage *)image ToSandboxFile:(NSString *)fileName;

@end
