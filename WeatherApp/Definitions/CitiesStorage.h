//
//  CitiesStorage.h
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/15/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Country;

@protocol CitiesStorage <NSObject>

//把一个国家里面的城市存储下来
- (void)storeCities:(NSArray *)cities
        fromCountry:(Country *)country;

@end
