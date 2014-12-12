//
//  Person.h
//  MR_Demo
//
//  Created by John on 14-9-22.
//  Copyright (c) 2014年 WorkMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Card;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Card *card;

@end
