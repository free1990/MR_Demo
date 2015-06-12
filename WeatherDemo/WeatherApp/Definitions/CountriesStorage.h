//
//  CountriesStorage.h
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/15/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CountriesStorage <NSObject>

//存储国家的城市
- (void)storeCountries:(NSArray *)cities;

@end
