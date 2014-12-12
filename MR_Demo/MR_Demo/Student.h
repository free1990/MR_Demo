//
//  Student.h
//  MR_Demo
//
//  Created by John on 9/18/14.
//  Copyright (c) 2014 WorkMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * id_class;

@end
