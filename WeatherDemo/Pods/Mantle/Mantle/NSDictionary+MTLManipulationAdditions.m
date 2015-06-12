//
//  NSDictionary+MTLManipulationAdditions.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-24.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSDictionary+MTLManipulationAdditions.h"

@implementation NSDictionary (MTLManipulationAdditions)

//把一个字典里面的所有的键值对都已经移动到另外的一个字典里面
- (NSDictionary *)mtl_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
	NSMutableDictionary *result = [self mutableCopy];
	[result addEntriesFromDictionary:dictionary];
	return result;
}

// 删除指定的keys
- (NSDictionary *)mtl_dictionaryByRemovingEntriesWithKeys:(NSSet *)keys {
	NSMutableDictionary *result = [self mutableCopy];
	[result removeObjectsForKeys:keys.allObjects];
	return result;
}

@end
