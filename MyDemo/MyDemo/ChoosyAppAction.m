//
//  ChoosyAppAction.m
//  WeatherApp
//
//  Created by John on 15/6/11.
//  Copyright (c) 2015年 Ruenzuo. All rights reserved.
//

#import "ChoosyAppAction.h"

@implementation ChoosyAppAction

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // model_property_name : json_field_name
    return @{
             @"actionKey" : @"key",
             @"urlFormat" : @"url_format"
             };
}

@end
