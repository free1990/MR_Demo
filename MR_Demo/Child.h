//
//  Child.h
//  MR_Demo
//
//  Created by John on 14-9-22.
//  Copyright (c) 2014年 WorkMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Parents.h"

@class Parents;

@interface Child : Parents

@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) Parents *test;

@end
