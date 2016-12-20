//
//  MFDownloadOperationBlock.h
//  MyOperationQueueDownloadImagesDemo
//
//  Created by chang on 2016/12/20.
//  Copyright © 2016年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MFDownloadOperationBlock;

typedef void (^downloadImageBlock)(MFDownloadOperationBlock *op);

@interface MFDownloadOperationBlock : NSOperation

@property(nonatomic, strong) NSString *url;
@property(nonatomic, strong) NSIndexPath *indexPath;
@property(nonatomic, strong) UIImage *webImage;
@property(nonatomic, copy) downloadImageBlock myBlock;

- (void)downloadImageWithBlock:(downloadImageBlock)blk;


@end
