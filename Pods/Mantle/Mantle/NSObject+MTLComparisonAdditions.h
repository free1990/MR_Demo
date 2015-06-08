//
//  NSObject+MTLComparisonAdditions.h
//  Mantle
//
//  Created by Josh Vera on 10/26/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//
//  Portions copyright (c) 2011 Bitswift. All rights reserved.
//  See the LICENSE file for more information.
//

#import <Foundation/Foundation.h>

// Returns whether both objects are identical or equal via -isEqual:
// 给Object添加对象是否相等的帮助方法
BOOL MTLEqualObjects(id obj1, id obj2);
