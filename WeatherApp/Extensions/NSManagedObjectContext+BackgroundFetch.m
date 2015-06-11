//
//  NSManagedObjectContext+BackgroundFetch.m
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/21/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import "NSManagedObjectContext+BackgroundFetch.h"

@implementation NSManagedObjectContext (BackgroundFetch)

- (void)executeFetchRequest:(NSFetchRequest *)request
                 completion:(ArrayCompletionBlock)completion
{
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    // 异步并发的的去查询
    [backgroundContext performBlock:^{
        backgroundContext.persistentStoreCoordinator = coordinator;
        NSError *error = nil;
        
        // 此时已经查处指定request的数据集合
        NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        
        [self performBlock:^{
            if (fetchedObjects) {
                
                //???: 为什么需要这样做两步，而不是说直接去把fetchedObjects 进行copy
                
                // 先获取到每个NSManagedObject的objectID
                NSMutableArray *mutObjectIds = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
                for (NSManagedObject *obj in fetchedObjects) {
                    [mutObjectIds addObject:obj.objectID];
                }
                
                // 根据objectID获取到每个NSManagedObject
                NSMutableArray *mutObjects = [[NSMutableArray alloc] initWithCapacity:[mutObjectIds count]];
                for (NSManagedObjectID *objectID in mutObjectIds) {
                    NSManagedObject *obj = [self objectWithID:objectID];
                    [mutObjects addObject:obj];
                }
                
                // 回调获得的数据
                if (completion) {
                    NSArray *objects = [mutObjects copy];
                    completion(objects, nil);
                }
            } else {
                if (completion) {
                    completion(nil, error);
                }
            }
        }];
    }];
}

@end
