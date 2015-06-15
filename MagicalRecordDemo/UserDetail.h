//
//  UserDetail.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/6/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface UserDetail : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * occupation;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) User *user;

@end
