//
//  ApiMethod.m
//  LLNetWork
//
//  Created by LLVK on 29/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#import "ApiMethod.h"
#import "HttpRequestWithCache.h"

NSString *const kTestGet = @"......";

@implementation ApiMethod

+ (void)getBlogData:(NSDictionary *)param isCache:(BOOL)isCache result:(void(^)(id))block
{
    [HttpRequestWithCache getRequestMethod:kTestGet param:param  isCache:isCache withBlock:^(id response, NSInteger errorCode) {
        !block?:block(response);
    }];
    
}


@end
