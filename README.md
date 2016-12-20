多线程笔记一：

```
1. 什么是主线程
一个iOS程序运行后，默认会开启1条线程，称为“主线程”或“UI线程”

主线程的主要作用
显示\刷新UI界面
处理UI事件（比如点击事件、滚动事件、拖拽事件等）

主线程的使用注意
别将比较耗时的操作放到主线程中
耗时操作会卡住主线程，严重影响UI的流畅度，给用户一种“卡”的坏体验


一个NSThread对象就代表一条线程
创建、启动线程
NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
[thread start];
// 线程一启动，就会告诉 CPU 准备就绪,可以随时接受 CPU 调度! CPU 调度当前线程之后,就会在线程thread中执行self的run方法

主线程相关用法
+ (NSThread *)mainThread; // 获得主线程
- (BOOL)isMainThread; // 是否为主线程
+ (BOOL)isMainThread; // 是否为主线程

获得当前线程
NSThread *current = [NSThread currentThread];

线程的调度优先级
+ (double)threadPriority;
+ (BOOL)setThreadPriority:(double)p;
- (double)threadPriority;
- (BOOL)setThreadPriority:(double)p;
调度优先级的取值范围是0.0 ~ 1.0，默认0.5，值越大，优先级越高

线程的名字
- (void)setName:(NSString *)n;
- (NSString *)name;


创建线程后自动启动线程
[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];

隐式创建并启动线程
[self performSelectorInBackground:@selector(run) withObject:nil];

上述2种创建线程方式的优缺点
优点：简单快捷
缺点：无法对线程进行更详细的设置


控制线程状态
启动线程
- (void)start; 
// 进入就绪状态 -> 运行状态。当线程任务执行完毕，自动进入死亡状态

阻塞（暂停）线程
+ (void)sleepUntilDate:(NSDate *)date;
+ (void)sleepForTimeInterval:(NSTimeInterval)ti;
// 进入阻塞状态

强制停止线程
+ (void)exit;
// 进入死亡状态
注意：一旦线程停止（死亡）了，就不能再次开启任务


互斥锁使用格式
@synchronized(锁对象) { // 需要锁定的代码  }
注意：锁定1份代码只用1把锁，用多把锁是无效的

互斥锁的优缺点
优点：能有效防止因多线程抢夺资源造成的数据安全问题
缺点：需要消耗大量的CPU资源

互斥锁的使用前提：多条线程抢夺同一块资源

相关专业术语：线程同步
线程同步的意思是：多条线程在同一条线上执行（按顺序地执行任务）
互斥锁，就是使用了线程同步技术

原子和非原子属性的选择：
nonatomic和atomic对比
atomic：线程安全，需要消耗大量的资源
nonatomic：非线程安全，适合内存小的移动设备

iOS开发的建议
所有属性都声明为nonatomic
尽量避免多线程抢夺同一块资源
尽量将加锁、资源抢夺的业务逻辑交给服务器端处理，减小移动客户端的压力

线程间通信：
什么叫做线程间通信
在1个进程中，线程往往不是孤立存在的，多个线程之间需要经常进行通信

线程间通信的体现
1个线程传递数据给另1个线程
在1个线程中执行完特定任务后，转到另1个线程继续执行任务

线程间通信常用方法
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait;

 
既然多线程这么爽, 线程是不是越多越好呢?
<1> 开启线程需要消耗一定的内存(默认情况下,线程占用 512KB 的栈区空间);
<2> 会使应用程序增加很多代码!代码变多之后,程序复杂性就会提高!
<3> CPU 在多条线程之间来回切换!线程越多, CPU就越累!
建议: 在移动应用的开发中; 一般只开3~5条线程!


/*-------------------------------------- 桥接 (__bridge) ------------------------------------*/
重点:为什么要使用桥接?你是怎么进行混合开发的?
{
    桥接 (__bridge) :C 和 OC 之间传递数据的时候需要使用桥接! why?为什么呢?
    
    1.内存管理:
        在 OC 中,如果是在 ARC环境下开发,编译器在编译的时候会根据代码结构,自动为 OC 代码添加 retain/release/autorelease等.   ----->自动内存管理(ARC)的原理!
    
        但是, ARC只负责 OC 部分的内存管理!不会负责 C 语言部分代码的内存管理!
        也就是说!即使是在 ARC 的开发环境中!如果使用的 C 语言代码出现了 retain/copy/new/create等字样呢!我们都需要手动为其添加 release 操作!否则会出现内存泄露!
    
        在混合开发时(C 和 OC 代码混合),C 和 OC 之间传递数据需要使用 __bridge 桥接,目的就是为了告诉编译器如何管理内存

        在 MRC中不需要使用桥接! 因为都需要手动进行内存管理!
    
    2.数据类型转换:
    
        Foundation 和 Core Foundation框架的数据类型可以互相转换的
        Foundation :  OC
        Core Foundation : C语言
    
        NSString *str = @"123"; // Foundation
        CFStringRef str2 = (__bridge CFStringRef)str; // Core Foundation
        NSString *str3 = (__bridge NSString *)str2;
            CFArrayRef ---- NSArray
            CFDictionaryRef ---- NSDictionary
            CFNumberRef ---- NSNumber

        Core Foundation中手动创建的数据类型，都需要手动释放

        CGPathRef path = CGPathCreateMutable();
        CGPathRetain(path);

        CGPathRelease(path);
        CGPathRelease(path);

    3.桥接的添加:
        利用 Xcode 提示自动添加! --简单/方便/快速


/**
 凡是函数名中带有create\copy\new\retain等字眼, 都应该在不需要使用这个数据的时候进行release
 GCD的数据类型在ARC环境下不需要再做release
 CF(Core Foundation)的数据类型在ARC\MRC环境下都需要再做release
 */
}
/*------------------------- iOS中多线程实现方案2.NSThread - 1基本使用 ---------------------------*/
重点:1.三种创建线程! 2.常用方法!
{
    1.NSThread: 一个 NSThread 就代表一个线程对象!
    // OC语言 / 使用面向对象 / 需要手动管理线程生命周期(创建/销毁等)
    
    2.三种多线程实现方案:
    
    1> 先创建，后启动
    // 创建
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(download:) object:nil];
    // 启动
    [thread start];
    
    2> 创建完自动启动
    [NSThread detachNewThreadSelector:@selector(download:) toTarget:self withObject:nil];
    
    3> 隐式创建（自动启动）
    [self performSelectorInBackground:@selector(download:) withObject:nil];
    
    3.常用方法:
     名字/获得主线程/获得当前线程/阻塞线程/退出线程
    // 不常用: 栈区大小/优先级
    1> 获得当前线程
    + (NSThread *)currentThread;
    
    2> 获得主线程
    + (NSThread *)mainThread;
    
    3> 睡眠（暂停）线程
    + (void)sleepUntilDate:(NSDate *)date;
    + (void)sleepForTimeInterval:(NSTimeInterval)ti;
    
    4> 设置线程的名字
    - (void)setName:(NSString *)n;
    - (NSString *)name;
}

```

