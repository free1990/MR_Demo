//
//  Countries.h
//  WeatherApp
//
//  Created by Renzo Crisóstomo on 1/14/14.
//  Copyright (c) 2014 Ruenzuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blocks.h"

@protocol CountriesFetcher <NSObject>

//获得国家的协议方法
- (void)getCountriesWithCompletion:(ArrayCompletionBlock)completion;

@end
