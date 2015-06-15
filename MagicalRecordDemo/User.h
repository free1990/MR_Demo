//
//  User.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/6/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, UserDetail;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *groups;
@property (nonatomic, retain) UserDetail *userDetail;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
