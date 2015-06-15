//
//  ChoosyAppInfo.h
//  WeatherApp
//
//  Created by John on 15/6/11.
//  Copyright (c) 2015年 Ruenzuo. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h" // defines MTLJSONSerializing

@interface ChoosyAppInfo : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *appName;
@property (nonatomic) NSString *appKey;
@property (nonatomic) NSURL *appURLScheme;
@property (nonatomic) NSArray *appActions; // of ChoosyAppAction
@property (nonatomic) NSDate *specificObject;

@property (nonatomic) BOOL isInstalled;

@property (nonatomic) NSDictionary *dicObject;
@end