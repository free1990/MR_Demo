//
//  TranslatorHelper.m
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/15/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import "TranslatorHelper.h"
#import <Mantle/Mantle.h>

@implementation TranslatorHelper

// 辅助类用来提供方便的接口用来处理数据

//直接转换成对象
- (id)translateModelFromJSON:(NSDictionary *)JSON
                withclassName:(NSString *)className
{
    NSParameterAssert(className != nil);
    NSError *error = nil;
    
    //利用Mantle把JSON转成class
    id model = [MTLJSONAdapter modelOfClass:NSClassFromString(className)
                         fromJSONDictionary:JSON
                                      error:&error];
    if (!error) {
        return model;
    } else {
        return nil;
    }
}


//数组类型的JSON转包含自己类型的数组
- (id)translateCollectionFromJSON:(NSDictionary *)JSON
                    withClassName:(NSString *)className
{
    NSParameterAssert(className != nil);
    
    if ([JSON isKindOfClass:[NSArray class]]) {
        
        //把解析后的数据格式和JSON文件绑定起来
        NSValueTransformer *valueTransformer = [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:NSClassFromString(className)];
        
        //透过里面的玩法，其实相当于通过block的延迟执行，把这个值返回出来，此时的值已经是正常可以去使用的对象的集合了
        NSArray *collection = [valueTransformer transformedValue:JSON];
        return collection;
    }
    return nil;
}

//???:把存入Model的managedObject的
- (id)translateModelfromManagedObject:(NSManagedObject *)managedObject
                        withClassName:(NSString *)className
{
    NSParameterAssert(className != nil);
    NSError *error = nil;
    id model = [MTLManagedObjectAdapter modelOfClass:NSClassFromString(className)
                                   fromManagedObject:managedObject
                                               error:&error];
    if (!error) {
        return model;
    } else {
        return nil;
    }
}

//managedObjects都转换成对应的数组
- (id)translateCollectionfromManagedObjects:(NSArray *)managedObjects
                              withClassName:(NSString *)className
{
    NSParameterAssert(className != nil);
    if ([managedObjects isKindOfClass:[NSArray class]]) {
        NSMutableArray *collection = [NSMutableArray array];
        for (NSManagedObject *managedObject in managedObjects) {
            id model = [self translateModelfromManagedObject:managedObject
                                               withClassName:className];
            [collection addObject:model];
        }
        return collection;
    }
    return nil;
}

@end
