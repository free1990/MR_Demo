//
//  Card.h
//  MR_Demo
//
//  Created by John on 14-9-22.
//  Copyright (c) 2014年 WorkMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Card : NSManagedObject

@property (nonatomic, retain) NSString * no;
@property (nonatomic, retain) NSManagedObject *person;

@end
