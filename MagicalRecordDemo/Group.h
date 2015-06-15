//
//  Group.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/6/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Privileges, User;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Privileges *privileges;
@property (nonatomic, retain) NSSet *users;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addUsersObject:(User *)value;
- (void)removeUsersObject:(User *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
