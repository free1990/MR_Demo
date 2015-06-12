#import "TMCache.h"

NSString * const TMCachePrefix = @"com.tumblr.TMCache";
NSString * const TMCacheSharedName = @"TMCacheShared";

@interface TMCache ()
#if OS_OBJECT_USE_OBJC
@property (strong, nonatomic) dispatch_queue_t queue;
#else
@property (assign, nonatomic) dispatch_queue_t queue;
#endif
@end

@implementation TMCache

#pragma mark - Initialization -

#if !OS_OBJECT_USE_OBJC
- (void)dealloc
{
    dispatch_release(_queue);
    _queue = nil;
}
#endif

- (instancetype)initWithName:(NSString *)name
{
    if (!name)
        return nil;

    if (self = [super init]) {
        _name = [name copy];
        
        //卧槽，直接使用内存的地址来作为队列的名字，太狠了
        NSString *queueName = [[NSString alloc] initWithFormat:@"%@.%p", TMCachePrefix, self];
        NSLog(@"queueName = %@", queueName);
        
        _queue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
        
        //创建成员变量（此处禁止使用self.diskcache）
        _diskCache = [[TMDiskCache alloc] initWithName:_name];
        _memoryCache = [[TMMemoryCache alloc] init];
    }
    return self;
}

//继承方法，描述类
- (NSString *)description
{
    return [[NSString alloc] initWithFormat:@"%@.%@.%p", TMCachePrefix, _name, self];
}

//创建单例
+ (instancetype)sharedCache
{
    static id cache;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        cache = [[self alloc] initWithName:TMCacheSharedName];
    });

    return cache;
}

#pragma mark - Public Asynchronous Methods -

//异步根据key在block中去获取它
- (void)objectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    //key和block都为真
    if (!key || !block)
        return;
    
    //为了保持block里面引用的纯洁，就需要在每次外面的创建weak的引用
    __weak TMCache *weakSelf = self;
    
    //异步提交到队列
    dispatch_async(_queue, ^{
        
        //在block的传递过程中都是现在外面week然后再再内部进行strong之后进行曲传递
        TMCache *strongSelf = weakSelf;
        if (!strongSelf)
            return;

        __weak TMCache *weakSelf = strongSelf;
        
        //先去到内存中去寻找对象，如果没有，则在disk中继续寻找
        [strongSelf->_memoryCache objectForKey:key block:^(TMMemoryCache *cache, NSString *key, id object) {
            TMCache *strongSelf = weakSelf;
            if (!strongSelf)
                return;
            
            //判断对象是否为真
            if (object) {
                [strongSelf->_diskCache fileURLForKey:key block:^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
                    //更新这个对象的当访问时间
                    // update the access time on disk
                }];

                __weak TMCache *weakSelf = strongSelf;
                
                dispatch_async(strongSelf->_queue, ^{
                    TMCache *strongSelf = weakSelf;
                    //回调对象
                    if (strongSelf)
                        block(strongSelf, key, object);
                });
            } else {
                __weak TMCache *weakSelf = strongSelf;
                
                //硬盘中去获取这个对象
                [strongSelf->_diskCache objectForKey:key block:^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
                    TMCache *strongSelf = weakSelf;
                    if (!strongSelf)
                        return;
                    
                    //将对象拿出来放在内存中
                    [strongSelf->_memoryCache setObject:object forKey:key block:nil];
                    
                    __weak TMCache *weakSelf = strongSelf;
                    
                    dispatch_async(strongSelf->_queue, ^{
                        TMCache *strongSelf = weakSelf;
                        //回调对象
                        if (strongSelf)
                            block(strongSelf, key, object);
                    });
                }];
            }
        }];
    });
}

//设置对象到缓存
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key || !object)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        
        //设置group对象的任务数量为2
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }
    
    //把任务放入到缓存中
    [_memoryCache setObject:object forKey:key block:memBlock];
    [_diskCache setObject:object forKey:key block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        
        //两个group的任务执行完成，然后执行回调
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, object);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

//删除原理同上主要是利用了group的原理
- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block
{
    if (!key)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheObjectBlock memBlock = nil;
    TMDiskCacheObjectBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache, NSString *key, id object) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache, NSString *key, id <NSCoding> object, NSURL *fileURL) {
            dispatch_group_leave(group);
        };
    }

    [_memoryCache removeObjectForKey:key block:memBlock];
    [_diskCache removeObjectForKey:key block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf, key, nil);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

//删除所有的对象
- (void)removeAllObjects:(TMCacheBlock)block
{
    dispatch_group_t group = nil;
    TMMemoryCacheBlock memBlock = nil;
    TMDiskCacheBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache removeAllObjects:memBlock];
    [_diskCache removeAllObjects:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

//删除过期的对象
- (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block
{
    if (!date)
        return;
    
    dispatch_group_t group = nil;
    TMMemoryCacheBlock memBlock = nil;
    TMDiskCacheBlock diskBlock = nil;
    
    if (block) {
        group = dispatch_group_create();
        dispatch_group_enter(group);
        dispatch_group_enter(group);
        
        memBlock = ^(TMMemoryCache *cache) {
            dispatch_group_leave(group);
        };
        
        diskBlock = ^(TMDiskCache *cache) {
            dispatch_group_leave(group);
        };
    }
    
    [_memoryCache trimToDate:date block:memBlock];
    [_diskCache trimToDate:date block:diskBlock];
    
    if (group) {
        __weak TMCache *weakSelf = self;
        dispatch_group_notify(group, _queue, ^{
            TMCache *strongSelf = weakSelf;
            if (strongSelf)
                block(strongSelf);
        });
        
        #if !OS_OBJECT_USE_OBJC
        dispatch_release(group);
        #endif
    }
}

#pragma mark - Public Synchronous Accessors -

- (NSUInteger)diskByteCount
{
    __block NSUInteger byteCount = 0;
    
    dispatch_sync([TMDiskCache sharedQueue], ^{
        byteCount = self.diskCache.byteCount;
    });
    
    return byteCount;
}

#pragma mark - Public Synchronous Methods -

- (id)objectForKey:(NSString *)key
{
    if (!key)
        return nil;
    
    __block id objectForKey = nil;
    
    //创建一个0的可以配合dispatch_semaphore_wait用来阻塞线程
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self objectForKey:key block:^(TMCache *cache, NSString *key, id object) {
        objectForKey = object;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif

    return objectForKey;
}

- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key
{
    if (!object || !key)
        return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self setObject:object forKey:key block:^(TMCache *cache, NSString *key, id object) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key)
        return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self removeObjectForKey:key block:^(TMCache *cache, NSString *key, id object) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (void)trimToDate:(NSDate *)date
{
    if (!date)
        return;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self trimToDate:date block:^(TMCache *cache) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

- (void)removeAllObjects
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [self removeAllObjects:^(TMCache *cache) {
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

@end

#pragma HC SVNT DRACONES
