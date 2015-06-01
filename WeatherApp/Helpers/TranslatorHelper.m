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
        NSValueTransformer *valueTransformer = [MTLValueTransformer mtl_JSONArrayTransformerWithModelClass:NSClassFromString(className)];
        NSArray *collection = [valueTransformer transformedValue:JSON];
        return collection;
    }
    return nil;
}

//???:不知道咋么玩
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
