//
//  ApiMethod.h
//  LLNetWork
//
//  Created by LLVK on 29/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiMethod : NSObject
+ (void)getBlogData:(NSDictionary *)param isCache:(BOOL)isCache result:(void(^)(id))block;

@end
