//
//  ChoosyAppInfo.m
//  WeatherApp
//
//  Created by John on 15/6/11.
//  Copyright (c) 2015年 Ruenzuo. All rights reserved.
//

#import "ChoosyAppInfo.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "ChoosyAppAction.h"

@implementation ChoosyAppInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // model_property_name : json_field_name
    return @{
             @"appName" : @"name",
             @"appKey" : @"key",
             @"appURLScheme" : @"app_url_scheme",
             @"appActions" : @"actions",
             @"isInstalled" : NSNull.null // tell Mantle to ignore this property
             };
}

+ (NSValueTransformer *)appURLSchemeJSONTransformer {
    // use Mantle's built-in "value transformer" to convert strings to NSURL and vice-versa
    // you can write your own transformers
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)appActionsJSONTransformer
{
    // tell Mantle to populate appActions property with an array of ChoosyAppAction objects
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[ChoosyAppAction class]];
}

@end
