//
//  ChoosyAppAction.h
//  WeatherApp
//
//  Created by John on 15/6/11.
//  Copyright (c) 2015年 Ruenzuo. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface ChoosyAppAction : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *actionKey;
@property (nonatomic) NSString *urlFormat;

@end