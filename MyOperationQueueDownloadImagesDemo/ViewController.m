//
//  ViewController.m
//  MyOperationQueueDownloadImagesDemo
//
//  Created by chang on 2016/12/20.
//  Copyright © 2016年 chang. All rights reserved.
//

// 状态栏高度
#define kSTATUSHEIGHT 20
// 屏幕宽度
#define kWIDTH [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define kHEIGHT [UIScreen mainScreen].bounds.size.height - kSTATUSHEIGHT - 50
// 图片间间隙
#define kMARGIN 4
// 总行数
#define kROWS 5
// 总列数
#define kCOUNT 3
// 图片总数
#define kNUMBERS 15

#import "ViewController.h"
#import "MFDownloadOperationBlock.h"

@interface ViewController ()<UIAlertViewDelegate>
// 操作队列
@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 创建一个操作队列
    self.queue = [[NSOperationQueue alloc] init];
    
    // 设置最大并发数
    [self.queue setMaxConcurrentOperationCount:3];
    
    // 设置底部按钮
    [self setUpCancelButton];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 设置 下载,取消,暂停/恢复 按钮
- (void)setUpCancelButton
{
    // 下载图片按钮
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 addTarget:self action:@selector(setupUI)forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"下载图片" forState:UIControlStateNormal];
    button2.backgroundColor = [UIColor redColor];
    button2.frame = CGRectMake(0, 0, kWIDTH/3, 50);
    
    // 取消下载操作按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(cancelOperation:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"取消下载" forState:UIControlStateNormal];
    [button setTitle:@"已经取消" forState:UIControlStateSelected];
    button.backgroundColor = [UIColor blueColor];
    button.frame = CGRectMake(2*kWIDTH/3, 0, kWIDTH/3, 50);
    
    // 暂停/恢复下载操作按钮
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 addTarget:self action:@selector(suspendedOperation:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [button1 setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    //  [button1 setBackgroundColor:[UIColor blueColor]];
    button1.frame = CGRectMake(kWIDTH/3, 0, kWIDTH/3, 50);
    
    // 将三个按钮添加到一个 View 上,可以封装在外面.
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kHEIGHT+kSTATUSHEIGHT, kWIDTH, 50)];
    
    [view addSubview:button];
    [view addSubview:button1];
    [view addSubview:button2];
    
    [self.view addSubview:view];
    
}
// 暂停下载
- (void)suspendedOperation:(UIButton *)button
{
    
    BOOL is_Selected = !button.selected;
    button.selected = is_Selected;
    
    [self.queue setSuspended:is_Selected];
    
}

// 取消下载
- (void)cancelOperation:(UIButton *)button
{
    [self.queue cancelAllOperations]; // 取消所有操作
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"亲.一旦取消,不可恢复.请三思而后行" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
    // 点击取消按钮之后,首先暂停下载操作,等待用户做出选择
    [self.queue setSuspended:YES];
    
    //    BOOL is_Selected = !button.selected;
    //    button.selected = is_Selected;
    //    [self.queue cancelAllOperations];
    
}

// 设置主视图 UI
- (void)setupUI
{
    //__weak typeof(self) wself = self;
    //NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 图片的 宽W/高H
    CGFloat imageW = (kWIDTH - kMARGIN*(kCOUNT+1))/kCOUNT;
    
    CGFloat imageH = (kHEIGHT - kMARGIN*(kROWS+1))/kROWS;
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0 ; i < kNUMBERS; i ++) {
        
        //图片所在的行
        int row = i/kCOUNT;
        //图片所在的列
        int count = i%kCOUNT;
        
        // 图片的X
        CGFloat imageX = kMARGIN + count*(imageW +kMARGIN);
        // 图片的Y
        CGFloat imageY = kMARGIN +kSTATUSHEIGHT + row*(imageH +kMARGIN);
        // 绘制 imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        imageView.backgroundColor = [UIColor greenColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, imageH - 30, imageW-10, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor whiteColor];
        label.alpha = 0.5;
        [imageView addSubview:label];
        // 将 imageView 添加到控制器 View 上
        [self.view addSubview:imageView];
        
        //
        MFDownloadOperationBlock *op1 = [[MFDownloadOperationBlock alloc] init];
        NSString *urlString = [NSString stringWithFormat:@"http://joeychang.oss-cn-shanghai.aliyuncs.com/testImages/%d.JPG",i+1];
        op1.url = urlString;
        
        [op1 downloadImageWithBlock:^(MFDownloadOperationBlock *op) {
            imageView.image = op.webImage;
        }];
        
        //        // 设置下载操作
        //        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //            // 在子线程下载网络图片
        //            UIImage *image = [wself downloadImageWithUrl:i];
        //            // 回到主线程
        //            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        //                // 设置图片
        //                imageView.image = image;
        //            }];
        //        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            op1.completionBlock = ^{
                label.text = @"操作执行完毕";
                
            };
        });
        
        [array addObject:op1];
    };
    
    // 设置操作依赖
    //  ITDownloadOperationBlock *lastOp = array.lastObject;
    for (int i = 0 ; i < array.count -1 ; i ++) {
        MFDownloadOperationBlock *op1 = array[i];
        MFDownloadOperationBlock *op2 = array[i+1];
        [op2 addDependency:op1];
    }
    // 将操作添加到 操作队列中.
    [self.queue addOperations:array waitUntilFinished:NO];
}

// 下载网络图片
- (UIImage *)downloadImageWithUrl:(int)index
{
    NSString *urlString = [NSString stringWithFormat:@"http://joeychang.oss-cn-shanghai.aliyuncs.com/testImages/%d.JPG",index];
    
    // 统一资源定位符.定位唯一资源!
    NSURL *url = [NSURL URLWithString:urlString];
    // 执行下载操作,将url 定位到的资源转换为2进制数据
    NSData *data = [NSData dataWithContentsOfURL:url];
    // 将2进制数据转换为图片
    UIImage *image = [UIImage imageWithData:data];
    
    // 返回下载好的网络图片
    return image;
    
}

#pragma UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { //点击取消
        [self.queue setSuspended:NO]; //点击取消之后恢复下载
        return;
    }else if (buttonIndex == 1) // 点击确定
    {
        [self.queue cancelAllOperations]; // 取消所有操作
        [self.queue setSuspended:NO]; // 设置操作队列恢复下载操作
        
        return;
        
    }
}

@end
