//
//  Privileges.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/6/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Privileges : NSManagedObject

@property (nonatomic, retain) NSNumber * createUsers;
@property (nonatomic, retain) NSNumber * editPosts;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSSet *groups;
@end

@interface Privileges (CoreDataGeneratedAccessors)

- (void)addGroupsObject:(Group *)value;
- (void)removeGroupsObject:(Group *)value;
- (void)addGroups:(NSSet *)values;
- (void)removeGroups:(NSSet *)values;

@end
