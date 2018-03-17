//
//  ViewController.m
//  GCD
//
//  Created by lucky zong on 2018/3/16.
//  Copyright © 2018年 lingqi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
   // [self dispath_after];
    

  //  [self dispath_group];
    
   // [self dispath_barrier_async];
    
  // [self dispath_apply];
    
  // [self dispath_semaphore];
    
}
// 多线程访问安全
- (void)dispath_once
{
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
    
        // 初始化
    
    });
    
    
    
    
}


- (void)dispath_semaphore
{
   
    dispatch_queue_t queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    /*
     * 生成 Dispath Semaphore
     * Disparh Semaphore 的计数器初始值为1
     * 保证可访问NSMutableArray类对象的线程 同时只有1个
    */
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 100000; i++) {
    dispatch_async(queue, ^{
            /*
             等待 Dispath Semaphore
             一直等待 直到 Dispath Semaphore的计数值到达 >= 1
             */
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            /*
             由于dispath semaphore 的计数值达到>=1
             所以 dispath semaphore 计数值减去1
             dispath_semaphore_wait 函数执行返回
             即执行到此时的 dispath semaphore的计数值恒为 0
             由于可访问NSMutableArray类对象的线程只有1个
             因此可以安全的更新
             */
            
            [array addObject:[NSNumber numberWithInt:i]];
            
            /*
             排他控制处理结束
             所以通过dispath_semaphore_signal函数
             将dispath semaphore的计数值加1
             如果有通过dispath_semaphore_wait的函数
             等待dispath semaphore的计数值增加的线程
             就由最先等待的线程执行
             */
            dispatch_semaphore_signal(semaphore);
    });
    }
    
    dispatch_async(queue, ^{
       
        dispatch_semaphore_wait(semaphore, 1ull*NSEC_PER_SEC);
        
        NSLog(@"数组操作完毕");
        
        
        dispatch_semaphore_signal(semaphore);
        
    });

    
    
    
    
    
    
}

- (void)dispath_apply
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu",index);
    });
    
    NSLog(@"done");
}


- (void)dispath_barrier_async
{
    dispatch_queue_t queue = dispatch_queue_create("forbarrier", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"reading111");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"reading222");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"reading333");
    });
    // 写入操作
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"writing111");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"reading444");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"reading555");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"reading666");
    });
    
}

- (void)dispath_group
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        NSLog(@"111");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"222");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"333");
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"done");
    });
    // 等待group中的线程执行完
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)dispath_after
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        NSLog(@"waited at least three seconds");
    });
    
    
    
}
//
- (void)dispath_queue_t
{
    //SerialQueue
    dispatch_queue_t myserialDispathQueue = dispatch_queue_create("myfirstSerialQueue", NULL);
    // ConcurrentQueue
    dispatch_queue_t myConcurrentQueue = dispatch_queue_create("myFirstConcurrentQueue",DISPATCH_QUEUE_CONCURRENT);
    
    
    //    dispatch_async(myserialDispathQueue, ^{
    //        NSLog(@"11");
    //    });
    //    dispatch_async(myserialDispathQueue, ^{
    //        NSLog(@"22");
    //    });
    //    dispatch_async(myserialDispathQueue, ^{
    //        NSLog(@"33");
    //    });
    //    dispatch_async(myserialDispathQueue, ^{
    //        NSLog(@"44");
    //    });
    
    
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"55");
    });
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"66");
    });
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"77");
    });
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"88");
    });
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    // 高优先级 global queue
    
    dispatch_queue_t globalDispathQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    // 默认先级 global queue
    dispatch_queue_t globalDispathQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 低先级 global queue
    dispatch_queue_t globalDispathQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    
    
    // 后台优先级
    
    dispatch_queue_t globalDispathQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    // 让myserialDispathQueue处于globalDispathQueueBackground的优先级
    dispatch_set_target_queue(myserialDispathQueue, globalDispathQueueBackground);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
