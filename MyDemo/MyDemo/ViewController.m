//
//  ViewController.m
//  MyDemo
//
//  Created by John on 15/6/12.
//  Copyright (c) 2015年 WorkMac. All rights reserved.
//

#import "ViewController.h"
#import <Mantle/Mantle.h>
#import "ChoosyAppInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self testMantleFunc];
}

- (void)testMantleFunc
{
    NSLog(@"测试Mantle");
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    NSError *error = nil;
    id jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
    
    NSArray *objectArray = [MTLJSONAdapter modelsOfClass:[ChoosyAppInfo class] fromJSONArray:jsonArray error:&error];
    
    for ( int i = 0; i < [objectArray count]; i++ ) {
        
        ChoosyAppInfo *appInfo = [objectArray objectAtIndex:i];
        
        NSLog(@"appinfo name = %@ app action count = %ld appURLScheme = %@, appInfo.specificObject = %@", appInfo.appName, [appInfo.appActions count], appInfo.appURLScheme, appInfo.specificObject);
        
         NSLog(@"dic = %@", [appInfo.dicObject objectForKey:@"key"]);
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
