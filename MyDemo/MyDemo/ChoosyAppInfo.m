//
//  ChoosyAppInfo.m
//  WeatherApp
//
//  Created by John on 15/6/11.
//  Copyright (c) 2015年 Ruenzuo. All rights reserved.
//

#import "ChoosyAppInfo.h"
#import <Mantle/Mantle.h>
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
             @"isInstalled" : @"isInstalled",
             @"specificObject": @"specific",
             @"dicObject":@"dic"
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
    return [MTLJSONAdapter transformerForModelPropertiesOfClass:[ChoosyAppAction class]];
}

+ (NSValueTransformer *)specificObjectJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error){
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date, BOOL *success, NSError **error) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSString *)transLateString:(NSString *)string
{
    return [NSString stringWithFormat:@"%@-1", string];
}

//+ (NSValueTransformer *)specificObjectJSONTransformer
//{
//    return [MTLValueTransformer transformerUsingForwardBlock:^(NSDictionary *dic, BOOL *success, NSError **error){
//        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
//    } reverseBlock:^(NSDate *date, BOOL *success, NSError **error) {
//        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
//    }];
//}

@end
