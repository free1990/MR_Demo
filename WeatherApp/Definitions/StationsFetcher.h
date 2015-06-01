//
//  StationsFetcher.h
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/21/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blocks.h"

@class City;

@protocol StationsFetcher <NSObject>

//获取城市的地区
- (void)getStationsWithCity:(City *)city
                  completion:(ArrayCompletionBlock)completion;

@end
