//
//  StationStorage.h
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/21/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class City;

@protocol StationsStorage <NSObject>

//把城市的地区存储下来
- (void)storeStations:(NSArray *)stations
             fromCity:(City *)city;

@end
