//
//  HttpRequestWithCache.h
//  LLNetWork
//
//  Created by LLVK on 29/07/2017.
//  Copyright © 2017 devHuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpHeader.h"


@interface HttpRequestWithCache : NSObject

#pragma mark - Get方法
/**
    *method: 接口名
    *param: 传入字典
*/
+ (void)getRequestMethod:(NSString *)method param:(NSDictionary *)param isCache:(BOOL)cache withBlock:(void(^)(id response,NSInteger errorCode))block;

#pragma mark - Post方法
+ (void)postRequestMethod:(NSString *)method param:(NSDictionary *)param isCache:(BOOL)cache withBlock:(void(^)(id response,NSInteger errorCode))block;
#pragma mark - 上传文件方法
//上传单张图片
+ (void)upLoadDataWithMethod:(NSString *)method param:(NSDictionary *)param imageKey:(NSString *)name withData:(NSData *)data withBlock:(void(^)(id response,NSInteger errorCode))block;
//上传多张图片
+ (void)upLoadDataWithMethod:(NSString *)method param:(NSDictionary *)param  withDataArray:(NSArray *)dataArray withBlock:(void(^)(id response,NSInteger errorCode))block;

@end
