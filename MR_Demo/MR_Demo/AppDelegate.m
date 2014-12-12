//
//  AppDelegate.m
//  MR_Demo
//
//  Created by John on 9/18/14.
//  Copyright (c) 2014 WorkMac. All rights reserved.
//

#import "AppDelegate.h"
#import "Student.h"
#import "Class_list.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model.sqlite"];
    
//    for (int i = 0; i < 10; i++) {
//        Student *person = [Student MR_createEntity];
//        person.name = [NSString stringWithFormat:@"lao%d", i];
//        person.age = [NSNumber numberWithInt:1];
//        person.id_class = [NSNumber numberWithInt:i+10];
//        
//        
//        Class_list *class = [Class_list MR_createEntity];
//        class.name = [NSString stringWithFormat:@"%d ban", i];
//        class.id_class = [NSNumber numberWithInt:i+10];
//        
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    }
    
    
    NSArray *students = [Student MR_findByAttribute:@"id_class" withValue:@"18"];
    
    Student *temp = [students objectAtIndex:0];
    
    NSLog(@"--------->  %@", temp.name);
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [MagicalRecord cleanUp];
}

@end