多线程笔记二：

```
1. 什么是GCD
全称是Grand Central Dispatch，可译为“牛逼的中枢调度器”
纯C语言，提供了非常多强大的函数

GCD的优势
GCD是苹果公司为多核的并行运算提出的解决方案
GCD会自动利用更多的CPU内核（比如双核、四核）
GCD会自动管理线程的生命周期（创建线程、调度任务、销毁线程）
程序员只需要告诉GCD想要执行什么任务，不需要编写任何线程管理代码

2. GCD中有2个核心概念
任务：执行什么操作
队列：用来存放任务

GCD的使用就2个步骤
定制任务
确定想做的事情

将任务添加到队列中
GCD会自动将队列中的任务取出，放到对应的线程中执行
任务的取出遵循队列的FIFO原则：先进先出，后进后出

3. 延时执行
iOS常见的延时执行有2种方式
调用NSObject的方法
[self performSelector:@selector(run) withObject:nil afterDelay:2.0];
// 2秒后再调用self的run方法

使用GCD函数
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 2秒后执行这里的代码... 在哪个线程执行，跟队列类型有关
    
});


4. 一次性代码
使用dispatch_once函数能保证某段代码在程序运行过程中只被执行1次
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    // 只执行1次的代码(这里面默认是线程安全的)
});

5. 队列组
有这么1种需求
首先：分别异步执行2个耗时的操作
其次：等2个异步操作都执行完毕后，再回到主线程执行操作

如果想要快速高效地实现上述需求，可以考虑用队列组
dispatch_group_t group =  dispatch_group_create();
dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});
dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});
dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 等前面的异步操作都执行完毕后，回到主线程...
});


6. 单例模式
单例模式的作用
可以保证在程序运行过程，一个类只有一个实例，而且该实例易于供外界访问
从而方便地控制了实例个数，并节约系统资源

单例模式的使用场合
在整个应用程序中，共享一份资源（这份资源只需要创建初始化1次）

单例模式在ARC\MRC环境下的写法有所不同，需要编写2套不同的代码
可以用宏判断是否为ARC环境
#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif

ARC中，单例模式的实现
在.m中保留一个全局的static的实例
static id _instance;

重写allocWithZone:方法，在这里创建唯一的实例（注意线程安全）
+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_instance == nil) { // 防止频繁加锁
        @synchronized(self) {
            if (_instance == nil) { // 防止创建多次
		  _instance = [super allocWithZone:zone];
            }
        }
    }
    return _instance;
}

提供1个类方法让外界访问唯一的实例
+ (instancetype)sharedMusicTool {
    if (_instance == nil) { // 防止频繁加锁
        	@synchronized(self) {
            if (_instance == nil) { // 防止创建多次
               _instance = [[self alloc] init];
            }
        }
    }
    return _instance;
}

实现copyWithZone:方法
- (id)copyWithZone:(struct _NSZone *)zone {
    return _instance;
}


非ARC中（MRC），单例模式的实现（比ARC多了几个步骤）
实现内存管理方法
- (id)retain { return self; }
- (NSUInteger)retainCount { return 1; }
- (oneway void)release {}
- (id)autorelease { return self; }


7.注意两个方法:
 // 面试问题:两个方法的区别?
 <1> +(void)load;
    // 当类加载到OC运行时环境(内存)中的时候,就会调用一次(一个类只会加载一次).
    // 程序一启动就会调用.
    // 程序运行过程中,只会调用1次.
 <2> +(void)initialize;
    // 当第一次使用这个类的时候(比如调用了类的某个方法)才会调用.
    // 并非程序一启动就会调用.


8. 常用代码

   // 创建一个串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    
    // 创建一个并发队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);

    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 获取全局并发队列
    // <#long identifier#> iOS8 之前 传线程优先级 iOS8以后 传0 可以跟之前的版本兼容
    dispatch_queue_t globalQueue = dispatch_get_global_queue(0, 0);
    
    
    // 异步执行函数
    // <#dispatch_queue_t queue#>:队列
    // <#^(void)block#>:任务
    dispatch_async(serialQueue, ^{
        // 执行任务
        NSLog(@"------下载图片1");
    });
    dispatch_async(serialQueue, ^{
        // 执行任务
        NSLog(@"------下载图片2");
    });
    dispatch_async(serialQueue, ^{
        // 执行任务
        NSLog(@"------下载图片3");
    });
    // 同步执行函数
    dispatch_sync(concurrentQueue, ^{
        // 任务
        NSLog(@"------下载图片");
    });
```


