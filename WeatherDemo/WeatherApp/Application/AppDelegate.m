//
//  AppDelegate.m
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/14/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import <TMCache/TMCache.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import "CacheHelper.h"
#import "AppDelegate.h"
#import "MTLJSONAdapter.h"
#import "MTLValueTransformer.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "ChoosyAppInfo.h"

@implementation AppDelegate
{
}

#pragma mark - Application Life Cycle

-           (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self testMantleFunc];
    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    
    //设置最大cost是MEMORY_CACHE_COST_LIMIT
    [[[TMCache sharedCache] memoryCache] setCostLimit:MEMORY_CACHE_COST_LIMIT];
    
    
    
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:20 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    return YES;
}

// TODO:123123123
// FIXME:12312312312312
// ???:TEST ???
// !!!:TEST !!!

- (void)testMantleFunc
{
    NSLog(@"测试Mantle");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error = nil;
   id array = [NSJSONSerialization JSONObjectWithData:data
                                              options:NSJSONReadingAllowFragments
                                                error:&error];
    
    NSValueTransformer *valueTransformer = [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:[ChoosyAppInfo class]];
    
    //透过里面的玩法，其实相当于通过block的延迟执行，把这个值返回出来，此时的值已经是正常可以去使用的对象的集合了
    NSArray *collection = [valueTransformer transformedValue:array];

    
    for ( int i = 0; i < [collection count]; i++ ) {
        
        ChoosyAppInfo *appInfo = [collection objectAtIndex:i];
        
        NSLog(@"appinfo name = %@ app action count = %ld appURLScheme = %@", appInfo.appName, [appInfo.appActions count], appInfo.appURLScheme);
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

@end
