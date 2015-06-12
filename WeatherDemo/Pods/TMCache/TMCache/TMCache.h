/**
 `TMCache` is a thread safe key/value store designed for persisting temporary objects that are expensive to
 reproduce, such as downloaded data or the results of slow processing. It is comprised of two self-similar
 stores, one in memory (<TMMemoryCache>) and one on disk (<TMDiskCache>).
 
 `TMCache` itself actually does very little; its main function is providing a front end for a common use case:
 a small, fast memory cache that asynchronously persists itself to a large, slow disk cache. When objects are
 removed from the memory cache in response to an "apocalyptic" event they remain in the disk cache and are
 repopulated in memory the next time they are accessed. `TMCache` also does the tedious work of creating a
 dispatch group to wait for both caches to finish their operations without blocking each other.
 
 The parallel caches are accessible as public properties (<memoryCache> and <diskCache>) and can be manipulated
 separately if necessary. See the docs for <TMMemoryCache> and <TMDiskCache> for more details.
 */


//TMCache 是一个线程安全的key/value存储一些变量的的辅助工具。
//TMCache 这个类并不做很多的工作，主要是把通用的接口暴露给用户，另外做一些线程调度安全的工作，这个玩意可以把对象存在内存和硬盘中

#import "TMDiskCache.h"
#import "TMMemoryCache.h"

@class TMCache;

//声明了两个block用来回调
typedef void (^TMCacheBlock)(TMCache *cache);
typedef void (^TMCacheObjectBlock)(TMCache *cache, NSString *key, id object);

@interface TMCache : NSObject

#pragma mark -
/// @name Core

/**
 The name of this cache, used to create the <diskCache> and also appearing in stack traces.
 */
@property (readonly) NSString *name;

/**
 A concurrent queue on which blocks passed to the asynchronous access methods are run.
 */
//并发队列（主要是给那些个传过来的block那些鳖孙玩的）
@property (readonly) dispatch_queue_t queue;

/**
 Synchronously retrieves the total byte count of the <diskCache> on the shared disk queue.
 */
//在硬盘上占用的空间的byte数
@property (readonly) NSUInteger diskByteCount;

/**
 The underlying disk cache, see <TMDiskCache> for additional configuration and trimming options.
 */
//硬盘存储(只读哦)
@property (readonly) TMDiskCache *diskCache;

/**
 The underlying memory cache, see <TMMemoryCache> for additional configuration and trimming options.
 */
//内存存储(只读哦)
@property (readonly) TMMemoryCache *memoryCache;

#pragma mark -
/// @name Initialization

/**
 A shared cache.
 
 @result The shared singleton cache instance.
 */
//单例
+ (instancetype)sharedCache;

/**
 The designated initializer. Multiple instances with the same name are allowed and can safely access
 the same data on disk thanks to the magic of seriality. Also used to create the <diskCache>.
 
 @see name
 @param name The name of the cache.
 @result A new cache with the specified name.
 */
- (instancetype)initWithName:(NSString *)name;

#pragma mark -
/// @name Asynchronous Methods（异步的方法）

/**
 Retrieves the object for the specified key. This method returns immediately and executes the passed
 block after the object is available, potentially in parallel with other blocks on the <queue>.
 
 @param key The key associated with the requested object.
 @param block A block to be executed concurrently when the object is available.
 */

//获取指定的key的对象，并且完成后执行block的内容
- (void)objectForKey:(NSString *)key block:(TMCacheObjectBlock)block;

/**
 Stores an object in the cache for the specified key. This method returns immediately and executes the
 passed block after the object has been stored, potentially in parallel with other blocks on the <queue>.
 
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 @param block A block to be executed concurrently after the object has been stored, or nil.
 */

//以一个指定的key来存储对象，完成后执行block的内容
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key block:(TMCacheObjectBlock)block;

/**
 Removes the object for the specified key. This method returns immediately and executes the passed
 block after the object has been removed, potentially in parallel with other blocks on the <queue>.
 
 @param key The key associated with the object to be removed.
 @param block A block to be executed concurrently after the object has been removed, or nil.
 */

//根据对象的键值来删除对象，完成后执行block内容
- (void)removeObjectForKey:(NSString *)key block:(TMCacheObjectBlock)block;

/**
 Removes all objects from the cache that have not been used since the specified date. This method returns immediately and
 executes the passed block after the cache has been trimmed, potentially in parallel with other blocks on the <queue>.
 
 @param date Objects that haven't been accessed since this date are removed from the cache.
 @param block A block to be executed concurrently after the cache has been trimmed, or nil.
 */

//指定日期后会删除所有的对象
- (void)trimToDate:(NSDate *)date block:(TMCacheBlock)block;

/**
 Removes all objects from the cache.This method returns immediately and executes the passed block after the
 cache has been cleared, potentially in parallel with other blocks on the <queue>.
 
 @param block A block to be executed concurrently after the cache has been cleared, or nil.
 */

//删除所有的对象
- (void)removeAllObjects:(TMCacheBlock)block;

#pragma mark -
/// @name Synchronous Methods（同步的方法）

/**
 Retrieves the object for the specified key. This method blocks the calling thread until the object is available.
 
 @see objectForKey:block:
 @param key The key associated with the object.
 @result The object for the specified key.
 */


- (id)objectForKey:(NSString *)key;

/**
 Stores an object in the cache for the specified key. This method blocks the calling thread until the object has been set.
 
 @see setObject:forKey:block:
 @param object An object to store in the cache.
 @param key A key to associate with the object. This string will be copied.
 */
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;

/**
 Removes the object for the specified key. This method blocks the calling thread until the object
 has been removed.
 
 @param key The key associated with the object to be removed.
 */
- (void)removeObjectForKey:(NSString *)key;

/**
 Removes all objects from the cache that have not been used since the specified date.
 This method blocks the calling thread until the cache has been trimmed.
 
 @param date Objects that haven't been accessed since this date are removed from the cache.
 */
- (void)trimToDate:(NSDate *)date;

/**
 Removes all objects from the cache. This method blocks the calling thread until the cache has been cleared.
 */
- (void)removeAllObjects;

@end