多线程笔记三：

```
 1.NSOperation(操作)简介:
    
    NSOperation: // 本质是对 GCD 的封装, OC 语言.
    
    NSOperation 和 GCD 的比较:
    
    GCD使用场合:
    一些简单的需求,简单的多线程操作. //简单高效
    
    NSOperation使用场合:
    各个操作之间有依赖关系,操作需要取消/暂停;需要限制同时执行的线程数量,让线程在某时刻停止/继续等.
    
    配合使用 NSOperation和 NSOperationQueue 也可以实现多线程.

 2.NSOperation使用:
    
    NSOperation: 抽象类,不能直接使用,需要使用其子类.
    
    抽象类:定义子类共有的属性和方法.// CAAnimation/CAPropertyAnimation...
    
    两个常用子类: NSInvocationOperation(调用) 和 NSBlockOperation(块);
    
                两者没有本质区别,后者使用 Block 的形式组织代码,使用相对方便.
    
    自定义子类继承自 NSOperation,实现内部相应的方法. // 高级用法

3. NSBlockOperation, NSInvocationOperation的简单使用.

重点:1.NSBlockOperation, NSInvocationOperation的简单使用.
{
    1. 创建 NSInvocationOperation 对象
    
    // 创建 NSInvocationOperation
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(longTimeOperation:) object:@"op1"];
    
    //默认情况下,调用 start 方法之后,不会开启新线程,只会在当前线程执行操作.
    [op1 start];
    
    注意:只有将 NSOperation 放到一个 NSOperationQueue 中,才会异步执行操作.
    
    2. 创建 NSBlockOperation 对象
    
    // 创建 NSBlockOperation
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片1---%@",[NSThread currentThread]);
    }];
    // 添加更多操作
    [op2 addExecutionBlock:^{
        NSLog(@"下载图片2---%@",[NSThread currentThread]);
    }];
    [op2 addExecutionBlock:^{
        NSLog(@"下载图片3---%@",[NSThread currentThread]);
    }];
    
    // 只要 NSBlockOperation 中封装的操作数 > 1, 调用start方法之后就会开启多条线程并发执行
    // 如果 NSBlockOperation 中封装的操作数 == 1,调用 start 方法之后,不会开启新线程,只会在当前线程执行操作
    [op2 start];
    
    注意: 只要 NSBlockOperation 中封装的操作数 > 1,就会异步执行这些操作.(将操作添加到 NSOperationQueue中或者直接调用 start方法都会开启多条线程异步执行).
}



4. 重点:将操作添加到队列中;

{
    NSOperation 可以调用 start 方法来执行任务,但默认是同步执行的.
    将 NSOperation 添加到 NSOperationQueue(操作队列) 中,系统会自动异步执行NSOperationQueue中的操作.
    
    1.NSOperationQueue(操作队列):
    
    <1> 主队列
    [NSOperationQueue mainQueue] //获取主队列
    添加到"主队列"中的操作,都会放在主线程执行!
    
    <2>非主队列
    [[NSOperationQueue alloc] init]; //创建非主队列
    添加到"非主队列"中得操作,都会放在子线程中执行.
    
    2.使用: 添加操作到操作队列中.
    
    // 创建 NSInvocationOperation 操作
    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(longTimeOperation:) object:@"op1"];
    
    // 创建 NSBlockOperation 操作
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"下载图片1---%@",[NSThread currentThread]);
    }];

    // 1.创建一个 NSOperationQueue
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.将操作添加到队列中.
    [queue addOperation:op1];
    [queue addOperation:op2];
    
    注意:另外一种添加操作到队列中的方法: block
    [queue addOperationWithBlock:^{
        NSLog(@"下载图片5---%@",[NSThread currentThread]);
    }];
    
    推荐使用: block // 简单. 自己哪个使用熟练就用哪个.
    
    注意:队列中任务的执行是无序的.
    
    问题:是否可以让队列中的操作有序执行?
}

5. 常见用法
/*-------------------------------- NSOperation使用 4.常见用法1 -------------------------------*/
重点:1.设置操作依赖. 2.设置最大并发数.
{
    回答上问题: 能,设置操作依赖.
    
    1.NSOperation设置操作依赖: // 执行顺序: op1,op2,op3;
    
    // 操作op3依赖于操作op2;
    [op3 addDependency:op2];
    // 操作op2依赖于操作op1;
    [op2 addDependency:op1];
    
    注意:不能相互依赖.
    
    2.NSOperationQueue设置最大并发数.
    
    并发数:同时开启的线程数.
    
    // 创建操作队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 设置操作队列的最大并发数
    queue.maxConcurrentOperationCount = 3;
    [queue setMaxConcurrentOperationCount:3];
}
/*-------------------------------- NSOperation使用 5.常见用法2 -------------------------------*/
重点:1.队列的取消/暂停/恢复  2.线程间通信. 注意问题:为毛要取消恢复队列? 在什么时候用?
{
    1.NSOperationQueue 的取消/暂停/恢复
    
    // 取消操作 op1. 取消单个操作.
    [op1 cancel];
    // 取消所有操作,不会再次恢复
    [queue cancelAllOperations];
    // 暂停所有操作;注意,已经开始的操作不会暂停.
    [queue setSuspended:YES];
    // 重新开始所有操作
    [queue setSuspended:NO];
    
    问:为毛要取消恢复队列? 在什么时候用?
    
    答:1.为了内存管理,处理内存警告; 2.为了用户体验,保证滚动流畅.
    
    // 接收到内存警告的时候果断取消队列中的所有操作
    - (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        
        //    [queue cancelAllOperations]; // 取消队列中的所有任务（不可恢复）
    }
    // 开始滚动的时候暂停队列中的任务.
    - (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
    {
        //    [queue setSuspended:YES]; // 暂停队列中的所有任务
    }
    // 滚动结束的时候恢复队列中的任务.
    - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
    {
        //    [queue setSuspended:NO]; // 恢复队列中的所有任务
    }

    2.线程间通信  // 子线程下载图片,主线程设置图片.
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [queue addOperationWithBlock:^{
        // 1.异步下载图片
        NSURL *url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/pic/item/37d3d539b6003af3290eaf5d362ac65c1038b652.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        // 2.回到主线程，显示图片
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.imageView.image = image;
        }];
    }];
    
}
/*-----------------------------------------------------------------------------------------*/
```





