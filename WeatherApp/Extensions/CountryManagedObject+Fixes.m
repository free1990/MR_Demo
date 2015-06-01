//
//  CountryManagedObject+Fixes.m
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/21/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import "CountryManagedObject+Fixes.h"

@implementation CountryManagedObject (Fixes)

//添加城市的信息
- (void)addCitiesObject:(CityManagedObject *)value
{
    //ManagedObject其实是kvo的，依赖运行时的时候生成一个新的对象
    [self willChangeValueForKey:@"cities"];
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.cities];
    [tempSet addObject: value];
    self.cities = tempSet;
    [self didChangeValueForKey:@"cities"];
}

@end
