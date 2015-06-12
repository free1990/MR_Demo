//
//  NSError+MTLModelException.h
//  Mantle
//
//  Created by Robert Böhnke on 7/6/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (MTLModelException)

// Creates a new error for an exception that occured during updating an
// MTLModel.
//
// exception - The exception that was thrown while updating the model.
//             This argument must not be nil.
//
// Returns an error that takes its localized description and failure reason
// from the exception.
// model错误抛出的异常
+ (instancetype)mtl_modelErrorWithException:(NSException *)exception;

@end
